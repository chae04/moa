// [역할] 처음 쓰는 예산 비율 설정 화면 (두 모드에서 같이 사용)
// - 서버 모드: 회원가입 두 번째 단계. email·password를 받아 서버에 가입 + 기본 카테고리 + 비율을 한 번에 저장
// - 로컬 모드: 앱 첫 실행 화면. email 없이 열리고, 폰 안 DB에 기본 카테고리 + 비율을 저장한 뒤 홈으로

import 'package:flutter/material.dart';
import 'package:moa/data/app_repositories.dart';
import 'package:moa/screens/shell_screen.dart';
import 'package:moa/utils/api_error.dart';
import 'package:moa/constants/colors.dart';
import 'package:moa/constants/styles.dart';
import 'package:moa/services/auth_service.dart';

class SignupBudgetScreen extends StatefulWidget {
  final String? email; // null이면 로컬 모드 첫 실행 설정
  final String? password;

  const SignupBudgetScreen({super.key, this.email, this.password});

  // 로컬 첫 실행 설정인지 (서버 가입 흐름이면 이메일이 있음)
  bool get isLocalSetup => email == null;

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
                }),
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
                              if (widget.isLocalSetup) {
                                // 로컬: 폰 안 DB에 기본 카테고리 + 이번 달 비율 저장 (하나의 트랜잭션)
                                await AppRepositories.setup.createInitial(
                                  categories: categories
                                      .map(
                                        (c) => (
                                          name: c['name'] as String,
                                          // 체크 상태는 categories가 아니라 includeInDaily 맵에 저장되어 있음
                                          includeInDaily:
                                              includeInDaily[c['name']] ?? false,
                                          ratio: c['ratio'] as int,
                                        ),
                                      )
                                      .toList(),
                                  savingRatio: savingRatio,
                                  investRatio: investRatio,
                                );
                                if (!context.mounted) return;
                                // 설정 끝 → 홈. 이전 화면이 없으므로 스택을 홈으로 교체
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => ShellScreen()),
                                  (route) => false,
                                );
                                return;
                              }

                              // 서버: 회원가입 + 기본 카테고리 + 비율을 서버에 한 번에 저장
                              await _authService.signUp(
                                email: widget.email!,
                                password: widget.password!,
                                savingRatio: savingRatio,
                                investRatio: investRatio,
                                categories: categories
                                    .map(
                                      (c) => <String, dynamic>{
                                        'name': c['name'],
                                        // 체크 상태는 categories가 아니라 includeInDaily 맵에 저장되어 있음
                                        'includeInDaily':
                                            includeInDaily[c['name']] ?? false,
                                        'ratio': c['ratio'],
                                      },
                                    )
                                    .toList(),
                              );

                              if (mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  // 가입 응답으로 받은 토큰이 이미 저장됨 → 다시 로그인할 필요 없이 바로 홈
                                  MaterialPageRoute(builder: (context) => ShellScreen()),
                                  (route) => false,
                                );
                              }
                            } catch (e) {
                              // 서버가 보낸 {"message": "..."} 를 그대로 표시 (예: "이미 사용 중인 이메일입니다.")
                              final message = apiErrorMessage(e, '회원가입에 실패했어요.');

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(message)));
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
                        : Text(widget.isLocalSetup ? '시작하기' : '완료'),
                  ),
                ),
                // 로컬 첫 실행은 돌아갈 이전 화면이 없음 (누르면 빈 화면이 됨) → 숨김
                if (!widget.isLocalSetup)
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
