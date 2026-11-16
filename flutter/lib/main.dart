// [역할] 앱 시작점
// - 앱에 필요한 초기화(날짜 포맷, Firebase)를 한 뒤 앱을 실행한다.
// - 저장된 토큰이 있으면 홈(ShellScreen), 없으면 로그인 화면(LoginScreen)으로 시작한다.
// - 앱 전체 테마(색, 버튼, 입력칸 스타일)를 정한다.

import 'package:moa/app_navigator.dart';
import 'package:moa/services/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:moa/screens/shell_screen.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'package:moa/constants/colors.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 저장된 토큰이 있으면 로그인된 상태로 시작
  final token = await TokenStorage.getToken();
  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn; // main()에서 토큰 존재 여부를 받아 옴
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 화면 밖(ApiClient)에서도 화면 이동·스낵바를 쓸 수 있게 전역 키 연결 (토큰 만료 시 로그인 화면으로)
      navigatorKey: AppNavigator.navigatorKey,
      scaffoldMessengerKey: AppNavigator.scaffoldMessengerKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: backColor,
        appBarTheme: AppBarTheme(
          backgroundColor: backColor,
          foregroundColor: primaryColor,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: backColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primaryColor),
          ),
          labelStyle: TextStyle(color: TextColor),
          floatingLabelStyle: TextStyle(color: primaryColor),
        ),
      ),

      // 앱 시작 화면: 토큰이 있으면 홈, 없으면 로그인 화면
      // (로그인/로그아웃 후 화면 이동은 각 화면에서 Navigator로 처리)
      home: isLoggedIn ? ShellScreen() : LoginScreen(),
    );
  }
}
