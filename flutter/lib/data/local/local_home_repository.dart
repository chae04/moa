// [역할] 홈 요약의 로컬 구현 (서버 HomeService를 Dart로 옮김)
// - 유형별 합계, 날짜별 지출, 카테고리별 예산·사용액·잔액, 일일 추천 예산을 계산한다.
// - 홈 카테고리 목록 = 아래 셋의 합집합 (예산은 비율 행이 없으면 0)
//   1) 그 달 비율 묶음에서 비율이 0보다 큰 카테고리
//   2) 그 달 사용액이 있는 카테고리 (삭제된 것 포함)
//   3) 그 달 말일까지 만들어진 활성 카테고리
// - 예산 = 수입 × 비율 (반올림). 사용액 = 그 카테고리를 출처로 한 거래 합 (자동 거래는 출처가 없어서 자연히 제외)
// - 저축·투자 합계 = 그 유형 거래 합 - 저축·투자에서 꺼내 쓴 지출 (꺼낸 만큼 줄어듦)

import 'package:drift/drift.dart';
import 'package:moa/data/local/app_database.dart';
import 'package:moa/data/local/local_transaction_repository.dart';
import 'package:moa/data/repositories.dart';
import 'package:moa/models/home_model.dart';
import 'package:moa/models/transaction_model.dart';

class LocalHomeRepository implements HomeRepository {
  final AppDatabase _db;
  final LocalTransactionRepository _transactions; // 월별 거래 조회 재사용
  LocalHomeRepository(this._db, this._transactions);

  @override
  Future<HomeModel> getHome(int year, int month) async {
    final transactions = await _transactions.getMonthlyTransactions(
      year,
      month,
    ); // 연월 검증도 여기서
    final yearMonth = '$year-${month.toString().padLeft(2, '0')}';

    // 1. 거래를 돌며 유형별 합계, 카테고리별 사용액, 날짜별 지출
    var totalIncome = 0, totalExpense = 0, totalSaving = 0, totalInvest = 0;
    final usedByCategory = <int, int>{};
    final expenseByDate = <DateTime, int>{};
    final categoryIds = <int>{}; // 목록에 넣을 카테고리 id (Set이라 중복 자동 제거)

    for (final t in transactions) {
      switch (t.type) {
        case LocalTransactionRepository.income:
          totalIncome += t.amount;
        case LocalTransactionRepository.expense:
          totalExpense += t.amount;
          expenseByDate[t.date] = (expenseByDate[t.date] ?? 0) + t.amount;
          // 저축·투자에서 꺼내 쓴 지출은 그만큼 저축·투자 합계에서 뺌 (지난달에 모은 돈을 꺼내면 음수 가능)
          if (t.fundSource == LocalTransactionRepository.saving) totalSaving -= t.amount;
          if (t.fundSource == LocalTransactionRepository.invest) totalInvest -= t.amount;
        case LocalTransactionRepository.saving:
          totalSaving += t.amount;
        case LocalTransactionRepository.invest:
          totalInvest += t.amount;
      }
      final categoryId = t.budgetCategoryId;
      if (categoryId != null) {
        usedByCategory[categoryId] = (usedByCategory[categoryId] ?? 0) + t.amount;
        categoryIds.add(categoryId); // 사용액이 있는 카테고리 (삭제된 것 포함)
      }
    }

    // 2. 그 달 비율 묶음에서 비율이 0보다 큰 카테고리
    final applyFrom = await _db.latestApplyFrom(yearMonth);
    final ratioByCategory = <int, int>{};
    if (applyFrom != null) {
      final items = await (_db.select(
        _db.ratioItems,
      )..where((i) => i.applyFrom.equals(applyFrom))).get();
      for (final item in items) {
        if (item.ratio > 0) {
          ratioByCategory[item.categoryId] = item.ratio;
          categoryIds.add(item.categoryId);
        }
      }
    }

    // 3. 그 달 말일까지 만들어진 활성 카테고리
    final nextMonthStart = DateTime(year, month + 1, 1);
    final active = await (_db.select(
      _db.budgetCategories,
    )..where((c) => c.isDeleted.equals(false))).get();
    for (final c in active) {
      if (c.createdAt.isBefore(nextMonthStart)) categoryIds.add(c.id);
    }

    // 목록에 들어갈 카테고리 행을 한 번에 읽고 표시 순서대로
    final categories = categoryIds.isEmpty
        ? <CategoryRow>[]
        : await (_db.select(_db.budgetCategories)
                ..where((c) => c.id.isIn(categoryIds))
                ..orderBy([(c) => OrderingTerm.asc(c.orderIndex)]))
              .get();

    final summaries = categories.map((c) {
      final ratio = ratioByCategory[c.id] ?? 0;
      final budget = (totalIncome * ratio / 100).round();
      final used = usedByCategory[c.id] ?? 0;
      return CategorySummary(
        categoryId: c.id,
        name: c.name,
        budget: budget,
        used: used,
        remaining: budget - used,
        showOnHome: c.showOnHome,
        includeInDaily: c.includeInDaily,
        deleted: c.isDeleted,
      );
    }).toList();

    final dates = expenseByDate.keys.toList()..sort(); // 날짜순 (서버 TreeMap)
    final dailyExpenses = dates
        .map((d) => DailyExpense(date: d, amount: expenseByDate[d]!))
        .toList();

    final daily = _daily(year, month, applyFrom, summaries, transactions);

    return HomeModel(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      totalSaving: totalSaving,
      totalInvest: totalInvest,
      categories: summaries,
      dailyExpenses: dailyExpenses,
      dailyBudget: daily?.perDay,
      todayBudget: daily?.todayBudget,
      todaySpent: daily?.todaySpent,
      todayRemaining: daily?.todayRemaining,
    );
  }

  // 하루 추천 금액, 오늘 추천, 오늘 남은 돈
  // - 오늘 아침 잔액 = 활성 includeInDaily 카테고리 잔액 합 + 오늘 쓴 돈 (오늘 지출 전으로 되돌린 값)
  // - 오늘 추천 = 오늘 아침 잔액 ÷ 남은 일수(오늘 포함). 오늘 지출을 넣어도 그날은 그대로
  // - 오늘 남은 돈 = 오늘 추천 - 오늘 쓴 돈 (음수면 초과)
  // - 하루 추천 금액(내일부터) = (오늘 아침 잔액 - max(오늘 추천, 오늘 쓴 돈)) ÷ (남은 일수 - 1)
  //   · 오늘 추천 안에서 쓰면 그대로, 넘게 써서 마이너스가 되면 넘은 만큼 남은 날에 나눠 줄어듦
  //   · 이달 마지막 날이면 내일이 없으므로 null
  // - 다음 달 이후: 그 달 전체 잔액 ÷ 그 달 일수 (오늘 값은 없음)
  // - 비율이 없거나 지난달이면 null, 잔액이 0 이하면 0
  ({int? perDay, int? todayBudget, int? todaySpent, int? todayRemaining})? _daily(
    int year,
    int month,
    String? applyFrom,
    List<CategorySummary> summaries,
    List<TransactionModel> transactions,
  ) {
    if (applyFrom == null) return null;

    final now = DateTime.now();
    final target = year * 12 + month; // 월을 숫자 하나로 바꿔서 비교
    final thisMonth = now.year * 12 + now.month;
    if (target < thisMonth) return null;

    final daysInMonth = DateTime(year, month + 1, 0).day; // 다음 달 0일 = 이번 달 말일
    final dailyCategories = summaries.where((s) => s.includeInDaily && !s.deleted);
    final remaining = dailyCategories.fold(0, (sum, s) => sum + s.remaining);
    int perDayOf(int amount, int days) => amount <= 0 ? 0 : (amount / days).round();

    // 다음 달 이후: 오늘이 없으므로 그 달 전체 기준
    if (target > thisMonth) {
      return (
        perDay: perDayOf(remaining, daysInMonth),
        todayBudget: null,
        todaySpent: null,
        todayRemaining: null,
      );
    }

    // 이번 달
    final remainingDays = daysInMonth - now.day + 1; // 오늘 포함
    final dailyIds = dailyCategories.map((s) => s.categoryId).toSet();
    final today = DateTime(now.year, now.month, now.day);
    final todaySpent = transactions
        .where((t) => t.date == today && dailyIds.contains(t.budgetCategoryId))
        .fold(0, (sum, t) => sum + t.amount);

    final startOfDay = remaining + todaySpent; // 오늘 아침 기준 잔액
    final todayBudget = perDayOf(startOfDay, remainingDays);
    final usedToday = todaySpent > todayBudget
        ? todaySpent
        : todayBudget; // 넘게 썼으면 실제로 쓴 만큼
    final perDay = remainingDays > 1
        ? perDayOf(startOfDay - usedToday, remainingDays - 1)
        : null;

    return (
      perDay: perDay,
      todayBudget: todayBudget,
      todaySpent: todaySpent,
      todayRemaining: todayBudget - todaySpent,
    );
  }
}
