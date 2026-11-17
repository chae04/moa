// [역할] 서버와 통신하는 공통 HTTP 클라이언트
// - 서버 주소(baseUrl), 타임아웃, JSON 형식 같은 공통 설정을 한 곳에 모아 둔다.
// - 인터셉터로 모든 요청에 토큰(Authorization 헤더)을 자동으로 붙인다.
// - 401을 받으면 토큰을 지우고 로그인 화면으로 보낸다 (/api/auth/ 제외).
// - 각 서비스(auth, category, budget, transaction)는 ApiClient.dio로 요청만 보내면 된다.

import 'dart:io' show Platform; // 실행 중인 OS 확인용
import 'package:dio/dio.dart';
import 'package:moa/app_navigator.dart'; // 401이면 로그인 화면으로 이동
import 'package:moa/services/token_storage.dart';

class ApiClient {
  ApiClient._(); // private 생성자: 객체를 못 만들게 막음 (static으로만 사용)

  // 앱 전체가 함께 쓰는 Dio 하나 (처음 접근할 때 한 번 생성)
  static final Dio dio = _createDio();

  // 401 처리 중인지 (동시에 여러 요청이 401을 받아도 로그인 화면 이동은 한 번만)
  static bool _isLoggingOut = false;

  // 에뮬레이터에서 내 PC 서버 주소
  // 안드로이드 에뮬레이터: 10.0.2.2 = 에뮬레이터 밖의 PC
  // iOS 시뮬레이터: localhost = Mac 자신
  static String get _baseUrl =>
      Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl, // 요청할 때 '/api/...'만 쓰면 앞에 붙음
        connectTimeout: const Duration(
          seconds: 5,
        ), // 서버 연결 대기 최대 5초 (서버 꺼져 있을 때 무한 대기 방지)
        receiveTimeout: const Duration(seconds: 5), // 응답 대기 최대 5초
        contentType: Headers.jsonContentType, // 요청 본문을 JSON으로 보냄 (서버 @RequestBody와 맞춤)
      ),
    );

    // 인터셉터: 모든 요청이 나가기 직전에 실행되는 코드
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getToken(); // 저장된 토큰 꺼내기
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token'; // 서버 JwtAuthFilter가 읽는 헤더
            _isLoggingOut = false; // 다시 로그인해서 토큰이 생겼으면 플래그 해제
          }
          handler.next(options); // 요청 계속 진행
        },
        // 응답이 에러(4xx, 5xx, 연결 실패)일 때 화면보다 먼저 실행됨
        onError: (error, handler) async {
          final status = error.response?.statusCode; // 서버가 꺼져 있으면 response가 null
          final path = error.requestOptions.path; // 예: '/api/home'

          // 401 = 토큰 없음·만료·위조, 탈퇴한 사용자 → 로그아웃
          // 단, /api/auth/의 401(로그인 비밀번호 틀림)은 로그아웃하면 안 됨
          final shouldLogout = status == 401 && !path.startsWith('/api/auth/');

          if (shouldLogout && !_isLoggingOut) {
            _isLoggingOut = true;
            handler.next(error); // 1. 화면의 catch가 먼저 실행되게 에러부터 넘김
            await TokenStorage.deleteToken(); // 2. 토큰 삭제 (기다리는 동안 화면 catch가 끝남)
            AppNavigator.goToLogin('로그인이 만료되었어요. 다시 로그인해주세요.'); // 3. 이동 + 안내
            return; // handler는 한 번만 호출해야 하므로 여기서 끝
          }

          handler.next(error); // 그 밖의 에러는 그대로 화면에 전달 (화면의 catch가 메시지 표시)
        },

      ),
    );

    return dio;
  }
}
