// [역할] 폰 안에 저장하는 로컬 DB (drift = SQLite를 Dart 코드로 다루는 라이브러리)
// - 서버 MySQL 테이블(server/db/schema.sql)을 옮기되, 로그인이 없으므로 회원(users) 테이블과 user_id가 없다.
// - 테이블은 클래스로 정의하고, `dart run build_runner build`가 app_database.g.dart(실제 SQL·데이터 클래스)를 만든다.
//   → JPA 엔티티처럼 "클래스 = 테이블, getter = 칸"으로 읽으면 된다.
// - 서버와 다른 점 (로컬은 기존 데이터가 없어서 처음부터 바로잡음)
//   1) 비율: 묶음(ratio_sets) + 항목(ratio_items)으로 정규화. 서버는 저축·투자 비율을 카테고리 행마다 반복 저장함
//   2) 자동 거래: source_transaction_id에 외래키 + ON DELETE CASCADE → 수입을 지우면 DB가 자동 저축·투자를 같이 지움

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart'; // build_runner가 생성하는 파일 (직접 수정하지 않음)

// ---- 예산 카테고리 (서버 budget_categories) ----
// @DataClassName: 한 행을 담는 생성 클래스 이름. 앱의 BudgetCategoryModel과 헷갈리지 않게 Row를 붙임
@DataClassName('CategoryRow')
class BudgetCategories extends Table {
  IntColumn get id => integer().autoIncrement()(); // PK, 1부터 자동 증가
  TextColumn get name =>
      text().withLength(min: 1, max: 10)(); // 서버 CategoryRequest와 같은 10자 제한
  IntColumn get orderIndex => integer()(); // 표시 순서
  BoolColumn get includeInDaily =>
      boolean().withDefault(const Constant(false))(); // 일일 추천 예산에 포함
  BoolColumn get showOnHome =>
      boolean().withDefault(const Constant(true))(); // 홈 예산 바에 표시
  BoolColumn get isDeleted => boolean().withDefault(
    const Constant(false),
  )(); // 소프트 삭제 (지난 거래가 이 카테고리를 가리키므로 행은 남김)
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)(); // 홈 목록의 "그 달 말일까지 만들어진 카테고리" 판단용
}

// ---- 비율 묶음: 적용 시작 월 하나당 한 행 (서버는 이 값들이 budget_ratios 각 행에 반복됨) ----
@DataClassName('RatioSetRow')
class RatioSets extends Table {
  TextColumn get applyFrom =>
      text().withLength(min: 7, max: 7)(); // "2026-11" (문자열 비교로 월 순서 판단 가능)
  IntColumn get savingRatio => integer()(); // 저축 비율
  IntColumn get investRatio => integer()(); // 투자 비율

  @override
  Set<Column> get primaryKey => {applyFrom}; // 같은 월 묶음은 하나만 (다시 저장하면 교체)
}

// ---- 비율 항목: 묶음 안의 카테고리별 비율 ----
@DataClassName('RatioItemRow')
class RatioItems extends Table {
  // 묶음을 지우면 항목도 같이 지워짐 (같은 월로 다시 저장할 때 묶음째 교체하기 위해)
  TextColumn get applyFrom =>
      text().references(RatioSets, #applyFrom, onDelete: KeyAction.cascade)();
  IntColumn get categoryId => integer().references(BudgetCategories, #id)();
  IntColumn get ratio => integer()();

  @override
  Set<Column> get primaryKey => {applyFrom, categoryId}; // 한 묶음에 같은 카테고리 중복 불가
}

// ---- 거래 (서버 transactions) ----
@DataClassName('TransactionRow')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title =>
      text().withLength(min: 1, max: 10)(); // 서버 TransactionRequest와 같은 10자 제한
  IntColumn get amount => integer()(); // 원 단위 (소수 없음)
  TextColumn get type => text()(); // 수입 / 지출 / 저축 / 투자
  TextColumn get category => text()(); // 지출·수입 카테고리 이름. 저축·투자는 유형 이름. 통계는 이 문자열로 집계
  // 예산 출처: 지출·저축·투자는 필수, 수입은 null (규칙 검사는 Repository에서)
  IntColumn get budgetCategoryId =>
      integer().nullable().references(BudgetCategories, #id)();
  DateTimeColumn get date => dateTime()(); // 거래 날짜 (그날 0시로 저장)
  TextColumn get memo => text().nullable()();
  // 자동 거래면 원본 수입의 id. 원본을 지우면 DB가 이 행도 지움
  IntColumn get sourceTransactionId =>
      integer().nullable().references(Transactions, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  // (v2) 모아 둔 돈에서 꺼내 쓴 지출의 출처: '저축' 또는 '투자'. 이때 budgetCategoryId는 null
  // - 지출에서만 쓰고, 예산 카테고리 출처와 둘 중 하나만 있음 (규칙 검사는 Repository에서)
  TextColumn get fundSource => text().nullable()();
}

// ---- (v2) 수입·지출 카테고리: 거래의 "카테고리"(월급, 식비 등) 목록 ----
// - 예전에는 constants/categories.dart에 고정. 이제 사용자가 추가·이름 변경·삭제할 수 있음
// - 거래는 이 테이블의 id가 아니라 이름 문자열(transactions.category)을 저장 → 통계는 계속 문자열로 집계
//   그래서 이름을 바꾸거나 지워도 지난 거래의 카테고리 이름은 그대로 남는다.
@DataClassName('EntryCategoryRow')
class EntryCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => text()(); // '수입' 또는 '지출'
  TextColumn get name => text().withLength(min: 1, max: 10)(); // 거래 category 칸과 같은 10자 제한
  IntColumn get orderIndex => integer()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

// 처음 만들 때 넣는 기본 수입·지출 카테고리 (예전 constants/categories.dart와 같은 목록)
const defaultIncomeCategories = ['월급', '용돈', '기타'];
const defaultExpenseCategories = ['식비', '교통', '쇼핑', '구독', '취미', '고정비', '공부', '기타'];

@DriftDatabase(
  tables: [BudgetCategories, RatioSets, RatioItems, Transactions, EntryCategories],
)
class AppDatabase extends _$AppDatabase {
  // executor를 넘기면 그걸 사용 (테스트에서는 메모리 DB), 없으면 폰의 파일 DB 'moa'
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'moa'));

  // 테이블 구조를 바꿀 때마다 1씩 올리고 migration에 변경 SQL을 추가 (서버의 ddl-auto=validate + schema.sql 역할)
  // 버전 기록
  // 1: 카테고리, 비율(묶음/항목), 거래
  // 2: 거래.fund_source(저축·투자에서 꺼내 쓴 지출), entry_categories(수입·지출 카테고리 관리)
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // 앱을 처음 설치했을 때: 모든 테이블 생성 + 기본 수입·지출 카테고리
    onCreate: (m) async {
      await m.createAll();
      await _seedEntryCategories();
    },
    // 이미 이전 버전 DB가 있는 폰: 바뀐 부분만 추가 (기존 데이터는 그대로)
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(transactions, transactions.fundSource);
        await m.createTable(entryCategories);
        await _seedEntryCategories();
      }
    },
    // SQLite는 외래키 검사가 기본으로 꺼져 있음 → 연결할 때마다 켜야 references·cascade가 동작
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _seedEntryCategories() async {
    Future<void> seed(String kind, List<String> names) async {
      for (var i = 0; i < names.length; i++) {
        await into(entryCategories).insert(
          EntryCategoriesCompanion.insert(kind: kind, name: names[i], orderIndex: i),
        );
      }
    }

    await seed('수입', defaultIncomeCategories);
    await seed('지출', defaultExpenseCategories);
  }

  // ---- 여러 Repository가 같이 쓰는 조회 ----

  // month("2026-11") 이하에서 가장 최근 적용 월. 비율을 저장한 적이 없으면 null
  // (서버 BudgetRatioRepository.findLatestApplyFrom과 같은 쿼리: SELECT MAX(apply_from) ... WHERE apply_from <= ?)
  Future<String?> latestApplyFrom(String month) {
    final maxApplyFrom = ratioSets.applyFrom.max();
    final query = selectOnly(ratioSets)
      ..addColumns([maxApplyFrom])
      ..where(
        ratioSets.applyFrom.isSmallerOrEqualValue(month),
      ); // "YYYY-MM"은 문자열 비교 = 월 순서 비교
    return query.map((row) => row.read(maxApplyFrom)).getSingle();
  }
}

// ---- 날짜 도우미 (서버의 YearMonth 역할) ----

// DateTime → "2026-11"
String monthOf(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';

// 이번 달 "2026-11" (기기 시간 기준. 서버는 Asia/Seoul로 고정했지만 폰은 사용자가 있는 곳의 시간)
String currentMonth() => monthOf(DateTime.now());

// 날짜에서 시간을 버리고 그날 0시로 (거래 날짜는 "날짜"만 의미가 있음)
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
