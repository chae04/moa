// [역할] 예산 카테고리의 로컬 구현 (서버 BudgetCategoryService를 Dart로 옮김)
// - 규칙(서버와 같음): 이름 1~10자, 홈 표시 최대 5개, 최소 1개 유지, 현재·이후 비율에 남아 있으면 삭제 불가
// - (로컬 전용) 표시 순서 바꾸기: 홈 카드·비율 설정·예산 드롭다운이 모두 이 순서를 따름
// - 삭제는 소프트 삭제(isDeleted = true): 지난 거래가 이 카테고리를 출처로 가리키고 있어서 행은 남긴다.
// - 규칙을 어기면 AppException(서버와 같은 한글 문구)을 던진다.

import 'package:drift/drift.dart';
import 'package:moa/data/app_exception.dart';
import 'package:moa/data/local/app_database.dart';
import 'package:moa/data/repositories.dart';
import 'package:moa/models/budget_category_model.dart';

class LocalCategoryRepository implements CategoryRepository {
  static const int maxShowOnHome = 5; // 서버 MAX_SHOW_ON_HOME

  final AppDatabase _db;
  LocalCategoryRepository(this._db);

  @override
  Future<List<BudgetCategoryModel>> getCategories() async {
    final rows =
        await (_db.select(_db.budgetCategories)
              ..where((c) => c.isDeleted.equals(false)) // 삭제 제외
              ..orderBy([(c) => OrderingTerm.asc(c.orderIndex)])) // 표시 순서대로
            .get();
    return rows.map(toModel).toList();
  }

  @override
  Future<void> addCategory({
    required String name,
    required bool showOnHome,
    bool includeInDaily = false,
  }) async {
    final trimmed = _validateName(name);
    if (showOnHome && await _countShownOnHome() >= maxShowOnHome) {
      throw const AppException('홈 표시는 최대 5개까지 가능합니다.');
    }

    // 순서는 맨 뒤 (삭제된 카테고리까지 포함한 최댓값 + 1, 서버 findMaxOrderIndex와 같음)
    final maxOrder = _db.budgetCategories.orderIndex.max();
    final currentMax = await (_db.selectOnly(
      _db.budgetCategories,
    )..addColumns([maxOrder])).map((row) => row.read(maxOrder)).getSingle();

    await _db
        .into(_db.budgetCategories)
        .insert(
          BudgetCategoriesCompanion.insert(
            name: trimmed,
            orderIndex: (currentMax ?? -1) + 1, // 첫 카테고리면 0
            showOnHome: Value(showOnHome),
            includeInDaily: Value(includeInDaily),
          ),
        );
  }

  @override
  Future<void> updateCategory(BudgetCategoryModel category) async {
    final current = await _findActive(category.id);
    final trimmed = _validateName(category.name);

    // 홈 표시를 새로 켤 때만 개수 검사 (이미 켜져 있던 카테고리는 그대로 통과)
    if (category.showOnHome &&
        !current.showOnHome &&
        await _countShownOnHome() >= maxShowOnHome) {
      throw const AppException('홈 표시는 최대 5개까지 가능합니다.');
    }

    await (_db.update(
      _db.budgetCategories,
    )..where((c) => c.id.equals(category.id))).write(
      BudgetCategoriesCompanion(
        name: Value(trimmed),
        showOnHome: Value(category.showOnHome),
        includeInDaily: Value(category.includeInDaily),
      ),
    );
  }

  @override
  Future<void> deleteCategory(int id) async {
    await _findActive(id);

    final activeCount = await _countActive();
    if (activeCount <= 1) {
      throw const AppException('카테고리는 최소 1개 존재해야 합니다.');
    }
    if (await _isInUse(id)) {
      throw const AppException('해당 카테고리에 남아있는 비율을 먼저 조정해야합니다.');
    }

    await (_db.update(_db.budgetCategories)..where((c) => c.id.equals(id))).write(
      const BudgetCategoriesCompanion(isDeleted: Value(true)),
    );
  }

  @override
  bool get canReorder => true;

  @override
  Future<void> reorderCategories(List<int> orderedIds) async {
    // 지금 활성 카테고리와 정확히 같은 id들인지 (빠지거나 중복되거나 삭제된 것이 섞이면 거절)
    final activeIds = (await getCategories()).map((c) => c.id).toSet();
    if (orderedIds.length != activeIds.length || !orderedIds.toSet().containsAll(activeIds)) {
      throw const AppException('카테고리 목록이 바뀌었어요. 화면을 새로고침한 뒤 다시 시도해주세요.');
    }
    // 하나의 트랜잭션: 중간에 실패하면 원래 순서 그대로
    await _db.transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (_db.update(_db.budgetCategories)..where((c) => c.id.equals(orderedIds[i])))
            .write(BudgetCategoriesCompanion(orderIndex: Value(i)));
      }
    });
  }

  // ---- 내부 도우미 ----

  // DB 행 → 화면이 쓰는 모델 (서버 CategoryResponse와 같은 모양)
  static BudgetCategoryModel toModel(CategoryRow row) => BudgetCategoryModel(
    id: row.id,
    name: row.name,
    orderIndex: row.orderIndex,
    includeInDaily: row.includeInDaily,
    showOnHome: row.showOnHome,
  );

  // 이름 검사 (서버 CategoryRequest의 @NotBlank, @Size(max = 10))
  String _validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw const AppException('카테고리 이름을 입력해주세요.');
    if (trimmed.length > 10) throw const AppException('카테고리 이름은 10자 이내로 입력해주세요.');
    return trimmed;
  }

  Future<CategoryRow> _findActive(int id) async {
    final row = await (_db.select(
      _db.budgetCategories,
    )..where((c) => c.id.equals(id) & c.isDeleted.equals(false))).getSingleOrNull();
    if (row == null) throw const AppException('카테고리를 찾을 수 없습니다.');
    return row;
  }

  Future<int> _countActive() => _count(_db.budgetCategories.isDeleted.equals(false));

  Future<int> _countShownOnHome() => _count(
    _db.budgetCategories.isDeleted.equals(false) &
        _db.budgetCategories.showOnHome.equals(true),
  );

  // SELECT COUNT(*) FROM budget_categories WHERE ...
  Future<int> _count(Expression<bool> where) {
    final count = _db.budgetCategories.id.count();
    final query = _db.selectOnly(_db.budgetCategories)
      ..addColumns([count])
      ..where(where);
    return query.map((row) => row.read(count)!).getSingle();
  }

  // 현재 또는 앞으로 적용될 비율에 이 카테고리가 0보다 큰 비율로 남아 있는지 (서버 isCategoryInUse)
  // - 이번 달에 적용 중인 묶음(이번 달 이하 중 최신)부터, 그 이후 묶음까지 확인
  Future<bool> _isInUse(int categoryId) async {
    final thisMonth = currentMonth();
    final from = await _db.latestApplyFrom(thisMonth) ?? thisMonth;
    final found =
        await (_db.select(_db.ratioItems)
              ..where(
                (i) =>
                    i.categoryId.equals(categoryId) &
                    i.ratio.isBiggerThanValue(0) &
                    i.applyFrom.isBiggerOrEqualValue(from),
              )
              ..limit(1))
            .get();
    return found.isNotEmpty;
  }
}
