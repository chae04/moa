// [역할] 로컬 DB(app_database.dart)의 테이블·제약이 의도대로 동작하는지 확인
// - 메모리 DB(NativeDatabase.memory)를 써서 테스트마다 빈 DB로 시작 → 폰·시뮬레이터 없이 맥에서 실행
// - 실행: flutter test test/local_db_test.dart

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moa/data/local/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory())); // 테스트마다 새 DB
  tearDown(() => db.close());

  // 카테고리 하나 넣고 id 돌려주기
  Future<int> addCategory(String name) => db
      .into(db.budgetCategories)
      .insert(BudgetCategoriesCompanion.insert(name: name, orderIndex: 0));

  test('카테고리: 기본값이 들어가고, 이름 10자 초과는 거절', () async {
    final id = await addCategory('생활비');
    final row = await (db.select(db.budgetCategories)..where((c) => c.id.equals(id))).getSingle();

    expect(row.showOnHome, true); // withDefault(true)
    expect(row.includeInDaily, false);
    expect(row.isDeleted, false);

    // withLength(max: 10): drift가 INSERT 전에 Dart에서 검사
    expect(() => addCategory('열한글자카테고리이름임'), throwsA(isA<InvalidDataException>()));
  });

  test('비율: 묶음을 지우면 항목도 같이 지워지고(cascade), 같은 카테고리 중복은 거절', () async {
    final cat = await addCategory('생활비');
    await db.into(db.ratioSets).insert(
      RatioSetsCompanion.insert(applyFrom: '2026-11', savingRatio: 20, investRatio: 10),
    );
    await db.into(db.ratioItems).insert(
      RatioItemsCompanion.insert(applyFrom: '2026-11', categoryId: cat, ratio: 70),
    );

    // PK(applyFrom, categoryId) 중복 → 실패
    expect(
      () => db.into(db.ratioItems).insert(
        RatioItemsCompanion.insert(applyFrom: '2026-11', categoryId: cat, ratio: 10),
      ),
      throwsA(isA<SqliteException>()),
    );

    await (db.delete(db.ratioSets)..where((s) => s.applyFrom.equals('2026-11'))).go();
    expect(await db.select(db.ratioItems).get(), isEmpty); // ON DELETE CASCADE
  });

  test('거래: 수입을 지우면 자동 거래도 DB가 같이 지움(cascade)', () async {
    final cat = await addCategory('생활비');
    final day = DateTime(2026, 11, 16);

    final incomeId = await db.into(db.transactions).insert(
      TransactionsCompanion.insert(title: '월급', amount: 2000000, type: '수입', category: '월급', date: day),
    );
    await db.into(db.transactions).insert(
      TransactionsCompanion.insert(
        title: '자동 저축',
        amount: 400000,
        type: '저축',
        category: '저축',
        date: day,
        sourceTransactionId: Value(incomeId), // 원본 수입 연결
      ),
    );
    // 직접 입력한 지출 (자동 거래 아님) → 수입을 지워도 남아야 함
    await db.into(db.transactions).insert(
      TransactionsCompanion.insert(
        title: '점심',
        amount: 9000,
        type: '지출',
        category: '식비',
        date: day,
        budgetCategoryId: Value(cat),
      ),
    );

    await (db.delete(db.transactions)..where((t) => t.id.equals(incomeId))).go();

    final left = await db.select(db.transactions).get();
    expect(left.map((t) => t.title), ['점심']); // 자동 저축은 사라지고 점심만 남음
  });

  test('외래키: 없는 카테고리를 예산 출처로 넣으면 거절 (PRAGMA foreign_keys = ON)', () async {
    expect(
      () => db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          title: '점심',
          amount: 9000,
          type: '지출',
          category: '식비',
          date: DateTime(2026, 11, 16),
          budgetCategoryId: const Value(999), // 없는 id
        ),
      ),
      throwsA(isA<SqliteException>()),
    );
  });
}
