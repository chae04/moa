import 'package:firebase_auth/firebase_auth.dart';
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
  // await FirebaseAuth.instance.signOut(); // 임시 추가
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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

      // StreamBuilder : Firebase Auth 상태가 바뀔 때마다 자동으로 화면을 바꿔줌
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 로딩 중
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          // 로그인 상태 : 홈 화면
          if (snapshot.hasData) {
            return ShellScreen();
          }
          // 로그아웃 상태: 로그인 화면
          return LoginScreen();
        },
      ),
    );
  }
}
