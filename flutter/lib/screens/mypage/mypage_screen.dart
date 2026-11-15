import 'package:flutter/material.dart';
import 'package:moa/constants/colors.dart';
import 'package:moa/services/auth_service.dart';
import 'package:moa/screens/auth/login_screen.dart';
import 'package:moa/screens/budget/budget_form_screen.dart';
import 'package:moa/screens/budget/budget_category_screen.dart';
import 'package:moa/services/user_service.dart';
import 'package:dio/dio.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService(); // 내 정보 조회용
  bool isDeleting = false;
  String email = ''; // 서버에서 받아 오기 전에는 빈 문자열

  @override
  void initState() {
    super.initState();
    _loadEmail(); // 화면이 처음 만들어질 때 한 번 서버에서 이메일 가져오기
  }

  // 서버에서 내 이메일 가져오기
  Future<void> _loadEmail() async {
    try {
      final result = await _userService.getMyEmail();
      if (!mounted) return; // 요청하는 동안 화면을 벗어났으면 setState 하지 않음
      setState(() => email = result); // 받은 이메일을 화면에 반영
    } on DioException catch (e) {
      // 실패해도 마이페이지는 쓸 수 있게 이메일만 비워 둠 (토큰 만료 처리는 TODO 92)
      print('이메일 조회 실패: ${e.response?.statusCode}');
    }
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? primaryColor),
      title: Text(label, style: TextStyle(color: color)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 100.0,
              bottom: 24.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '마이페이지',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 32),

                // 프로필
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: primaryColor.withOpacity(0.2),
                        child: Icon(Icons.person, color: primaryColor),
                      ),
                      SizedBox(width: 12),
                      Text(
                        email, // 서버에서 받아 온 이메일
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),

                // 메뉴 리스트
                _buildMenuItem(
                  icon: Icons.account_balance_wallet,
                  label: '예산 설정',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BudgetFormScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.category_outlined,
                  label: '예산 카테고리 관리',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BudgetCategoryScreen()),
                    );
                  },
                ),
                Divider(),
                _buildMenuItem(
                  icon: Icons.logout,
                  label: '로그아웃',
                  onTap: () async {
                    // 이중 확인 다이얼로그
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        // title: Text('거래 삭제'),
                        content: Text('로그아웃하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('취소'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('로그아웃', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _authService.signOut();
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      }
                    }
                  },
                ),

                // 회원 탈퇴 버튼
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.white,
                          title: Text('회원탈퇴'),
                          content: Text('탈퇴하면 모든 데이터가 삭제되며\n복구할 수 없습니다.\n정말 탈퇴하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('취소'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('탈퇴', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        final passwordController = TextEditingController();

                        final password = await showDialog<String>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.white,
                            title: Text('비밀번호 확인'),
                            content: TextField(
                              controller: passwordController,
                              decoration: InputDecoration(labelText: '비밀번호'),
                              obscureText: true,
                              autofocus: true,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('취소'),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (passwordController.text.isEmpty) {
                                    return;
                                  }
                                  // 비밀번호 확인은 서버가 탈퇴 요청에서 처리
                                  Navigator.pop(context, passwordController.text);
                                },
                                child: Text('확인', style: TextStyle(color: primaryColor)),
                              ),
                            ],
                          ),
                        );

                        if (password == null || password.isEmpty) return;

                        // await Future.delayed(
                        //   Duration(milliseconds: 100),
                        // ); // 다이얼로그 닫힐 시간

                        setState(() => isDeleting = true);
                        try {
                          await _authService.deleteAccount(password);
                          if (mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                              (route) => false,
                            );
                          }
                        } on DioException catch (e) {
                          // 서버가 보낸 {"message": "..."} 를 그대로 표시 (예: "비밀번호가 올바르지 않습니다.")
                          final message = e.response?.data?['message'] ?? '탈퇴 실패';
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                          if (mounted) setState(() => isDeleting = false);
                        }
                      }
                    },
                    child: Text(
                      '회원탈퇴    ',
                      style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    ),
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),

          // 로딩 오버레이
          if (isDeleting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
