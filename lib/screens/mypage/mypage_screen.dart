import 'package:flutter/material.dart';
import 'package:moa/constants/colors.dart';
import 'package:moa/services/auth_service.dart';
import 'package:moa/screens/auth/login_screen.dart';
import 'package:moa/screens/budget/budget_form_screen.dart';
import 'package:moa/screens/budget/budget_category_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  final AuthService _authService = AuthService();
  bool isLoading = true;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
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
          isLoading
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
                              FirebaseAuth.instance.currentUser?.email ?? '',
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
                            MaterialPageRoute(
                              builder: (context) => BudgetCategoryScreen(),
                            ),
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
                                  child: Text(
                                    '로그아웃',
                                    style: TextStyle(color: Colors.red),
                                  ),
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
                                content: Text(
                                  '탈퇴하면 모든 데이터가 삭제되며\n복구할 수 없습니다.\n정말 탈퇴하시겠습니까?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text(
                                      '탈퇴',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              final passwordController = TextEditingController();

                              final password = await showDialog<String>(
                                context: context,
                                builder: (context) => StatefulBuilder(
                                  builder: (context, setDialogState) {
                                    String? errorText;
                                    bool isVerifying = false;

                                    return StatefulBuilder(
                                      builder: (context, setDialogState) {
                                        return AlertDialog(
                                          backgroundColor: Colors.white,
                                          title: Text('비밀번호 확인'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextField(
                                                controller: passwordController,
                                                decoration: InputDecoration(
                                                  labelText: '비밀번호',
                                                  errorText: errorText,
                                                ),
                                                obscureText: true,
                                                autofocus: true,
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text('취소'),
                                            ),
                                            TextButton(
                                              onPressed: isVerifying
                                                  ? null
                                                  : () async {
                                                      if (passwordController.text.isEmpty)
                                                        return;
                                                      setDialogState(() {
                                                        isVerifying = true;
                                                        errorText = null;
                                                      });
                                                      try {
                                                        await _authService.reauthenticate(
                                                          passwordController.text,
                                                        );
                                                        Navigator.pop(
                                                          context,
                                                          passwordController.text,
                                                        );
                                                      } catch (e) {
                                                        setDialogState(() {
                                                          isVerifying = false;
                                                          errorText = '비밀번호가 틀렸습니다.';
                                                        });
                                                      }
                                                    },
                                              child: isVerifying
                                                  ? SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                    )
                                                  : Text(
                                                      '확인',
                                                      style: TextStyle(
                                                        color: primaryColor,
                                                      ),
                                                    ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
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
                                    MaterialPageRoute(
                                      builder: (context) => LoginScreen(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              } catch (e) {
                                String message = '탈퇴 실패';
                                if (e.toString().contains('wrong-password') ||
                                    e.toString().contains('invalid-credential')) {
                                  message = '비밀번호가 틀렸습니다.';
                                }
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
