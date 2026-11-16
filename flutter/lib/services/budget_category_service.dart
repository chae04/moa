// [역할] 예산 카테고리 서버 호출 모음 (서버 CategoryController와 1:1)
// - 서버 API: GET/POST /api/categories, PUT/DELETE /api/categories/{id}
// - 서버가 검증하는 것: 본인 소유, 홈 표시 최대 5개, 최소 1개 유지, 이름 10자 이내
//   → 실패하면 DioException(400/404)이 호출한 화면으로 전달된다.
// - 삭제는 서버가 소프트 삭제(isDeleted)로 처리하고, 목록에서는 자동으로 빠진다.

import 'package:dio/dio.dart';
import 'package:moa/models/budget_category_model.dart';
import 'package:moa/services/api_client.dart';

class BudgetCategoryService {
  final Dio _dio = ApiClient.dio;

  // 카테고리 목록 불러오기 (서버가 삭제 제외 + 순서대로 정렬해서 줌)
  Future<List<BudgetCategoryModel>> getCategories() async {
    final response = await _dio.get('/api/categories');
    final List<dynamic> list = response.data; // 서버 응답: [{...}, {...}]
    return list.map((json) => BudgetCategoryModel.fromJson(json)).toList();
  }

  // 카테고리 추가 (순서는 서버가 맨 뒤로 정함)
  Future<void> addCategory({
    required String name,
    required bool showOnHome,
    bool includeInDaily = false,
  }) async {
    await _dio.post(
      '/api/categories',
      data: {'name': name, 'showOnHome': showOnHome, 'includeInDaily': includeInDaily},
    );
  }

  // 카테고리 수정 (이름, 홈 표시, 일일 포함)
  Future<void> updateCategory(BudgetCategoryModel category) async {
    await _dio.put('/api/categories/${category.id}', data: category.toJson());
  }

  // 카테고리 삭제 (서버에서 소프트 삭제)
  Future<void> deleteCategory(int id) async {
    await _dio.delete('/api/categories/$id');
  }
}
