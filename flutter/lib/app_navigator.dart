// [역할] 화면 밖(ApiClient 등)에서 화면 이동과 스낵바를 쓰기 위한 전역 키 모음
// - 보통은 Navigator.of(context)처럼 context가 있어야 화면을 이동할 수 있는데,
//   ApiClient 인터셉터에는 context가 없다. → MaterialApp에 키를 달아 두고 키로 접근한다.
// - 사용처: main.dart(키 연결), api_client.dart(401이면 goToLogin 호출)

import 'package:flutter/material.dart';
import 'package:moa/screens/auth/login_screen.dart';

class AppNavigator {
  AppNavigator._(); // private 생성자: static으로만 사용 (ApiClient와 같은 패턴)

  // MaterialApp(navigatorKey: ...)에 연결 → 앱 어디서든 화면 이동 가능
  static final navigatorKey = GlobalKey<NavigatorState>();

  // MaterialApp(scaffoldMessengerKey: ...)에 연결 → 앱 어디서든 스낵바 표시 가능
  // (화면이 바뀌어도 유지되므로 로그인 화면으로 이동한 뒤에도 메시지가 보임)
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  // 모든 화면을 닫고 로그인 화면으로 이동 + 안내 메시지
  static void goToLogin(String message) {
    // currentState: 키에 연결된 Navigator. 앱이 아직 안 떴으면 null일 수 있어서 ?.
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false, // 이전 화면을 전부 제거 → 뒤로가기로 홈에 못 돌아감
    );

    // 화면들의 catch가 띄운 "다시 로그인해주세요" 스낵바를 지우고 안내 하나만 표시
    // ..(캐스케이드): 같은 객체에 메서드를 이어서 호출 → clearSnackBars() 후 showSnackBar()
    scaffoldMessengerKey.currentState
      ?..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
