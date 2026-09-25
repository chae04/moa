import 'package:flutter/material.dart';
import 'package:moa/constants/colors.dart';
import 'package:moa/models/budget_category_model.dart';
import 'package:moa/models/budget_model.dart';
import 'package:moa/services/budget_category_service.dart';
import 'package:moa/services/budget_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moa/constants/styles.dart';

class BudgetFormScreen extends StatefulWidget {
  BudgetFormScreen({super.key});

  @override
  State<BudgetFormScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetFormScreen> {
  final BudgetService _budgetService = BudgetService();
  final BudgetCategoryService _budgetCategoryService = BudgetCategoryService();

  List<BudgetCategoryModel> categories = [];
  Map<String, int> budgetRatios = {};
  Map<String, bool> includeInDaily = {};
  Map<String, TextEditingController> controllers = {};
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
      }

      // 기존 비율 채우기
      if (userBudget != null) {
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

                  // 카테고리별 비율 입력
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: SizedBox()),
                          Text(
                            '일일 예산',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
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
                                  controller: controllers[category.id],
                                  decoration: inputDecoration('${category.name} (%)'),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      budgetRatios[category.id] =
                                          int.tryParse(value) ?? 0;
                                    });
                                  },
                                ),
                              ),
                              Checkbox(
                                value: includeInDaily[category.id] ?? false,
                                activeColor: primaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    includeInDaily[category.id] = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),

                  // 버튼
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final totalRatio = budgetRatios.values.fold(
                              0,
                              (sum, v) => sum + v,
                            );

                            if (totalRatio != 100) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('비율 합계가 100%가 되어야 합니다. 현재: $totalRatio'),
                                ),
                              );
                              return;
                            }

                            // categories 배열로 변환
                            final List<Map<String, dynamic>> cats = categories.map((c) {
                              return <String, dynamic>{
                                'categoryId': c.id,
                                'name': c.name,
                                'ratio': budgetRatios[c.id] ?? 0,
                                'amount': 0,
                                'includeInDaily': includeInDaily[c.id] ?? false,
                              };
                            }).toList();

                            // BudgetModel 생성
                            final budget = BudgetModel(
                              userId: FirebaseAuth.instance.currentUser!.uid,
                              month: selectedMonth,
                              categories: cats, // cats 사용
                            );

                            await _budgetService.setBudget(budget);
                            await _budgetService.setUserBudget(budget);

                            if (mounted) Navigator.pop(context);
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
