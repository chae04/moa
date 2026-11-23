// [역할] 서버 모드의 수입·지출 카테고리: 서버에 테이블이 없어서 constants/categories.dart의 고정 목록을 그대로 돌려준다.
// - isEditable = false → 마이페이지가 관리 메뉴를 숨긴다. 추가·변경·삭제를 부르면 안내 에러
// - 서버까지 바꾸려면: entry_categories 테이블·API를 서버에 추가하고 이 클래스를 HTTP 구현으로 교체

import 'package:moa/constants/categories.dart';
import 'package:moa/data/app_exception.dart';
import 'package:moa/data/repositories.dart';
import 'package:moa/models/entry_category_model.dart';

class FixedEntryCategoryService implements EntryCategoryRepository {
  static const _notSupported = AppException('서버 모드에서는 카테고리를 바꿀 수 없어요.');

  @override
  bool get isEditable => false;

  @override
  Future<List<EntryCategoryModel>> getCategories(String kind) async {
    final names = kind == '수입' ? incomeCategoryList : expenseCategoryList;
    return [
      for (var i = 0; i < names.length; i++)
        EntryCategoryModel(id: i, kind: kind, name: names[i]),
    ];
  }

  @override
  Future<void> addCategory(String kind, String name) async => throw _notSupported;

  @override
  Future<void> renameCategory(int id, String name) async => throw _notSupported;

  @override
  Future<void> deleteCategory(int id) async => throw _notSupported;
}
