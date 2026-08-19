import 'package:flutter/material.dart';
import 'package:moa/constants/colors.dart';
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
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

                  // 닉네임 카드
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
                        Expanded(
                          child: TextField(
                            controller: nicknamecontroller,
                            decoration: InputDecoration(
                              labelText: '닉네임',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await _authService.updateNickname(nicknamecontroller.text);
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('닉네임이 변경되었습니다.')));
                          },
                          child: Text('변경', style: TextStyle(color: primaryColor)),
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

                  Divider(),
                  _buildMenuItem(
                    icon: Icons.logout,
                    label: '로그아웃',
                    onTap: () async {
                      await _authService.signOut();
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      }
                    },
                  ),

                  SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
