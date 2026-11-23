// [역할] 통계의 로컬 구현 (서버 StatsService를 Dart로 옮김)
// - 카테고리별 지출: 그 달 지출을 거래의 category 문자열로 묶어 합계 (금액 큰 순)
// - 1년 추이: 1~12월 수입·지출 합계, 모은 돈 = 수입 - 지출
// - 저축·투자에서 꺼내 쓴 지출도 "지출"이라 둘 다에 포함됨 (모아 둔 돈이 실제로 나간 것이므로)

import 'package:drift/drift.dart';
import 'package:moa/data/app_exception.dart';
import 'package:moa/data/local/app_database.dart';
import 'package:moa/data/repositories.dart';
import 'package:moa/models/stats_model.dart';

class LocalStatsRepository implements StatsRepository {
  final AppDatabase _db;
  LocalStatsRepository(this._db);

  @override
  Future<CategoryStatsModel> getCategoryStats(int year, int month) async {
    if (year < 2000 || year > 2100 || month < 1 || month > 12) {
      throw const AppException('조회할 연도와 월이 올바르지 않습니다.');
    }
    final t = _db.transactions;
    final sum = t.amount.sum();

    // SELECT category, SUM(amount) FROM transactions
    // WHERE type = '지출' AND date >= 그달1일 AND date < 다음달1일 GROUP BY category ORDER BY SUM DESC
    final query = _db.selectOnly(t)
      ..addColumns([t.category, sum])
      ..where(
        t.type.equals('지출') &
            t.date.isBiggerOrEqualValue(DateTime(year, month, 1)) &
            t.date.isSmallerThanValue(DateTime(year, month + 1, 1)),
      )
      ..groupBy([t.category])
      ..orderBy([OrderingTerm.desc(sum)]);

    final categories = await query
        .map(
          (row) =>
              CategoryAmount(category: row.read(t.category)!, amount: row.read(sum) ?? 0),
        )
        .get();
    final total = categories.fold(0, (s, c) => s + c.amount);
    return CategoryStatsModel(totalExpense: total, categories: categories);
  }

  @override
  Future<YearlyStatsModel> getYearlyStats(int year) async {
    if (year < 2000 || year > 2100) throw const AppException('조회할 연도가 올바르지 않습니다.');

    // 그해 수입·지출 거래만 읽어서 월별로 더함 (칸 번호 = 월, 0번 칸은 안 씀)
    final rows =
        await (_db.select(_db.transactions)..where(
              (x) =>
                  x.type.isIn(['수입', '지출']) &
                  x.date.isBiggerOrEqualValue(DateTime(year, 1, 1)) &
                  x.date.isSmallerThanValue(DateTime(year + 1, 1, 1)),
            ))
            .get();

    final income = List.filled(13, 0);
    final expense = List.filled(13, 0);
    for (final r in rows) {
      if (r.type == '수입') {
        income[r.date.month] += r.amount;
      } else {
        expense[r.date.month] += r.amount;
      }
    }

    final months = [
      for (var m = 1; m <= 12; m++)
        MonthSummary(month: m, income: income[m], expense: expense[m]),
    ];
    final totalIncome = income.fold(0, (s, v) => s + v);
    final totalExpense = expense.fold(0, (s, v) => s + v);
    return YearlyStatsModel(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      totalSaved: totalIncome - totalExpense,
      months: months,
    );
  }
}
