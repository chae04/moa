import 'package:flutter/material.dart';
import 'package:moa/services/auth_service.dart';

// StatefulWidget: 상태(데이터)가 변하는 화면에서 사용
// 회원가입 화면은 텍스트 입력값이 변하니까 StatefulWidget 사용
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // TextEditingController: TextFeild의 입력값을 가져오는 컨트롤러
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordCheckController = TextEditingController();
  final nicknameController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    // Scaffold: 앱 화면의 기본 뼈대
    return Scaffold(
      body: Padding(
        // padding: 내부 여백 설정
        padding: const EdgeInsets.all(24.0),
        child: Column(
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
              keyboardType: TextInputType.emailAddress,
            ),

            SizedBox(height: 16),

            // 비밀번호 입력 필드
            TextField(
              controller: passwordController, // 입력값 연결
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true, // 비밀번호 가리기 (***)
            ),

            SizedBox(height: 16),

            // 비밀번호 확인 입력 필드
            TextField(
              controller: passwordCheckController,
              decoration: InputDecoration(labelText: '비밀번호 확인'),
              obscureText: true,
            ),

            SizedBox(height: 16),

            // 닉네임 입력 필드
            TextField(
              controller: nicknameController,
              decoration: InputDecoration(labelText: '닉네임'),
              keyboardType: TextInputType.name,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('이전'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    if (passwordController.text.length < 6) {
                      print('비밀번호 짧음');
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('비밀번호는 6자리 이상이어야 합니다.')));
                      return;
                    } else if (passwordController.text != passwordCheckController.text) {
                      print('비밀번호 불일치');
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('비밀번호 재확인')));
                      return;
                    }
                    print('validation 통과');
                    try {
                      await _authService.signUp(
                        email: emailController.text,
                        password: passwordController.text,
                        nickname: nicknameController.text,
                      );
                      print('회원가입 성공');
                      if (mounted) Navigator.pop(context); // 회원가입 후 로그인 화면으로 이동
                    } catch (e) {
                      print('에러: $e');
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('회원가입 실패: $e')));
                    }
                  },
                  child: Text('회원가입'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
