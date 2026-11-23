// [역할] 마이페이지
// - 공통: 예산 설정, 예산 카테고리 관리
// - 서버 모드: 내 이메일, 로그아웃, 회원탈퇴
// - 로컬 모드: 로그인이 없으므로 위 셋 대신 "이 기기에 저장" 안내 + 백업 내보내기/가져오기

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:moa/app_mode.dart';
import 'package:moa/data/app_repositories.dart';
import 'package:moa/screens/shell_screen.dart';
import 'package:moa/utils/api_error.dart';
import 'package:moa/constants/colors.dart';
import 'package:moa/services/auth_service.dart';
import 'package:moa/screens/auth/login_screen.dart';
import 'package:moa/screens/budget/budget_form_screen.dart';
import 'package:moa/screens/budget/budget_category_screen.dart';
import 'package:moa/screens/budget/entry_category_screen.dart';
import 'package:moa/services/user_service.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
    if (!isLocalMode) _loadEmail(); // 서버 모드: 화면이 처음 만들어질 때 한 번 서버에서 이메일 가져오기
  }

  // ---- 로컬 모드 백업 ----

  // 모든 데이터를 JSON 파일로 만들어 공유 시트로 내보내기 (파일 앱·드라이브·카톡 나에게 등으로 저장)
  Future<void> _exportBackup() async {
    try {
      final json = await AppRepositories.backup.exportJson();
      final now = DateTime.now();
      final stamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      // 임시 폴더에 파일을 만든 뒤 공유 (공유가 끝나면 OS가 정리)
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/moa_backup_$stamp.json');
      await file.writeAsString(json);

      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?; // 아이패드 공유 시트 위치 (아이폰에서는 무시됨)
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          subject: 'Moa 백업 $stamp',
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiErrorMessage(e, '백업 파일을 만들지 못했어요.'))));
    }
  }

  // 백업 파일을 골라서 지금 데이터를 통째로 교체
  Future<void> _importBackup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('백업 가져오기'),
        content: Text('지금 이 기기에 있는 데이터가 모두 지워지고\n백업 파일의 내용으로 바뀝니다.\n계속할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('가져오기', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (files.isEmpty) return; // 고르지 않고 닫음
      final json = await files.first.xFile.readAsString();
      await AppRepositories.backup.importJson(json);

      if (!mounted) return;
      // 모든 화면이 새 데이터를 다시 읽도록 홈부터 새로 시작
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ShellScreen()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('백업을 가져왔어요.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiErrorMessage(e, '백업을 가져오지 못했어요.'))));
    }
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
                        backgroundColor: primaryColor.withValues(alpha: 0.2),
                        child: Icon(Icons.person, color: primaryColor),
                      ),
                      SizedBox(width: 12),
                      Text(
                        // 서버 모드: 서버에서 받아 온 이메일 / 로컬 모드: 계정이 없으므로 저장 위치 안내
                        isLocalMode ? '이 기기에 저장된 가계부' : email,
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
                // 수입·지출 카테고리 관리 (서버 모드는 고정 목록이라 숨김)
                if (AppRepositories.entryCategories.isEditable)
                  _buildMenuItem(
                    icon: Icons.sell_outlined,
                    label: '수입·지출 카테고리 관리',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EntryCategoryScreen()),
                      );
                    },
                  ),
                Divider(),

                // 로컬 모드: 백업 (폰을 바꾸거나 앱을 지우면 데이터가 사라지므로)
                if (isLocalMode) ...[
                  _buildMenuItem(
                    icon: Icons.upload_file,
                    label: '백업 내보내기',
                    onTap: _exportBackup,
                  ),
                  _buildMenuItem(
                    icon: Icons.download,
                    label: '백업 가져오기',
                    onTap: _importBackup,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      '데이터는 이 기기에만 저장돼요. 앱을 지우거나 기기를 바꾸기 전에 백업을 내보내 두세요.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ),
                ],

                // 서버 모드: 계정 메뉴 (로그아웃, 회원탈퇴)
                if (!isLocalMode) ...[
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
                                  child: Text(
                                    '확인',
                                    style: TextStyle(color: primaryColor),
                                  ),
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
                          } catch (e) {
                            // 서버가 보낸 {"message": "..."} 를 그대로 표시 (예: "비밀번호가 올바르지 않습니다.")
                            final message = apiErrorMessage(e, '탈퇴 실패');
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
                ], // 서버 모드 계정 메뉴 끝
                SizedBox(height: 24),
              ],
            ),
          ),

          // 로딩 오버레이
          if (isDeleting)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
