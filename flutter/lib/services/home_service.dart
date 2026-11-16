// [역할] 홈 화면 데이터 서버 호출 (서버 HomeController와 1:1)
// - 서버 API: GET /api/home?year=2026&month=11
// - 합계, 카테고리별 예산·사용액·잔액, 날짜별 지출, 일일 추천 예산을 한 번에 받는다.
//   → 계산 규칙(자동 거래 제외, 반올림, 남은 일수)은 서버에만 있고 Flutter는 표시만 한다.

import 'package:dio/dio.dart';
import 'package:moa/models/home_model.dart';
import 'package:moa/services/api_client.dart';

class HomeService {
  final Dio _dio = ApiClient.dio; // 토큰 헤더가 자동으로 붙는 공통 클라이언트

  // 해당 연월의 홈 데이터 조회
  Future<HomeModel> getHome(int year, int month) async {
    final response = await _dio.get(
      '/api/home',
      queryParameters: {'year': year, 'month': month},
    );
    return HomeModel.fromJson(response.data); // 응답 JSON(Map) → 모델
  }
}
