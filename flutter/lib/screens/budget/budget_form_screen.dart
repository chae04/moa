import 'package:flutter/material.dart';
import 'package:moa/constants/colors.dart';
import 'package:moa/models/budget_category_model.dart';
import 'package:moa/models/budget_model.dart';
import 'package:moa/services/budget_category_service.dart';
import 'package:moa/services/budget_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moa/constants/styles.dart';

class BudgetFormScreen extends StatefulWidget {
  final String? deleteCategoryId; // 삭제할 카테고리 ID
  BudgetFormScreen({super.key, this.deleteCategoryId});
  @override
  State<BudgetFormScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetFormScreen> {
  final BudgetService _budgetService = BudgetService();
  final BudgetCategoryService _budgetCategoryService = BudgetCategoryService();
  Map<String, bool> showOnHome = {};

  List<BudgetCategoryModel> categories = [];
  Map<String, int> budgetRatios = {};
  Map<String, bool> includeInDaily = {};
  Map<String, TextEditingController> controllers = {};
  final savingRatioController = TextEditingController();
  final investRatioController = TextEditingController();
  int savingRatio = 0;
  int investRatio = 0;

  bool isLoading = true;

  String selectedMonth =
      '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

  List<String> getMonthList() {
    final now = DateTime.now();
    return List.generate(12, (i) {
      final month = DateTime(now.year, now.month + i);
      return '${month.year}-${month.month.toString().padLeft(2, '0')}';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await _budgetCategoryService.getCategories();
    final userBudget = await _budgetService.getUserBudget();

    setState(() {
      categories = cats;
      for (var c in cats) {
        budgetRatios[c.id] = 0;
        includeInDaily[c.id] = c.includeInDaily;
        controllers[c.id] = TextEditingController();
        showOnHome[c.id] = c.showOnHome;
      }

      // 기존 비율 채우기
      if (userBudget != null) {
        savingRatio = userBudget.savingRatio;
        investRatio = userBudget.investRatio;
        savingRatioController.text = userBudget.savingRatio.toString();
        investRatioController.text = userBudget.investRatio.toString();
        for (var c in userBudget.categories) {
          final categoryId = c['categoryId'] as String?;
          if (categoryId != null) {
            budgetRatios[categoryId] = c['ratio'] ?? 0;
            controllers[categoryId]?.text = (c['ratio'] ?? 0).toString();
            includeInDaily[categoryId] = c['includeInDaily'] ?? false;
          }
        }
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
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

                  // 적용 시작 월
                  InputDecorator(
                    decoration: InputDecoration(labelText: '적용 시작 월'),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedMonth,
                        items: getMonthList().map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedMonth = newValue!;
                          });
                        },
                      ),
                    ),
                  ),

                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: false,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 20, bottom: 20, right: 10),
                        child: Column(
                          children: [
                            // 카테고리별 비율 입력
                            Column(
                              children: [
                                SizedBox(height: 8),
                                ...categories
                                    .where((c) => c.id != widget.deleteCategoryId)
                                    .map((category) {
                                      return Padding(
                                        padding: EdgeInsets.only(bottom: 15),
                                        child: Row(
                                          children: [
                                            // 카테고리 이름 (고정 너비)
                                            SizedBox(
                                              width: 60,
                                              child: Text(
                                                category.name,
                                                style: TextStyle(fontSize: 13),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            // 비율 입력 (짧게)
                                            Expanded(
                                              child: TextField(
                                                controller: controllers[category.id],
                                                decoration: inputDecoration('%'),
                                                keyboardType: TextInputType.number,
                                                onChanged: (value) {
                                                  setState(() {
                                                    budgetRatios[category.id] =
                                                        int.tryParse(value) ?? 0;
                                                  });
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 10),

                                            // 일일 예산 체크박스
                                            GestureDetector(
                                              onTap: () {
                                                setState(
                                                  () => includeInDaily[category.id] =
                                                      !(includeInDaily[category.id] ??
                                                          false),
                                                );
                                              },

                                              child: Icon(
                                                (includeInDaily[category.id] ?? false)
                                                    ? Icons.calendar_month
                                                    : Icons.calendar_month_outlined,
                                                color:
                                                    (includeInDaily[category.id] ?? false)
                                                    ? primaryColor
                                                    : Colors.grey[300],
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            // 홈화면 표시
                                            GestureDetector(
                                              onTap: () {
                                                final currentShowOnHome =
                                                    showOnHome[category.id] ?? false;
                                                if (!currentShowOnHome &&
                                                    showOnHome.values
                                                            .where((v) => v)
                                                            .length >=
                                                        5) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        '홈화면에는 최대 5개까지 표시할 수 있어요',
                                                      ),
                                                    ),
                                                  );
                                                  return;
                                                }
                                                setState(
                                                  () => showOnHome[category.id] =
                                                      !currentShowOnHome,
                                                );
                                              },
                                              child: Icon(
                                                (showOnHome[category.id] ?? false)
                                                    ? Icons.home
                                                    : Icons.home_outlined,
                                                color: (showOnHome[category.id] ?? false)
                                                    ? primaryColor
                                                    : Colors.grey[300],
                                              ),
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
                                      SizedBox(
                                        width: 60,
                                        child: Text('저축', style: TextStyle(fontSize: 13)),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: savingRatioController,
                                          decoration: inputDecoration('%'),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            setState(
                                              () =>
                                                  savingRatio = int.tryParse(value) ?? 0,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 60,
                                        child: Text('투자', style: TextStyle(fontSize: 13)),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: investRatioController,
                                          decoration: inputDecoration('%'),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            setState(
                                              () =>
                                                  investRatio = int.tryParse(value) ?? 0,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 버튼
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final totalRatio =
                                budgetRatios.entries
                                    .where(
                                      (e) => e.key != widget.deleteCategoryId,
                                    ) // 삭제 예정 카테고리 제외
                                    .fold(0, (sum, e) => sum + e.value) +
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

                            // categories 배열로 변환
                            final List<Map<String, dynamic>> cats = categories
                                .where(
                                  (c) => c.id != widget.deleteCategoryId,
                                ) // 삭제 예정 카테고리 제외
                                .map((c) {
                                  return <String, dynamic>{
                                    'categoryId': c.id,
                                    'name': c.name,
                                    'ratio': budgetRatios[c.id] ?? 0,
                                    'amount': 0,
                                    'includeInDaily': includeInDaily[c.id] ?? false,
                                  };
                                })
                                .toList();

                            // BudgetModel 생성
                            final budget = BudgetModel(
                              userId: FirebaseAuth.instance.currentUser!.uid,
                              month: selectedMonth,
                              categories: cats, // cats 사용
                              savingRatio: savingRatio,
                              investRatio: investRatio,
                            );

                            // BudgetModel 저장
                            await _budgetService.setBudget(budget);
                            await _budgetService.setUserBudget(budget);

                            if (widget.deleteCategoryId != null) {
                              await _budgetCategoryService.deleteCategory(
                                widget.deleteCategoryId!,
                              );
                            }

                            // showOnHome, includeInDaily 업데이트
                            for (var c in categories) {
                              c.showOnHome = showOnHome[c.id] ?? false;
                              c.includeInDaily = includeInDaily[c.id] ?? false;
                              await _budgetCategoryService.updateCategory(c);
                            }

                            if (mounted) {
                              Navigator.pop(context);
                            }
                          },
                          child: Text('저장'),
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
