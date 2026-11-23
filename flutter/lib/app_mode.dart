// [역할] 앱이 어디에 데이터를 저장할지(모드) 정하는 곳
// - local(기본): 폰 안 로컬 DB(drift). 로그인 없음. 실제로 쓰는 모드
// - remote: Spring 서버 (로그인, JWT, 401 처리). 포트폴리오 시연용
// - 빌드할 때 고른다. 코드 수정 없이 실행 명령만 바꾸면 됨
//   로컬:  flutter run
//   서버:  flutter run --dart-define=MODE=remote
// - String.fromEnvironment는 "컴파일할 때" 값이 정해지는 상수라, 실행 중에는 바뀌지 않는다.

const String appMode = String.fromEnvironment('MODE', defaultValue: 'local');

// 서버 모드가 아니면 전부 로컬로 취급 (오타가 나도 안전하게 로컬)
const bool isLocalMode = appMode != 'remote';
