import 'package:flutter/material.dart';
import 'package:moa/constants/colors.dart';
import 'package:moa/constants/styles.dart';
import 'package:moa/services/auth_service.dart';
import 'package:moa/screens/auth/login_screen.dart';

class SignupBudgetScreen extends StatefulWidget {
  final String email;
  final String password;

  const SignupBudgetScreen({super.key, required this.email, required this.password});

  @override
  State<SignupBudgetScreen> createState() => _SignupBudgetScreenState();
}

class _SignupBudgetScreenState extends State<SignupBudgetScreen> {
  final AuthService _authService = AuthService();
  bool isLoading = false;

  // 기본 카테고리 하드코딩
  final List<Map<String, dynamic>> categories = [
    {'name': '생활비', 'ratio': 0, 'includeInDaily': true},
    {'name': '자유비', 'ratio': 0, 'includeInDaily': false},
  ];

  Map<String, TextEditingController> controllers = {};
  Map<String, bool> includeInDaily = {};
  int savingRatio = 0;
  int investRatio = 0;
  final savingRatioController = TextEditingController();
  final investRatioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (var c in categories) {
      controllers[c['name']] = TextEditingController();
      includeInDaily[c['name']] = c['includeInDaily'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Text(
                '예산 비율 설정',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),

            // 카테고리별 비율 입력
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: SizedBox()),
                    Text('일일 예산', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 8),
                ...categories.map((category) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controllers[category['name']],
                            decoration: inputDecoration('${category['name']} (%)'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                category['ratio'] = int.tryParse(value) ?? 0;
                              });
                            },
                          ),
                        ),
                        Checkbox(
                          value: includeInDaily[category['name']] ?? false,
                          activeColor: primaryColor,
                          onChanged: (value) {
                            setState(() {
                              includeInDaily[category['name']] = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
                Divider(color: Colors.grey[200]),
                SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: savingRatioController,
                          decoration: inputDecoration('저축 (%)'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              savingRatio = int.tryParse(value) ?? 0;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 40),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: investRatioController,
                          decoration: inputDecoration('투자 (%)'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              investRatio = int.tryParse(value) ?? 0;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 40),
                    ],
                  ),
                ),
              ],
            ),

            // 버튼
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final totalRatio =
                                categories.fold(
                                  0,
                                  (sum, c) => sum + (c['ratio'] as int),
                                ) +
                                savingRatio +
                                investRatio;

                            if (totalRatio != 100) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('비율 합계가 100%가 되어야 합니다. 현재: $totalRatio'),
                                ),
                              );
                              return;
                            }

                            setState(() => isLoading = true);
                            try {
                              // 회원가입 처리 (여기서 실행)
                              await _authService.signUp(
                                email: widget.email,
                                password: widget.password,
                                budgetCategories: categories,
                                includeInDaily: includeInDaily,
                                savingRatio: savingRatio,
                                investRatio: investRatio,
                              );

                              if (mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => LoginScreen()),
                                  (route) => false,
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text('회원가입 실패: $e')));
                              if (mounted) setState(() => isLoading = false);
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
                        : Text('완료'),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('돌아가기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
