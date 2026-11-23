// [역할] 수입·지출 카테고리 관리 화면 (월급, 식비 등. 마이페이지 → 수입·지출 카테고리 관리)
// - 탭: 지출 / 수입. 추가, 이름 변경, 삭제
// - 거래는 카테고리 이름을 그대로 저장하므로, 이름을 바꾸거나 지워도 지난 거래와 통계의 이름은 그대로
// - 로컬 모드 전용 (서버 모드는 고정 목록이라 마이페이지에서 메뉴를 숨김)

import 'package:flutter/material.dart';
import 'package:moa/constants/colors.dart';
import 'package:moa/constants/styles.dart';
import 'package:moa/data/app_repositories.dart';
import 'package:moa/models/entry_category_model.dart';
import 'package:moa/utils/api_error.dart';

class EntryCategoryScreen extends StatefulWidget {
  const EntryCategoryScreen({super.key});

  @override
  State<EntryCategoryScreen> createState() => _EntryCategoryScreenState();
}

class _EntryCategoryScreenState extends State<EntryCategoryScreen> {
  final _repo = AppRepositories.entryCategories;
  final Map<String, List<EntryCategoryModel>> _lists = {'지출': [], '수입': []};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final expense = await _repo.getCategories('지출');
      final income = await _repo.getCategories('수입');
      if (!mounted) return;
      setState(() {
        _lists['지출'] = expense;
        _lists['수입'] = income;
      });
    } catch (e) {
      _showError(e, '카테고리를 불러오지 못했어요.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(Object e, String fallback) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(apiErrorMessage(e, fallback))));
  }

  // 이름 입력 다이얼로그 (추가·변경 공용). 취소하면 null
  Future<String?> _askName({required String title, String initial = ''}) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: inputDecoration('카테고리 이름 (10자 이내)'),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text('저장', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }

  Future<void> _add(String kind) async {
    final name = await _askName(title: '$kind 카테고리 추가');
    if (name == null) return;
    try {
      await _repo.addCategory(kind, name);
      await _load();
    } catch (e) {
      _showError(e, '추가하지 못했어요.');
    }
  }

  Future<void> _rename(EntryCategoryModel c) async {
    final name = await _askName(title: '이름 바꾸기', initial: c.name);
    if (name == null || name.trim() == c.name) return;
    try {
      await _repo.renameCategory(c.id, name);
      await _load();
    } catch (e) {
      _showError(e, '이름을 바꾸지 못했어요.');
    }
  }

  Future<void> _delete(EntryCategoryModel c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('카테고리 삭제'),
        content: Text('${c.name}을(를) 삭제할까요?\n이미 기록한 거래의 카테고리 이름은 그대로 남아요.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _repo.deleteCategory(c.id);
      await _load();
    } catch (e) {
      _showError(e, '삭제하지 못했어요.');
    }
  }

  Widget _buildList(String kind) {
    final list = _lists[kind]!;
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: list.length,
            separatorBuilder: (context, index) => Divider(color: Colors.grey[200]),
            itemBuilder: (context, index) {
              final c = list[index];
              return ListTile(
                title: Text(c.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _rename(c),
                      icon: Icon(Icons.edit_outlined, color: Colors.grey),
                    ),
                    IconButton(
                      onPressed: () => _delete(c),
                      icon: Icon(Icons.delete_outline, color: primaryColor),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _add(kind),
            icon: Icon(Icons.add, size: 16),
            label: Text('$kind 카테고리 추가'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 60, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back),
                  ),
                  Text(
                    '수입·지출 카테고리',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TabBar(
                labelColor: primaryColor,
                indicatorColor: primaryColor,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: '지출'),
                  Tab(text: '수입'),
                ],
              ),
              Expanded(
                child: _loading
                    ? Center(child: CircularProgressIndicator())
                    : TabBarView(children: [_buildList('지출'), _buildList('수입')]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
