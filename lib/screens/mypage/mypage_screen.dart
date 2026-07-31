import 'package:flutter/material.dart';
import 'package:moa/services/auth_service.dart';
import 'package:moa/screens/auth/login_screen.dart';
import 'package:moa/screens/budget/budget_form_screen.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  final AuthService _authService = AuthService();
  final nicknamecontroller = TextEditingController();
  String nickname = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNickname();
  }

  Future<void> _loadNickname() async {
    final name = await _authService.getNickname();
    setState(() {
      nickname = name;
      nicknamecontroller.text = name;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '마이페이지',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 48),

                  // 닉네임 수정
                  TextField(
                    controller: nicknamecontroller,
                    decoration: InputDecoration(labelText: '닉네임'),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _authService.updateNickname(nicknamecontroller.text);
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('닉네임이 변경되었습니다.')));
                      },
                      child: Text('닉네임 변경'),
                    ),
                  ),
                  SizedBox(height: 24),

                  // 예산 설정
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BudgetFormScreen()),
                        );
                      },
                      child: Text('예산 설정'),
                    ),
                  ),
                  SizedBox(height: 24),

                  // 로그아웃
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _authService.signOut();
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        }
                      },
                      child: Text('로그아웃'),
                    ),
                  ),
                  SizedBox(height: 24),

                  // 홈
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('홈'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
