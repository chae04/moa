// [역할] 앱 개선 기능의 로컬 규칙 확인
// - 저축·투자에서 꺼내 쓴 지출(fundSource), 수입·지출 카테고리 관리, 통계, DB v1 → v2 마이그레이션
// - 실행: flutter test test/local_features_test.dart

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moa/data/app_exception.dart';
import 'package:moa/data/local/app_database.dart';
import 'package:moa/data/local/backup_service.dart';
import 'package:moa/data/local/local_entry_category_repository.dart';
import 'package:moa/data/local/local_home_repository.dart';
import 'package:moa/data/local/local_setup.dart';
import 'package:moa/data/local/local_stats_repository.dart';
import 'package:moa/data/local/local_transaction_repository.dart';
import 'package:moa/models/transaction_model.dart';

// 비동기 함수의 에러는 await expectLater(...)로 검사해야 다음 줄이 검사가 끝난 뒤에 실행됨
Matcher throwsAppException(String message) =>
    throwsA(isA<AppException>().having((e) => e.message, 'message', message));

void main() {
  late AppDatabase db;
  late LocalTransactionRepository transactions;
  late LocalHomeRepository home;
  late LocalEntryCategoryRepository entries;
  late LocalStatsRepository stats;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    transactions = LocalTransactionRepository(db);
    home = LocalHomeRepository(db, transactions);
    entries = LocalEntryCategoryRepository(db);
    stats = LocalStatsRepository(db);
    await LocalSetup(db).createInitial(
      categories: [(name: '생활비', includeInDaily: true, ratio: 70)],
      savingRatio: 20,
      investRatio: 10,
    );
  });
  tearDown(() => db.close());

  TransactionModel tx({
    required String type,
    required int amount,
    String category = '식비',
    int? budgetCategoryId,
    String? fundSource,
    DateTime? date,
  }) => TransactionModel(
    title: '거래',
    amount: amount,
    type: type,
    category: category,
    budgetCategoryId: budgetCategoryId,
    fundSource: fundSource,
    date: date ?? today,
  );

  group('저축·투자에서 꺼내 쓴 지출', () {
    test('카테고리 사용액에서는 빠지고, 지출 합계·통계에는 포함, 홈 저축 합계는 꺼낸 만큼 줄어듦', () async {
      await transactions.addTransaction(tx(type: '수입', amount: 1000000, category: '월급'));
      await transactions.addTransaction(tx(type: '지출', amount: 50000, category: '의료', fundSource: '저축'));

      final h = await home.getHome(now.year, now.month);
      expect(h.totalExpense, 50000); // 지출 합계에는 포함
      expect(h.totalSaving, 150000); // 자동 저축 200,000 - 저축에서 꺼낸 50,000
      expect(h.totalInvest, 100000); // 투자는 그대로
      expect(h.categories.single.used, 0); // 생활비 사용액에는 안 들어감
      expect(h.dailyExpenses.single.amount, 50000); // 달력에는 표시

      final list = await transactions.getMonthlyTransactions(now.year, now.month);
      final spent = list.firstWhere((t) => t.fundSource != null);
      expect(spent.budgetCategoryId, isNull);
      expect(spent.sourceLabel, '저축에서');

      final c = await stats.getCategoryStats(now.year, now.month);
      expect(c.categories.single.category, '의료');
    });

    test('이번 달 넣은 것보다 많이 꺼내면 음수', () async {
      await transactions.addTransaction(tx(type: '지출', amount: 30000, category: '의료', fundSource: '투자'));
      final h = await home.getHome(now.year, now.month);
      expect(h.totalInvest, -30000); // 이번 달 투자 0 - 꺼낸 30,000
      expect(h.totalSaving, 0);
    });

    test('지출에서만 선택 가능, 저축·투자만 허용', () async {
      await expectLater(
        () => transactions.addTransaction(tx(type: '저축', amount: 1000, fundSource: '투자')),
        throwsAppException('저축·투자에서 꺼내 쓰기는 지출에서만 선택할 수 있어요.'),
      );
      await expectLater(
        () => transactions.addTransaction(tx(type: '지출', amount: 1000, fundSource: '비상금')),
        throwsAppException('출처는 저축 또는 투자여야 합니다.'),
      );
    });
  });

  group('오늘 남은 돈', () {
    // 생활비 70%(일일 예산 포함), 수입 1,000,000원 → 생활비 예산 700,000원
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final remainingDays = daysInMonth - now.day + 1; // 오늘 포함
    final todayBudget = (700000 / remainingDays).round(); // 오늘 추천
    int? future(int usedToday) =>
        remainingDays > 1 ? ((700000 - usedToday) / (remainingDays - 1)).round() : null;

    test('오늘 추천 안에서 쓰면: 오늘 추천·하루 추천 금액 그대로, 오늘 남은 돈만 줄어듦', () async {
      final living = (await db.select(db.budgetCategories).get()).single.id;
      await transactions.addTransaction(tx(type: '수입', amount: 1000000, category: '월급'));

      final before = await home.getHome(now.year, now.month);
      expect(before.todayBudget, todayBudget);
      expect(before.todayRemaining, todayBudget);
      expect(before.dailyBudget, future(todayBudget));

      await transactions.addTransaction(tx(type: '지출', amount: 1000, budgetCategoryId: living));
      await transactions.addTransaction(tx(type: '지출', amount: 5000, fundSource: '저축')); // 일일 예산 밖

      final after = await home.getHome(now.year, now.month);
      expect(after.todayBudget, todayBudget); // 그날은 그대로
      expect(after.todaySpent, 1000); // 저축에서 꺼낸 돈은 제외
      expect(after.todayRemaining, todayBudget - 1000);
      expect(after.dailyBudget, future(todayBudget)); // 추천 안에서 썼으면 내일부터 금액도 그대로
    });

    test('오늘 넘게 써서 마이너스면: 넘은 만큼 남은 날의 하루 추천 금액이 줄어듦', () async {
      final living = (await db.select(db.budgetCategories).get()).single.id;
      await transactions.addTransaction(tx(type: '수입', amount: 1000000, category: '월급'));
      final spent = todayBudget + 50000; // 50,000원 초과
      await transactions.addTransaction(tx(type: '지출', amount: spent, budgetCategoryId: living));

      final h = await home.getHome(now.year, now.month);
      expect(h.todayBudget, todayBudget);
      expect(h.todayRemaining, -50000);
      expect(h.dailyBudget, future(spent)); // 실제로 쓴 만큼 빼고 나눔
      if (remainingDays > 1) expect(h.dailyBudget! < future(todayBudget)!, true);
    });

    test('다음 달은 하루 추천 금액만 있고 오늘 값은 없음', () async {
      final next = DateTime(now.year, now.month + 1);
      final h = await home.getHome(next.year, next.month);
      expect(h.dailyBudget, isNotNull);
      expect(h.todayBudget, isNull);
      expect(h.todaySpent, isNull);
      expect(h.todayRemaining, isNull);
    });
  });

  group('수입·지출 카테고리', () {
    test('기본 목록이 들어가 있고, 추가·이름 변경·삭제 규칙', () async {
      expect((await entries.getCategories('수입')).map((c) => c.name), ['월급', '용돈', '기타']);
      expect((await entries.getCategories('지출')).first.name, '식비');

      await entries.addCategory('지출', '병원');
      expect((await entries.getCategories('지출')).last.name, '병원');
      await expectLater(() => entries.addCategory('지출', '병원'), throwsAppException('이미 있는 카테고리예요.'));
      await entries.addCategory('수입', '병원'); // 종류가 다르면 같은 이름 가능

      final hospital = (await entries.getCategories('지출')).last;
      await entries.renameCategory(hospital.id, '의료');
      expect((await entries.getCategories('지출')).last.name, '의료');

      await entries.deleteCategory(hospital.id);
      expect((await entries.getCategories('지출')).any((c) => c.name == '의료'), false);
    });

    test('종류마다 최소 1개 유지', () async {
      final income = await entries.getCategories('수입');
      for (final c in income.skip(1)) {
        await entries.deleteCategory(c.id);
      }
      await expectLater(
        () => entries.deleteCategory(income.first.id),
        throwsAppException('수입 카테고리는 최소 1개 있어야 합니다.'),
      );
    });
  });

  group('통계', () {
    test('카테고리별 지출은 큰 순, 1년 추이는 월별 수입 - 지출', () async {
      final living = (await db.select(db.budgetCategories).get()).single.id;
      await transactions.addTransaction(tx(type: '수입', amount: 300000, category: '월급'));
      await transactions.addTransaction(tx(type: '지출', amount: 10000, category: '교통', budgetCategoryId: living));
      await transactions.addTransaction(tx(type: '지출', amount: 30000, category: '식비', budgetCategoryId: living));
      await transactions.addTransaction(tx(type: '지출', amount: 5000, category: '식비', budgetCategoryId: living));

      final c = await stats.getCategoryStats(now.year, now.month);
      expect(c.totalExpense, 45000);
      expect(c.categories.map((x) => '${x.category}:${x.amount}'), ['식비:35000', '교통:10000']);

      final y = await stats.getYearlyStats(now.year);
      expect(y.months.length, 12);
      final m = y.months[now.month - 1];
      expect(m.income, 300000);
      expect(m.expense, 45000);
      expect(m.saved, 255000);
      expect(y.totalSaved, 255000); // 자동 저축·투자는 수입·지출이 아니라 모은 돈 계산에 안 들어감
    });
  });

  test('백업 v2: 수입·지출 카테고리와 꺼내 쓴 지출 출처까지 되살림', () async {
    await entries.addCategory('지출', '병원');
    await transactions.addTransaction(tx(type: '지출', amount: 7000, category: '병원', fundSource: '투자'));
    final json = await BackupService(db).exportJson();

    final other = AppDatabase(NativeDatabase.memory());
    addTearDown(other.close);
    await BackupService(other).importJson(json);

    expect((await LocalEntryCategoryRepository(other).getCategories('지출')).last.name, '병원');
    final restored = await LocalTransactionRepository(other).getMonthlyTransactions(now.year, now.month);
    expect(restored.single.fundSource, '투자');
  });

  test('마이그레이션: v1 DB를 열면 기존 데이터는 그대로, fund_source 칸과 기본 카테고리가 추가됨', () async {
    final dir = await Directory.systemTemp.createTemp('moa_migration');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/moa.sqlite');

    // 1) v1 상태의 DB 파일 만들기: 지금 구조로 만든 뒤 v2에서 추가한 것을 지우고 버전을 1로
    final v1 = AppDatabase(NativeDatabase(file));
    await LocalSetup(v1).createInitial(
      categories: [(name: '생활비', includeInDaily: true, ratio: 70)],
      savingRatio: 20,
      investRatio: 10,
    );
    await LocalTransactionRepository(v1).addTransaction(tx(type: '수입', amount: 1000000, category: '월급'));
    await v1.customStatement('DROP TABLE entry_categories');
    await v1.customStatement('ALTER TABLE transactions DROP COLUMN fund_source');
    await v1.customStatement('PRAGMA user_version = 1');
    await v1.close();

    // 2) 새 앱(v2)이 같은 파일을 열면 onUpgrade 실행
    final v2 = AppDatabase(NativeDatabase(file));
    addTearDown(v2.close);
    final list = await LocalTransactionRepository(v2).getMonthlyTransactions(now.year, now.month);
    expect(list.length, 3); // 수입 + 자동 저축 + 자동 투자 그대로
    expect((await LocalEntryCategoryRepository(v2).getCategories('지출')).length, 8); // 기본 지출 카테고리

    // 새 칸도 사용 가능
    await LocalTransactionRepository(v2).addTransaction(tx(type: '지출', amount: 1000, fundSource: '저축'));
    expect((await LocalTransactionRepository(v2).getMonthlyTransactions(now.year, now.month)).length, 4);
  });
}
