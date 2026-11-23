// [역할] 통계 서버 호출 (서버 StatsController와 1:1) — 서버 모드에서 쓰는 StatsRepository 구현
// - 서버 API: GET /api/stats/categories?year=&month=, GET /api/stats/yearly?year=

import 'package:dio/dio.dart';
import 'package:moa/data/repositories.dart'; // 서버 구현으로서 지키는 인터페이스
import 'package:moa/models/stats_model.dart';
import 'package:moa/services/api_client.dart';

class StatsService implements StatsRepository {
  final Dio _dio = ApiClient.dio; // 토큰 헤더가 자동으로 붙는 공통 클라이언트

  @override
  Future<CategoryStatsModel> getCategoryStats(int year, int month) async {
    final response = await _dio.get(
      '/api/stats/categories',
      queryParameters: {'year': year, 'month': month},
    );
    return CategoryStatsModel.fromJson(response.data);
  }

  @override
  Future<YearlyStatsModel> getYearlyStats(int year) async {
    final response = await _dio.get('/api/stats/yearly', queryParameters: {'year': year});
    return YearlyStatsModel.fromJson(response.data);
  }
}
