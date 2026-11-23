// [역할] 앱 시작점
// - 앱에 필요한 초기화(날짜 포맷)를 한 뒤 앱을 실행한다.
// - 시작 화면은 모드(app_mode.dart)에 따라 다르다.
//   로컬 모드(기본): 첫 실행 설정을 마쳤으면 홈(ShellScreen), 아니면 예산 비율 설정(SignupBudgetScreen)
//   서버 모드: 저장된 토큰이 있으면 홈(ShellScreen), 없으면 로그인 화면(LoginScreen)
// - 앱 전체 테마(색, 버튼, 입력칸 스타일)를 정한다.

import 'package:moa/app_mode.dart';
import 'package:moa/app_navigator.dart';
import 'package:moa/data/app_repositories.dart';
import 'package:moa/screens/auth/signup_budget_screen.dart';
import 'package:moa/services/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:moa/screens/shell_screen.dart';
import 'screens/auth/login_screen.dart';
import 'package:moa/constants/colors.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR');

  final Widget startScreen;
  if (isLocalMode) {
    // 로컬: 로그인 없음. 카테고리가 하나라도 있으면 설정을 마친 것
    final ready = await AppRepositories.setup.isSetUp();
    startScreen = ready ? ShellScreen() : SignupBudgetScreen();
  } else {
    // 서버: 저장된 토큰이 있으면 로그인된 상태로 시작
    final token = await TokenStorage.getToken();
    startScreen = token != null ? ShellScreen() : LoginScreen();
  }
  runApp(MyApp(startScreen: startScreen));
}

class MyApp extends StatelessWidget {
  final Widget startScreen; // main()에서 모드에 맞게 정한 시작 화면
  const MyApp({super.key, required this.startScreen});

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

      // 앱 시작 화면 (main()에서 모드에 맞게 정함)
      // (로그인/로그아웃·첫 설정 후 화면 이동은 각 화면에서 Navigator로 처리)
      home: startScreen,
    );
  }
}
