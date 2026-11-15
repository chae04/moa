// [역할] 사용자 정보 관련 서버 호출 모음 (서버 UserController와 1:1)
// - 서버 API: GET /api/users/me (내 정보 조회)
// - 누구의 정보인지는 토큰으로 판단하므로 userId를 보내지 않는다. (토큰은 ApiClient 인터셉터가 자동으로 붙임)
// - 탈퇴(DELETE /api/users/me)는 토큰 삭제까지 함께 해야 해서 auth_service.dart에 있다.

import 'package:dio/dio.dart';
import 'package:moa/services/api_client.dart';

class UserService {
  final Dio _dio = ApiClient.dio;

  // 내 이메일 조회 (마이페이지 프로필 표시용)
  Future<String> getMyEmail() async {
    final response = await _dio.get('/api/users/me'); // 서버 응답: {"email": "a@a.com"}
    return response.data['email']; // 이메일 문자열만 꺼내서 반환
  }
}
