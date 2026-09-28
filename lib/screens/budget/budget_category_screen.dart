import 'package:flutter/material.dart';
import 'package:moa/constants/colors.dart';
import 'package:moa/constants/styles.dart';
import 'package:moa/models/budget_category_model.dart';
import 'package:moa/services/budget_category_service.dart';
import 'package:moa/screens/budget/budget_form_screen.dart';

class BudgetCategoryScreen extends StatefulWidget {
  const BudgetCategoryScreen({super.key});

  @override
  State<BudgetCategoryScreen> createState() => _BudgetCategoryScreenState();
}

class _BudgetCategoryScreenState extends State<BudgetCategoryScreen> {
  final BudgetCategoryService _budgetCategoryService = BudgetCategoryService();
  List<BudgetCategoryModel> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await _budgetCategoryService.getCategories();
    setState(() {
      categories = cats;
      isLoading = false;
    });
  }

  // 카테고리 추가/수정 다이얼로그
  Future<void> _showCategoryDialog({BudgetCategoryModel? category}) async {
    final controller = TextEditingController(text: category?.name ?? '');
    bool showOnHome = category?.showOnHome ?? false;
    final isEdit = category != null;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text(isEdit ? '카테고리 수정' : '카테고리 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: inputDecoration('카테고리 이름'),
                autofocus: true,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: showOnHome,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      setDialogState(() => showOnHome = value!);
                    },
                  ),
                  Text('홈화면에 표시', style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('취소')),
            TextButton(
              onPressed: () async {
                if (controller.text.isEmpty) return;

                // 홈화면 5개 제한
                if (showOnHome &&
                    !(category?.showOnHome ?? false) &&
                    categories.where((c) => c.showOnHome).length >= 5) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('홈화면에는 최대 5개까지 표시할 수 있어요')));
                  return;
                }

                if (isEdit) {
                  category!.name = controller.text;
                  category.showOnHome = showOnHome;
                  await _budgetCategoryService.updateCategory(category);
                } else {
                  final newCategory = BudgetCategoryModel(
                    id: '',
                    userId: '',
                    name: controller.text,
                    order: categories.length,
                    includeInDaily: false,
                    showOnHome: showOnHome,
                  );
                  await _budgetCategoryService.addCategory(newCategory);
                }

                // 카테고리 추가하면 예산 비율 설정 폼으로 안내
                if (!isEdit) {
                  Navigator.pop(context);
                  await _loadCategories();
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BudgetFormScreen()),
                    ).then((_) => _loadCategories());
                  }
                } else {
                  // 수정은 그냥 닫기
                  Navigator.pop(context);
                  await _loadCategories();
                }
              },
              child: Text(isEdit ? '수정' : '추가', style: TextStyle(color: primaryColor)),
            ),
          ],
        ),
      ),
    );
  }

  // 카테고리 삭제
  Future<void> _deleteCategory(BudgetCategoryModel category) async {
    // 최소 1개 유지
    if (categories.length <= 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('최소 1개의 카테고리가 필요합니다.')));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('카테고리 삭제'),
        content: Text('${category.name}을(를) 삭제할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _budgetCategoryService.deleteCategory(category.id);
      await _loadCategories();
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BudgetFormScreen()),
        ).then((_) => _loadCategories());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 60.0, bottom: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24),

            // 상단 타이틀 + 추가 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  '예산 카테고리',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _showCategoryDialog,
                  icon: Icon(Icons.add, size: 16),
                  label: Text('추가'),
                ),
              ],
            ),
            SizedBox(height: 10),

            // 카테고리 목록
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.separated(
                      itemCount: categories.length,
                      separatorBuilder: (context, index) =>
                          Divider(color: Colors.grey[200]),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return ListTile(
                          leading: GestureDetector(
                            onTap: () async {
                              if (!category.showOnHome &&
                                  categories.where((c) => c.showOnHome).length >= 5) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('홈화면에는 최대 5개까지 표시할 수 있어요')),
                                );
                                return;
                              }
                              category.showOnHome = !category.showOnHome;
                              await _budgetCategoryService.updateCategory(category);
                              _loadCategories();
                            },
                            child: Icon(
                              Icons.label,
                              color: category.showOnHome
                                  ? primaryColor
                                  : Colors.grey[300],
                            ),
                          ),
                          title: Text(category.name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _showCategoryDialog(category: category),
                                icon: Icon(Icons.edit_outlined, color: Colors.grey),
                              ),
                              IconButton(
                                onPressed: () => _deleteCategory(category),
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
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('돌아가기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
