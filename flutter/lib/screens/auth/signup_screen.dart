import 'package:moa/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:moa/utils/api_error.dart';
import 'package:moa/screens/auth/signup_budget_screen.dart';

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
  final AuthService _authService = AuthService(); // 이메일 중복 확인용
  bool isLoading = false;

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
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (passwordController.text.length < 6) {
                            print('비밀번호 짧음');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('비밀번호는 6자리 이상이어야 합니다.')),
                            );
                            return;
                          } else if (passwordController.text !=
                              passwordCheckController.text) {
                            print('비밀번호 불일치');
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('비밀번호 재확인')));
                            return;
                          }
                          print('validation 통과');

                          // 이메일 중복 확인 (서버) - 비밀번호 검사가 끝난 뒤에 한 번만 요청
                          setState(() => isLoading = true); // 버튼 스피너 표시 + 중복 클릭 방지
                          try {
                            final available = await _authService.checkEmail(
                              emailController.text,
                            );
                            if (!available) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text('이미 사용 중인 이메일입니다.')));
                              return; // 예산 비율 화면으로 넘어가지 않음
                            }
                          } catch (e) {
                            // 서버 꺼짐, 파라미터 누락(400) 등
                            final message =
                                apiErrorMessage(e, '이메일 확인에 실패했어요.');
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(message)));
                            return;
                          } finally {
                            if (mounted) {
                              setState(() => isLoading = false); // 성공/실패/return 모두 스피너 끄기
                            }
                          }

                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignupBudgetScreen(
                                  email: emailController.text,
                                  password: passwordController.text,
                                ),
                              ),
                            );
                          }
                        },
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('다음'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
