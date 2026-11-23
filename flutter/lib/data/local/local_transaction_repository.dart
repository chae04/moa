// [역할] 거래의 로컬 구현 (서버 TransactionService를 Dart로 옮김)
// - 수입을 저장하면 그 달 비율대로 저축·투자 자동 거래를 만든다 (sourceTransactionId로 연결)
// - 수입을 지우면 자동 거래도 같이 지워진다 (DB 외래키 ON DELETE CASCADE)
// - 수정 규칙: 자동 거래 수정 불가, 유형 변경 불가, 수입 금액 변경 불가, 수입 날짜를 바꾸면 자동 거래도 같은 날짜로
// - 저축·투자의 category는 유형 이름으로 고정, 예산 출처는 지출·저축·투자에서 필수, 수입은 없음
// - (로컬 전용) 지출은 예산 카테고리 대신 저축·투자를 출처로 고를 수 있음 = 모아 둔 돈에서 꺼내 쓰기

import 'package:drift/drift.dart';
import 'package:moa/data/app_exception.dart';
import 'package:moa/data/local/app_database.dart';
import 'package:moa/data/repositories.dart';
import 'package:moa/models/transaction_model.dart';

class LocalTransactionRepository implements TransactionRepository {
  static const income = '수입';
  static const expense = '지출';
  static const saving = '저축';
  static const invest = '투자';
  static const _types = {income, expense, saving, invest};

  final AppDatabase _db;
  LocalTransactionRepository(this._db);

  @override
  Future<List<TransactionModel>> getMonthlyTransactions(int year, int month) async {
    _validateYearMonth(year, month);
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1); // 다음 달 1일 (13월이면 Dart가 다음 해 1월로 처리)

    // 출처 카테고리 이름도 같이 (삭제된 카테고리여도 이름이 나오게 LEFT JOIN, 서버 LEFT JOIN FETCH와 같음)
    final query =
        _db.select(_db.transactions).join([
            leftOuterJoin(
              _db.budgetCategories,
              _db.budgetCategories.id.equalsExp(_db.transactions.budgetCategoryId),
            ),
          ])
          ..where(
            _db.transactions.date.isBiggerOrEqualValue(start) &
                _db.transactions.date.isSmallerThanValue(end),
          )
          ..orderBy([
            OrderingTerm.desc(_db.transactions.date),
            OrderingTerm.desc(_db.transactions.id),
          ]);

    final rows = await query.get();
    return rows.map((row) {
      final t = row.readTable(_db.transactions);
      final category = row.readTableOrNull(_db.budgetCategories);
      return TransactionModel(
        id: t.id,
        title: t.title,
        amount: t.amount,
        type: t.type,
        category: t.category,
        budgetCategoryId: t.budgetCategoryId,
        budgetCategoryName: category?.name,
        date: t.date,
        memo: t.memo,
        sourceTransactionId: t.sourceTransactionId,
        fundSource: t.fundSource,
      );
    }).toList();
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    _validateBasic(transaction);
    final fields = await _applyTypeRules(transaction, current: null);

    // 수입 + 자동 거래를 하나로 묶음: 자동 거래 생성이 실패하면 수입도 저장 안 됨 (서버 @Transactional)
    await _db.transaction(() async {
      final id = await _db
          .into(_db.transactions)
          .insert(
            TransactionsCompanion.insert(
              title: transaction.title.trim(),
              amount: transaction.amount,
              type: transaction.type,
              category: fields.category,
              budgetCategoryId: Value(fields.budgetCategoryId),
              fundSource: Value(fields.fundSource),
              date: dateOnly(transaction.date),
              memo: Value(transaction.memo),
            ),
          );
      if (transaction.type == income) {
        await _createAutoTransactions(id, transaction.amount, dateOnly(transaction.date));
      }
    });
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    final current = await _find(transaction.id);

    if (current.sourceTransactionId != null) {
      throw const AppException('자동 생성된 거래는 수정할 수 없습니다.');
    }
    if (current.type != transaction.type) {
      throw const AppException('기존 거래 유형 변경은 불가합니다.');
    }
    if (current.type == income && current.amount != transaction.amount) {
      throw const AppException('수입 금액 수정은 불가합니다.');
    }
    _validateBasic(transaction);
    final fields = await _applyTypeRules(transaction, current: current);
    final newDate = dateOnly(transaction.date);

    await _db.transaction(() async {
      await (_db.update(_db.transactions)..where((t) => t.id.equals(current.id))).write(
        TransactionsCompanion(
          title: Value(transaction.title.trim()),
          amount: Value(transaction.amount),
          category: Value(fields.category),
          budgetCategoryId: Value(fields.budgetCategoryId),
          fundSource: Value(fields.fundSource),
          date: Value(newDate),
          memo: Value(transaction.memo),
          updatedAt: Value(DateTime.now()),
        ),
      );
      // 수입 날짜가 바뀌면 자동 거래도 같은 날짜로 이동
      if (current.type == income) {
        await (_db.update(_db.transactions)
              ..where((t) => t.sourceTransactionId.equals(current.id)))
            .write(TransactionsCompanion(date: Value(newDate)));
      }
    });
  }

  @override
  Future<void> deleteTransaction(int id) async {
    await _find(id);
    // 수입이면 자동 거래는 DB가 같이 지움 (source_transaction_id ON DELETE CASCADE)
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }

  // ---- 내부 도우미 ----

  void _validateYearMonth(int year, int month) {
    if (year < 2000 || year > 2100 || month < 1 || month > 12) {
      throw const AppException('조회할 연도와 월이 올바르지 않습니다.');
    }
  }

  // 서버 TransactionRequest의 검증 어노테이션과 같은 규칙
  void _validateBasic(TransactionModel t) {
    final title = t.title.trim();
    if (title.isEmpty) throw const AppException('거래명을 입력해주세요.');
    if (title.length > 10) throw const AppException('거래명이 너무 깁니다.');
    if (t.amount <= 0) throw const AppException('금액은 0보다 커야 합니다.');
    if (!_types.contains(t.type)) {
      throw const AppException('거래 유형은 수입, 지출, 저축, 투자 중 하나여야 합니다.');
    }
    if ((t.memo ?? '').length > 255) throw const AppException('메모가 너무 깁니다.');
  }

  // 유형별 규칙에 맞는 category, budgetCategoryId, fundSource 정하기 (서버 applyRequest + 로컬 전용 출처)
  Future<({String category, int? budgetCategoryId, String? fundSource})> _applyTypeRules(
    TransactionModel t, {
    required TransactionRow? current,
  }) async {
    final String category;
    if (t.type == saving || t.type == invest) {
      category = t.type; // 저축·투자는 유형 이름으로 고정
    } else {
      if (t.category.trim().isEmpty) throw const AppException('카테고리를 입력해주세요.');
      if (t.category.length > 10) throw const AppException('카테고리가 너무 깁니다.');
      category = t.category;
    }

    if (t.type == income) {
      return (category: category, budgetCategoryId: null, fundSource: null); // 수입은 출처 없음
    }

    // 모아 둔 돈(저축·투자)에서 꺼내 쓴 지출: 예산 카테고리 대신 fundSource
    final fundSource = t.fundSource;
    if (fundSource != null) {
      if (t.type != expense) {
        throw const AppException('저축·투자에서 꺼내 쓰기는 지출에서만 선택할 수 있어요.');
      }
      if (fundSource != saving && fundSource != invest) {
        throw const AppException('출처는 저축 또는 투자여야 합니다.');
      }
      return (category: category, budgetCategoryId: null, fundSource: fundSource);
    }

    final budgetCategoryId = t.budgetCategoryId;
    if (budgetCategoryId == null) throw const AppException('예산 카테고리를 선택해주세요.');

    // 출처를 안 바꿨으면 삭제된 카테고리여도 그대로 유지 (지난 거래를 고칠 때 출처가 사라지지 않게)
    if (current != null && current.budgetCategoryId == budgetCategoryId) {
      return (category: category, budgetCategoryId: budgetCategoryId, fundSource: null);
    }
    final active =
        await (_db.select(_db.budgetCategories)
              ..where((c) => c.id.equals(budgetCategoryId) & c.isDeleted.equals(false)))
            .getSingleOrNull();
    if (active == null) throw const AppException('카테고리를 찾을 수 없습니다.');
    return (category: category, budgetCategoryId: budgetCategoryId, fundSource: null);
  }

  Future<TransactionRow> _find(int id) async {
    final row = await (_db.select(
      _db.transactions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) throw const AppException('거래를 찾을 수 없습니다.');
    return row;
  }

  // 수입의 그 달 비율대로 저축·투자 자동 거래 생성 (비율을 저장한 적이 없으면 만들지 않음)
  Future<void> _createAutoTransactions(int incomeId, int amount, DateTime date) async {
    final applyFrom = await _db.latestApplyFrom(monthOf(date));
    if (applyFrom == null) return;

    final set = await (_db.select(
      _db.ratioSets,
    )..where((s) => s.applyFrom.equals(applyFrom))).getSingle();
    await _createAuto(incomeId, amount, date, saving, set.savingRatio);
    await _createAuto(incomeId, amount, date, invest, set.investRatio);
  }

  Future<void> _createAuto(
    int incomeId,
    int incomeAmount,
    DateTime date,
    String type,
    int ratio,
  ) async {
    final amount = (incomeAmount * ratio / 100).round(); // 반올림 (서버 Math.round와 같음)
    if (amount <= 0) return; // 비율이 0이거나 반올림하면 0원

    await _db
        .into(_db.transactions)
        .insert(
          TransactionsCompanion.insert(
            title: '자동 $type',
            amount: amount,
            type: type,
            category: type,
            date: date,
            memo: Value('수입의 $ratio% 자동 $type'),
            sourceTransactionId: Value(incomeId),
          ),
        );
  }
}
