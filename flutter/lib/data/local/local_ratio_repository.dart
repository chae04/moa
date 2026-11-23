// [역할] 예산 비율의 로컬 구현 (서버 BudgetRatioService를 Dart로 옮김)
// - 비율은 "적용 시작 월" 단위 묶음. 어떤 달의 비율 = 그 달 이하에서 가장 최근 묶음
// - 규칙(서버와 같음): 카테고리 + 저축 + 투자 = 100, 각 비율 0~100, 지난 달은 변경 불가, 같은 카테고리 중복 불가
// - 로컬 DB는 묶음(ratio_sets) + 항목(ratio_items)으로 정규화되어 있어서, 저축·투자 비율은 묶음에 한 번만 저장된다.

import 'package:drift/drift.dart';
import 'package:moa/data/app_exception.dart';
import 'package:moa/data/local/app_database.dart';
import 'package:moa/data/repositories.dart';
import 'package:moa/models/budget_model.dart';

class LocalRatioRepository implements RatioRepository {
  static final RegExp _monthFormat = RegExp(
    r'^\d{4}-(0[1-9]|1[0-2])$',
  ); // 서버 MONTH_FORMAT

  final AppDatabase _db;
  LocalRatioRepository(this._db);

  @override
  Future<BudgetModel> getRatios(String month) async {
    if (!_monthFormat.hasMatch(month)) {
      throw const AppException('조회 월은 YYYY-MM 형식이어야 합니다.');
    }
    final applyFrom = await _db.latestApplyFrom(month);
    if (applyFrom == null) {
      // 비율을 저장한 적이 없음 → 서버처럼 빈 묶음 (화면은 applyFrom == null로 판단)
      return BudgetModel(applyFrom: null, savingRatio: 0, investRatio: 0, categories: []);
    }
    return _load(applyFrom);
  }

  @override
  Future<BudgetModel> saveRatios(BudgetModel budget) async {
    final applyFrom = budget.applyFrom;
    if (applyFrom == null || !_monthFormat.hasMatch(applyFrom)) {
      throw const AppException('적용 시작 월은 YYYY-MM 형식이어야 합니다.');
    }
    if (applyFrom.compareTo(currentMonth()) < 0) {
      throw const AppException('지난 달의 비율은 변경할 수 없습니다.');
    }
    if (budget.categories.isEmpty) {
      throw const AppException('카테고리 비율을 입력해주세요.');
    }
    for (final r in [
      budget.savingRatio,
      budget.investRatio,
      ...budget.categories.map((c) => c.ratio),
    ]) {
      if (r < 0) throw const AppException('비율은 0 이상이어야 합니다.');
      if (r > 100) throw const AppException('비율은 100 이하여야 합니다.');
    }

    final total =
        budget.categories.fold(0, (sum, c) => sum + c.ratio) +
        budget.savingRatio +
        budget.investRatio;
    if (total != 100) {
      throw AppException('비율 합계는 100이어야 합니다. 현재: $total');
    }

    final ids = budget.categories.map((c) => c.categoryId).toList();
    if (ids.toSet().length != ids.length) {
      throw const AppException('같은 카테고리를 중복해서 보낼 수 없습니다.');
    }

    // 모두 활성 카테고리인지 (삭제됐거나 없는 카테고리면 실패)
    final activeIds = await (_db.select(
      _db.budgetCategories,
    )..where((c) => c.id.isIn(ids) & c.isDeleted.equals(false))).map((c) => c.id).get();
    if (activeIds.length != ids.length) {
      throw const AppException('카테고리를 찾을 수 없습니다.');
    }

    // 같은 월 묶음 교체: 지우고(항목은 CASCADE로 같이 삭제) 다시 넣기. 중간에 실패하면 전부 되돌림
    await _db.transaction(() async {
      await (_db.delete(_db.ratioSets)..where((s) => s.applyFrom.equals(applyFrom))).go();
      await _db
          .into(_db.ratioSets)
          .insert(
            RatioSetsCompanion.insert(
              applyFrom: applyFrom,
              savingRatio: budget.savingRatio,
              investRatio: budget.investRatio,
            ),
          );
      for (final c in budget.categories) {
        await _db
            .into(_db.ratioItems)
            .insert(
              RatioItemsCompanion.insert(
                applyFrom: applyFrom,
                categoryId: c.categoryId,
                ratio: c.ratio,
              ),
            );
      }
    });
    return _load(applyFrom);
  }

  // 묶음 하나 읽기 (항목은 카테고리 표시 순서대로)
  Future<BudgetModel> _load(String applyFrom) async {
    final set = await (_db.select(
      _db.ratioSets,
    )..where((s) => s.applyFrom.equals(applyFrom))).getSingle();

    final query =
        _db.select(_db.ratioItems).join([
            innerJoin(
              _db.budgetCategories,
              _db.budgetCategories.id.equalsExp(_db.ratioItems.categoryId),
            ),
          ])
          ..where(_db.ratioItems.applyFrom.equals(applyFrom))
          ..orderBy([OrderingTerm.asc(_db.budgetCategories.orderIndex)]);
    final rows = await query.get();

    final categories = <CategoryRatio>[];
    for (final row in rows) {
      final item = row.readTable(_db.ratioItems);
      final category = row.readTable(_db.budgetCategories);
      // 삭제됐고 비율도 0인 카테고리는 보여 줄 의미가 없음 (서버 toResponse와 같은 필터)
      if (category.isDeleted && item.ratio == 0) continue;
      categories.add(
        CategoryRatio(categoryId: category.id, name: category.name, ratio: item.ratio),
      );
    }

    return BudgetModel(
      applyFrom: set.applyFrom,
      savingRatio: set.savingRatio,
      investRatio: set.investRatio,
      categories: categories,
    );
  }
}
