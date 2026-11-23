// [역할] 저장소와 상관없는 "규칙 위반" 에러
// - 로컬 구현은 서버와 같은 규칙(합계 100, 홈 표시 최대 5개 등)을 어기면 이 에러를 던진다.
// - message는 서버 ApiException과 같은 한글 문구 → 화면은 서버 모드든 로컬 모드든 같은 방식으로 표시
// - 화면에서는 utils/api_error.dart의 apiErrorMessage(e, ...)가 이 message를 꺼내 준다.

class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message; // 디버깅 출력에서도 문구가 바로 보이게
}
