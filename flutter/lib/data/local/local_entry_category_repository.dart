// [역할] 수입·지출 카테고리의 로컬 구현 (entry_categories 테이블)
// - 규칙: 이름 1~10자, 같은 종류(수입/지출) 안에서 이름 중복 불가, 종류마다 최소 1개 유지
// - 삭제는 소프트 삭제. 거래는 이름 문자열을 저장하므로 지난 거래·통계는 영향 없음

import 'package:drift/drift.dart';
import 'package:moa/data/app_exception.dart';
import 'package:moa/data/local/app_database.dart';
import 'package:moa/data/repositories.dart';
import 'package:moa/models/entry_category_model.dart';

class LocalEntryCategoryRepository implements EntryCategoryRepository {
  final AppDatabase _db;
  LocalEntryCategoryRepository(this._db);

  @override
  bool get isEditable => true;

  @override
  Future<List<EntryCategoryModel>> getCategories(String kind) async {
    final rows = await _active(kind);
    return rows
        .map((r) => EntryCategoryModel(id: r.id, kind: r.kind, name: r.name))
        .toList();
  }

  @override
  Future<void> addCategory(String kind, String name) async {
    if (kind != '수입' && kind != '지출') throw const AppException('종류는 수입 또는 지출이어야 합니다.');
    final trimmed = _validateName(name);
    final rows = await _active(kind);
    if (rows.any((r) => r.name == trimmed)) throw const AppException('이미 있는 카테고리예요.');

    final maxOrder = rows.isEmpty
        ? -1
        : rows.map((r) => r.orderIndex).reduce((a, b) => a > b ? a : b);
    await _db
        .into(_db.entryCategories)
        .insert(
          EntryCategoriesCompanion.insert(
            kind: kind,
            name: trimmed,
            orderIndex: maxOrder + 1,
          ),
        );
  }

  @override
  Future<void> renameCategory(int id, String name) async {
    final current = await _find(id);
    final trimmed = _validateName(name);
    final rows = await _active(current.kind);
    if (rows.any((r) => r.id != id && r.name == trimmed)) {
      throw const AppException('이미 있는 카테고리예요.');
    }

    await (_db.update(_db.entryCategories)..where((c) => c.id.equals(id))).write(
      EntryCategoriesCompanion(name: Value(trimmed)),
    );
  }

  @override
  Future<void> deleteCategory(int id) async {
    final current = await _find(id);
    if ((await _active(current.kind)).length <= 1) {
      throw AppException('${current.kind} 카테고리는 최소 1개 있어야 합니다.');
    }
    await (_db.update(_db.entryCategories)..where((c) => c.id.equals(id))).write(
      const EntryCategoriesCompanion(isDeleted: Value(true)),
    );
  }

  // ---- 내부 도우미 ----

  Future<List<EntryCategoryRow>> _active(String kind) =>
      (_db.select(_db.entryCategories)
            ..where((c) => c.kind.equals(kind) & c.isDeleted.equals(false))
            ..orderBy([(c) => OrderingTerm.asc(c.orderIndex)]))
          .get();

  Future<EntryCategoryRow> _find(int id) async {
    final row = await (_db.select(
      _db.entryCategories,
    )..where((c) => c.id.equals(id) & c.isDeleted.equals(false))).getSingleOrNull();
    if (row == null) throw const AppException('카테고리를 찾을 수 없습니다.');
    return row;
  }

  String _validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw const AppException('카테고리 이름을 입력해주세요.');
    if (trimmed.length > 10) throw const AppException('카테고리 이름은 10자 이내로 입력해주세요.');
    return trimmed;
  }
}
