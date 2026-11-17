// [역할] 서버 통신 에러 → 사용자에게 보여 줄 한글 메시지로 변환
// - 서버가 보낸 {"message": "..."}가 있으면 그대로 사용 (서버 GlobalExceptionHandler와 짝)
// - 서버에 닿지 못한 경우(꺼짐, 타임아웃)는 따로 안내
// - 그 밖의 경우는 화면이 넘겨준 기본 문구(fallback) 사용
// - 스낵바를 띄울지는 화면이 정한다. (이 함수는 문장만 만든다)

import 'package:dio/dio.dart';

String apiErrorMessage(Object error, String fallback) {
  // dio 에러가 아니면 (코드 버그 등) 기본 문구
  if (error is! DioException) return fallback;

  // 서버에 닿지 못함: 연결 실패, 타임아웃
  switch (error.type) {
    case DioExceptionType.connectionError: // 서버 꺼짐, 주소 틀림, 인터넷 없음
    case DioExceptionType.connectionTimeout: // 연결 대기 5초 초과
    case DioExceptionType.receiveTimeout: // 응답 대기 5초 초과
      return '서버에 연결할 수 없어요. 잠시 후 다시 시도해주세요.';
    default:
      break;
  }

  // 서버가 {"message": "..."}로 응답한 경우
  final data = error.response?.data;
  if (data is Map && data['message'] is String) {
    // Map인지 먼저 확인 → String 본문이어도 안 죽음
    return data['message'];
  }

  // 그 밖 (본문 없는 500 등)
  return fallback;
}
