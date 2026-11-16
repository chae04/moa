// [역할] 거래 서버 호출 모음 (서버 TransactionController와 1:1)
// - 서버 API: GET /api/transactions?year=&month=, POST /api/transactions,
//             PUT/DELETE /api/transactions/{id}
// - 수입을 추가하면 서버가 저축·투자 자동 거래를 만들고, 수입을 삭제하면 같이 지운다.
//   → Flutter는 자동 거래를 직접 만들거나 지우지 않는다.
// - 서버가 막는 것: 자동 거래 수정, 유형 변경, 수입 금액 변경, 다른 사람 거래 접근
//   → 실패하면 DioException(400/404)이 호출한 화면으로 전달된다.

import 'package:dio/dio.dart';
import 'package:moa/models/transaction_model.dart';
import 'package:moa/services/api_client.dart';

class TransactionService {
  final Dio _dio = ApiClient.dio; // 토큰 헤더가 자동으로 붙는 공통 클라이언트

  // 거래 추가 (수입이면 서버가 자동 저축·투자도 생성)
  Future<void> addTransaction(TransactionModel transaction) async {
    await _dio.post('/api/transactions', data: transaction.toJson());
  }

  // 거래 수정
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _dio.put('/api/transactions/${transaction.id}', data: transaction.toJson());
  }

  // 거래 삭제 (수입이면 서버가 자동 거래도 같이 삭제)
  Future<void> deleteTransaction(int id) async {
    await _dio.delete('/api/transactions/$id');
  }

  // 월별 거래 조회
  Future<List<TransactionModel>> getMonthlyTransactions(int year, int month) async {
    final response = await _dio.get(
      '/api/transactions',
      queryParameters: {'year': year, 'month': month}, // → ?year=2026&month=11
    );
    final List<dynamic> list = response.data; // 서버 응답: [{...}, {...}]
    return list.map((json) => TransactionModel.fromJson(json)).toList();
  }
}
