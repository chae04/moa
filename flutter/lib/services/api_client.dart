// [역할] 서버와 통신하는 공통 HTTP 클라이언트
// - 서버 주소(baseUrl), 타임아웃, JSON 형식 같은 공통 설정을 한 곳에 모아 둔다.
// - 인터셉터로 모든 요청에 토큰(Authorization 헤더)을 자동으로 붙인다.
// - 각 서비스(auth, category, budget, transaction)는 ApiClient.dio로 요청만 보내면 된다.

import 'dart:io' show Platform; // 실행 중인 OS 확인용
import 'package:dio/dio.dart';
import 'package:moa/services/token_storage.dart';

class ApiClient {
  ApiClient._(); // private 생성자: 객체를 못 만들게 막음 (static으로만 사용)

  // 앱 전체가 함께 쓰는 Dio 하나 (처음 접근할 때 한 번 생성)
  static final Dio dio = _createDio();

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
          }
          handler.next(options); // 요청 계속 진행
        },
      ),
    );

    return dio;
  }
}
