import 'package:flutter/material.dart';
import 'package:moa/utils/api_error.dart';
import 'package:moa/screens/auth/signup_screen.dart';
import 'package:moa/screens/shell_screen.dart';
import 'package:moa/services/auth_service.dart';

// StatefulWidget: 상태(데이터)가 변하는 화면에서 사용
// 로그인 화면은 텍스트 입력값이 변하니까 StatefulWidget 사용
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // TextEditingController: TextFeild의 입력값을 가져오는 컨트롤러
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final _passwordFocus = FocusNode();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Scaffold: 앱 화면의 기본 뼈대
    return Scaffold(
      body: Padding(
        // padding: 내부 여백 설정
        padding: const EdgeInsets.all(24.0),
        child: Column(
          // Column: 위젯을 세로로 배치
          // mainAxisAlignment: 세로 방향 정렬 (center = 가운데)
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 타이틀
            Text('Moa', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),

            // sizedBox: 빈 공간 (height = 세로 간격)
            SizedBox(height: 48),

            // 이메일 입력 필드
            TextField(
              controller: emailController, // 입력값 연결
              decoration: InputDecoration(labelText: '이메일'),
              keyboardType: TextInputType.emailAddress, // 이메일 키보드
              onSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
            ),

            SizedBox(height: 16),

            // 비밀번호 입력 필드
            TextField(
              controller: passwordController, // 입력값 연결
              decoration: InputDecoration(labelText: '비밀번호'),
              focusNode: _passwordFocus,
              obscureText: true, // 비밀번호 가리기 (***)
            ),

            // 로그인 버튼
            // SizedBox width: double.infinity = 가로 꽉 채우기
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        try {
                          setState(() => isLoading = true);
                          await _authService.signIn(
                            email: emailController.text,
                            password: passwordController.text,
                          );
                          setState(() => isLoading = false);

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => ShellScreen()),
                          );
                        } catch (e) {
                          setState(() => isLoading = false);
                          // 비밀번호 틀림(401) → 서버 메시지, 서버 꺼짐 → 연결 안내
                          final message = apiErrorMessage(e, '이메일 또는 비밀번호를 확인해주세요.');
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        }
                      },
                child: Text('로그인'),
              ),
            ),

            // 회원가입 이동 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupScreen()),
                  );
                },
                child: Text('회원가입'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
