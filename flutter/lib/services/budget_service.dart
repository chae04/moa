// [역할] 예산 비율 서버 호출 모음 (서버 BudgetRatioController와 1:1)
// - 서버 API: GET /api/budget-ratios?month=YYYY-MM, PUT /api/budget-ratios
// - 같은 적용 월로 다시 저장하면 서버가 그 묶음을 통째로 교체한다.
// - 서버가 검증하는 것: 합계 100, 지난 달 변경 불가, 본인 카테고리
//   → 실패하면 DioException(400)이 호출한 화면으로 전달된다.
// - 금액(수입 × 비율)은 서버가 계산하므로 금액 관련 메서드가 없다.

import 'package:dio/dio.dart';
import 'package:moa/data/repositories.dart'; // 서버 구현으로서 지키는 인터페이스
import 'package:moa/models/budget_model.dart';
import 'package:moa/services/api_client.dart';

class BudgetService implements RatioRepository {
  final Dio _dio = ApiClient.dio; // 토큰 헤더가 자동으로 붙는 공통 클라이언트

  // 해당 월에 적용되는 비율 묶음 조회
  // 비율이 없는 달이어도 404가 아니라 applyFrom == null인 모델이 옴 → 반환 타입이 nullable이 아님
  @override
  Future<BudgetModel> getRatios(String month) async {
    final response = await _dio.get(
      '/api/budget-ratios',
      queryParameters: {'month': month}, // → /api/budget-ratios?month=2026-11 (dio가 붙여 줌)
    );
    return BudgetModel.fromJson(response.data); // 응답 JSON(Map) → 모델
  }

  // 비율 저장 (budget.applyFrom 월부터 적용). 서버가 저장된 묶음을 다시 돌려줌
  @override
  Future<BudgetModel> saveRatios(BudgetModel budget) async {
    final response = await _dio.put('/api/budget-ratios', data: budget.toJson());
    return BudgetModel.fromJson(response.data);
  }
}
