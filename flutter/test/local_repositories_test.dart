// [역할] 로컬 Repository가 서버와 같은 규칙을 지키는지 확인 (서버 Service의 규칙을 하나씩 옮겨 검사)
// - 메모리 DB로 테스트마다 새로 시작. 실행: flutter test test/local_repositories_test.dart

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moa/data/app_exception.dart';
import 'package:moa/data/local/app_database.dart';
import 'package:moa/data/local/backup_service.dart';
import 'package:moa/data/local/local_category_repository.dart';
import 'package:moa/data/local/local_home_repository.dart';
import 'package:moa/data/local/local_ratio_repository.dart';
import 'package:moa/data/local/local_setup.dart';
import 'package:moa/data/local/local_transaction_repository.dart';
import 'package:moa/models/budget_model.dart';
import 'package:moa/models/transaction_model.dart';

// AppException의 message까지 확인하는 matcher
// 비동기 함수의 에러는 await expectLater(...)로 검사해야 다음 줄이 검사가 끝난 뒤에 실행됨
Matcher throwsAppException(String message) =>
    throwsA(isA<AppException>().having((e) => e.message, 'message', message));

void main() {
  late AppDatabase db;
  late LocalCategoryRepository categories;
  late LocalRatioRepository ratios;
  late LocalTransactionRepository transactions;
  late LocalHomeRepository home;
  late LocalSetup setup;

  final now = DateTime.now();
  final thisMonth = monthOf(now);
  final today = DateTime(now.year, now.month, now.day);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    categories = LocalCategoryRepository(db);
    ratios = LocalRatioRepository(db);
    transactions = LocalTransactionRepository(db);
    home = LocalHomeRepository(db, transactions);
    setup = LocalSetup(db);
  });
  tearDown(() => db.close());

  // 첫 실행 설정: 생활비 50(일일), 자유비 20, 저축 20, 투자 10
  Future<void> setUpDefault() => setup.createInitial(
    categories: [
      (name: '생활비', includeInDaily: true, ratio: 50),
      (name: '자유비', includeInDaily: false, ratio: 20),
    ],
    savingRatio: 20,
    investRatio: 10,
  );

  Future<int> categoryId(String name) async =>
      (await categories.getCategories()).firstWhere((c) => c.name == name).id;

  TransactionModel tx({
    int id = 0,
    required String type,
    required int amount,
    String title = '거래',
    String category = '식비',
    int? budgetCategoryId,
    DateTime? date,
  }) => TransactionModel(
    id: id,
    title: title,
    amount: amount,
    type: type,
    category: category,
    budgetCategoryId: budgetCategoryId,
    date: date ?? today,
  );

  group('첫 실행 설정', () {
    test('카테고리와 이번 달 비율이 한 번에 저장됨', () async {
      expect(await setup.isSetUp(), false);
      await setUpDefault();
      expect(await setup.isSetUp(), true);

      final budget = await ratios.getRatios(thisMonth);
      expect(budget.applyFrom, thisMonth);
      expect(budget.savingRatio, 20);
      expect(budget.categories.map((c) => '${c.name}:${c.ratio}'), ['생활비:50', '자유비:20']);
    });

    test('합계가 100이 아니면 아무것도 저장 안 됨', () async {
      await expectLater(() => setup.createInitial(
          categories: [(name: '생활비', includeInDaily: true, ratio: 50)],
          savingRatio: 20,
          investRatio: 10,
        ),
        throwsAppException('비율 합계는 100이어야 합니다. 현재: 80'),
      );
      expect(await setup.isSetUp(), false);
    });
  });

  group('카테고리', () {
    test('홈 표시는 최대 5개', () async {
      for (var i = 1; i <= 5; i++) {
        await categories.addCategory(name: '카테$i', showOnHome: true);
      }
      await expectLater(() => categories.addCategory(name: '카테6', showOnHome: true),
        throwsAppException('홈 표시는 최대 5개까지 가능합니다.'),
      );
      await categories.addCategory(name: '카테6', showOnHome: false); // 홈 표시 안 하면 추가 가능
      expect((await categories.getCategories()).last.orderIndex, 5); // 순서는 맨 뒤
    });

    test('최소 1개 유지, 이번 달 비율에 남아 있으면 삭제 불가, 비율을 0으로 바꾸면 삭제 가능', () async {
      await setUpDefault();
      final free = await categoryId('자유비');

      await expectLater(() => categories.deleteCategory(free), throwsAppException('해당 카테고리에 남아있는 비율을 먼저 조정해야합니다.'));

      final living = await categoryId('생활비');
      await ratios.saveRatios(BudgetModel(
        applyFrom: thisMonth,
        savingRatio: 20,
        investRatio: 10,
        categories: [CategoryRatio(categoryId: living, name: '생활비', ratio: 70)],
      ));
      await categories.deleteCategory(free);
      expect((await categories.getCategories()).map((c) => c.name), ['생활비']);

      await expectLater(() => categories.deleteCategory(living), throwsAppException('카테고리는 최소 1개 존재해야 합니다.'));
    });

    test('순서 바꾸기: 목록·비율 순서에 반영, 목록과 다른 id는 거절', () async {
      await setUpDefault(); // 생활비, 자유비
      await categories.addCategory(name: '교통비', showOnHome: true);
      final ids = (await categories.getCategories()).map((c) => c.id).toList();

      await categories.reorderCategories([ids[2], ids[0], ids[1]]); // 교통비를 맨 앞으로
      expect((await categories.getCategories()).map((c) => c.name), ['교통비', '생활비', '자유비']);
      // 비율 묶음도 카테고리 표시 순서를 따름
      expect((await ratios.getRatios(thisMonth)).categories.map((c) => c.name), ['생활비', '자유비']);

      await expectLater(
        () => categories.reorderCategories([ids[0], ids[1]]), // 하나 빠짐
        throwsAppException('카테고리 목록이 바뀌었어요. 화면을 새로고침한 뒤 다시 시도해주세요.'),
      );
      await expectLater(
        () => categories.reorderCategories([ids[0], ids[0], ids[1]]), // 중복
        throwsAppException('카테고리 목록이 바뀌었어요. 화면을 새로고침한 뒤 다시 시도해주세요.'),
      );
    });

    test('이름은 1~10자', () async {
      await expectLater(() => categories.addCategory(name: '  ', showOnHome: false), throwsAppException('카테고리 이름을 입력해주세요.'));
      await expectLater(() => categories.addCategory(name: '열한글자카테고리이름임', showOnHome: false),
        throwsAppException('카테고리 이름은 10자 이내로 입력해주세요.'),
      );
    });
  });

  group('비율', () {
    test('합계 100, 지난 달 변경 불가, 중복 불가', () async {
      await setUpDefault();
      final living = await categoryId('생활비');
      BudgetModel budget(String month, List<int> ids, {int saving = 20}) => BudgetModel(
        applyFrom: month,
        savingRatio: saving,
        investRatio: 10,
        categories: ids.map((id) => CategoryRatio(categoryId: id, name: '', ratio: 35)).toList(),
      );

      await expectLater(() => ratios.saveRatios(budget(thisMonth, [living])), throwsAppException('비율 합계는 100이어야 합니다. 현재: 65'));
      await expectLater(() => ratios.saveRatios(budget(thisMonth, [living, living])), throwsAppException('같은 카테고리를 중복해서 보낼 수 없습니다.'));
      await expectLater(() => ratios.saveRatios(budget('2000-01', [living])), throwsAppException('지난 달의 비율은 변경할 수 없습니다.'));
    });

    test('다음 달 묶음을 저장하면 이번 달은 그대로, 다음 달부터 새 비율', () async {
      await setUpDefault();
      final living = await categoryId('생활비');
      final nextMonth = monthOf(DateTime(now.year, now.month + 1));
      final later = monthOf(DateTime(now.year, now.month + 3));

      await ratios.saveRatios(BudgetModel(
        applyFrom: nextMonth,
        savingRatio: 30,
        investRatio: 0,
        categories: [CategoryRatio(categoryId: living, name: '생활비', ratio: 70)],
      ));

      expect((await ratios.getRatios(thisMonth)).savingRatio, 20); // 이번 달은 기존 묶음
      expect((await ratios.getRatios(later)).applyFrom, nextMonth); // 이후 달은 가장 최근 묶음
      expect((await ratios.getRatios('2000-01')).applyFrom, isNull); // 저장 전 달은 빈 묶음
    });
  });

  group('거래', () {
    test('수입을 넣으면 저축·투자 자동 거래가 생기고, 수입을 지우면 같이 사라짐', () async {
      await setUpDefault();
      await transactions.addTransaction(tx(type: '수입', amount: 2000001, title: '월급', category: '월급'));

      var list = await transactions.getMonthlyTransactions(now.year, now.month);
      final autos = list.where((t) => t.isAuto).toList();
      expect(autos.map((t) => '${t.type}:${t.amount}').toSet(), {'저축:400000', '투자:200000'}); // 반올림
      expect(autos.first.memo, contains('자동'));

      final incomeId = list.firstWhere((t) => t.type == '수입').id;
      await transactions.deleteTransaction(incomeId);
      list = await transactions.getMonthlyTransactions(now.year, now.month);
      expect(list, isEmpty);
    });

    test('수정 규칙: 자동 거래·유형 변경·수입 금액 변경 불가, 수입 날짜를 옮기면 자동 거래도 이동', () async {
      await setUpDefault();
      await transactions.addTransaction(tx(type: '수입', amount: 1000000, title: '월급', category: '월급'));
      final list = await transactions.getMonthlyTransactions(now.year, now.month);
      final income = list.firstWhere((t) => t.type == '수입');
      final auto = list.firstWhere((t) => t.isAuto);

      await expectLater(() => transactions.updateTransaction(auto), throwsAppException('자동 생성된 거래는 수정할 수 없습니다.'));
      await expectLater(() => transactions.updateTransaction(tx(id: income.id, type: '지출', amount: 1000000, budgetCategoryId: 1)),
        throwsAppException('기존 거래 유형 변경은 불가합니다.'),
      );
      await expectLater(() => transactions.updateTransaction(tx(id: income.id, type: '수입', amount: 5, category: '월급')),
        throwsAppException('수입 금액 수정은 불가합니다.'),
      );

      // 같은 달 안에서 날짜 이동 (1일 ↔ 2일)
      final moved = DateTime(now.year, now.month, today.day == 1 ? 2 : 1);
      await transactions.updateTransaction(tx(id: income.id, type: '수입', amount: 1000000, category: '월급', date: moved));
      final after = await transactions.getMonthlyTransactions(now.year, now.month);
      expect(after.every((t) => t.date == moved), true);
    });

    test('지출·저축·투자는 예산 출처 필수, 저축의 category는 유형 이름으로 고정', () async {
      await setUpDefault();
      await expectLater(() => transactions.addTransaction(tx(type: '지출', amount: 1000)), throwsAppException('예산 카테고리를 선택해주세요.'));

      final free = await categoryId('자유비');
      await transactions.addTransaction(tx(type: '저축', amount: 5000, category: '아무거나', budgetCategoryId: free));
      final saved = (await transactions.getMonthlyTransactions(now.year, now.month)).single;
      expect(saved.category, '저축');
      expect(saved.budgetCategoryName, '자유비');
    });

    test('기본 검증: 거래명 10자, 금액 0 초과', () async {
      await setUpDefault();
      await expectLater(() => transactions.addTransaction(tx(type: '수입', amount: 0, category: '월급')),
        throwsAppException('금액은 0보다 커야 합니다.'),
      );
      await expectLater(() => transactions.addTransaction(tx(type: '수입', amount: 10, title: '열한글자거래이름입니다', category: '월급')),
        throwsAppException('거래명이 너무 깁니다.'),
      );
    });
  });

  group('홈', () {
    test('합계, 예산 = 수입 × 비율, 사용액은 자동 거래 제외, 날짜별 지출', () async {
      await setUpDefault();
      final living = await categoryId('생활비');
      final free = await categoryId('자유비');

      await transactions.addTransaction(tx(type: '수입', amount: 1000000, title: '월급', category: '월급'));
      await transactions.addTransaction(tx(type: '지출', amount: 30000, budgetCategoryId: living));
      await transactions.addTransaction(tx(type: '투자', amount: 10000, budgetCategoryId: free)); // 직접 입력 투자

      final h = await home.getHome(now.year, now.month);
      expect(h.totalIncome, 1000000);
      expect(h.totalExpense, 30000);
      expect(h.totalSaving, 200000); // 자동 저축
      expect(h.totalInvest, 110000); // 자동 투자 100000 + 직접 10000

      final livingSummary = h.categories.firstWhere((c) => c.name == '생활비');
      expect(livingSummary.budget, 500000); // 1,000,000 × 50%
      expect(livingSummary.used, 30000);
      expect(livingSummary.remaining, 470000);
      expect(h.categories.firstWhere((c) => c.name == '자유비').used, 10000); // 직접 입력 투자는 출처 사용액에 포함

      expect(h.dailyExpenses.single.amount, 30000);
      expect(h.dailyBudget, isNotNull); // 이번 달은 계산됨
    });

    test('지난달은 일일 추천 예산 없음, 비율이 없으면 없음', () async {
      expect((await home.getHome(now.year, now.month)).dailyBudget, isNull); // 비율 없음
      await setUpDefault();
      final lastMonth = DateTime(now.year, now.month - 1);
      expect((await home.getHome(lastMonth.year, lastMonth.month)).dailyBudget, isNull);
    });
  });

  test('백업: 내보낸 JSON으로 되살리면 id와 자동 거래 연결이 그대로', () async {
    await setUpDefault();
    await transactions.addTransaction(tx(type: '수입', amount: 1000000, title: '월급', category: '월급'));
    final backup = BackupService(db);
    final json = await backup.exportJson();

    // 다른 폰(빈 DB)에서 가져오기
    final other = AppDatabase(NativeDatabase.memory());
    addTearDown(other.close);
    await BackupService(other).importJson(json);

    final restored = await LocalTransactionRepository(other).getMonthlyTransactions(now.year, now.month);
    final income = restored.firstWhere((t) => t.type == '수입');
    expect(restored.where((t) => t.sourceTransactionId == income.id).length, 2);
    expect((await LocalRatioRepository(other).getRatios(thisMonth)).savingRatio, 20);

    // 가져온 뒤에도 규칙(CASCADE)이 동작
    await LocalTransactionRepository(other).deleteTransaction(income.id);
    expect(await LocalTransactionRepository(other).getMonthlyTransactions(now.year, now.month), isEmpty);

    await expectLater(() => backup.importJson('{"app":"other"}'), throwsAppException('Moa 백업 파일이 아니에요.'));
    await expectLater(() => backup.importJson('깨진 파일'), throwsAppException('백업 파일을 읽을 수 없어요.'));
  });
}
