// [역할] 인증(회원가입 / 로그인 / 로그아웃 / 탈퇴) 담당 서비스
// - 화면(login, signup, mypage)은 이 클래스만 호출하고, 서버 주소나 토큰 처리는 몰라도 된다.
// - 서버 API: POST /api/auth/signup, POST /api/auth/login, DELETE /api/users/me, GET /api/auth/check-email
// - 로그인/가입에 성공하면 서버가 준 JWT를 TokenStorage에 저장한다.
// - 로그아웃은 서버 호출 없이 토큰만 지운다. (JWT는 서버가 로그인 상태를 기억하지 않기 때문)

import 'package:dio/dio.dart';
import 'package:moa/services/api_client.dart';
import 'package:moa/services/token_storage.dart';

class AuthService {
  final Dio _dio = ApiClient.dio; // 공통 클라이언트 (baseUrl, 토큰 헤더 설정 완료된 것)

  // 회원가입
  // 계정 + 기본 카테고리 + 첫 비율(이번 달부터)을 서버가 한 트랜잭션으로 저장한다.
  // 하나라도 실패하면 서버가 전부 롤백 → 같은 이메일로 다시 가입 가능
  Future<void> signUp({
    required String email,
    required String password,
    required int savingRatio,
    required int investRatio,
    required List<Map<String, dynamic>> categories, // [{name, includeInDaily, ratio}, ...]
  }) async {
    final response = await _dio.post(
      '/api/auth/signup', // baseUrl 뒤에 붙는 경로
      data: {
        'email': email,
        'password': password,
        'savingRatio': savingRatio,
        'investRatio': investRatio,
        'categories': categories, // List<Map>은 dio가 JSON 배열로 바꿔 줌
      }, // 서버 SignUpRequest와 같은 필드 이름
    );
    // 서버 응답: {"token": "eyJ..."} → dio가 Map으로 바꿔 줌
    await TokenStorage.saveToken(response.data['token']);
  }


  // 로그인
  Future<void> signIn({required String email, required String password}) async {
    // 로그인 API 호출 (회원가입과 같은 모양, 경로만 다름)
    final response = await _dio.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );

    // 받은 토큰 저장
    await TokenStorage.saveToken(response.data['token']);
  }

  // 이메일 중복 확인 (회원가입 첫 화면 "다음" 버튼에서 호출)
  // true = 가입 가능, false = 이미 가입된 이메일
  Future<bool> checkEmail(String email) async {
    final response = await _dio.get(
      '/api/auth/check-email',
      queryParameters: {'email': email}, // → ?email=a@a.com (특수문자 인코딩도 dio가 처리)
    );
    return response.data['available']; // 서버 응답 {"available": true}에서 값만 꺼냄
  }

  // 로그아웃: 저장된 토큰 삭제 → 다음 요청부터 토큰이 안 붙음 = 로그아웃 상태
  Future<void> signOut() async {
    await TokenStorage.deleteToken();
  }

  // 탈퇴: 서버가 비밀번호 확인 + 연관 데이터(거래, 비율, 카테고리) 삭제까지 처리
  Future<void> deleteAccount(String password) async {
    await _dio.delete(
      '/api/users/me', // 누구인지는 토큰으로 판단 (userId를 보내지 않음)
      data: {'password': password}, // 서버 WithdrawRequest
    );
    await TokenStorage.deleteToken(); // 계정이 없어졌으니 토큰도 삭제
  }
}
