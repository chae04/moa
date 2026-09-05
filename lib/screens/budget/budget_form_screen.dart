import 'package:flutter/material.dart';
import 'package:moa/models/budget_model.dart';
import 'package:moa/services/budget_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moa/services/transaction_service.dart';
import 'package:moa/constants/categories.dart';

class BudgetFormScreen extends StatefulWidget {
  final BudgetModel? budget; // null이면 새 예산 추가, 있으면 기존 예산 수정
  BudgetFormScreen({super.key, this.budget});

  @override
  State<BudgetFormScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetFormScreen> {
  final BudgetService _budgetService = BudgetService();
  final TransactionService _transactionService = TransactionService();
  // 예산 비율 초기값 : 0
  Map<String, int> budgetRatios = {for (var c in budgetCategoryList) c: 0};

  // 기본값 지정 및 선택된 값 저장 변수
  String selectedBudgetCategory = '생활비';
  String selectedMonth =
      '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

  // 월 목록 생성
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
    // 수정 모드면 기존 값 채우기
    if (widget.budget != null) {
      for (var c in widget.budget!.categories) {
        budgetRatios[c['category']] = c['ratio'];
      }
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
                '예산 비율 설정 폼',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            InputDecorator(
              decoration: InputDecoration(labelText: '적용 시작 월'),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedMonth,
                  items: getMonthList().map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      setState(() {
                        selectedMonth = newValue!;
                      });
                    });
                  },
                ),
              ),
            ),
            Column(
              // TextField 동적 생성
              children: budgetRatios.entries.map((entry) {
                return TextField(
                  decoration: InputDecoration(labelText: '${entry.key} (%)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      budgetRatios[entry.key] = int.tryParse(value) ?? 0;
                    });
                  },
                );
              }).toList(),
            ),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final totalRatio = budgetRatios.values.fold(0, (sum, v) => sum + v);

                      // budgetRatios를 categories 배열로 변환
                      final List<Map<String, dynamic>> categories = budgetRatios.entries
                          .map((e) {
                            return <String, dynamic>{
                              'category': e.key,
                              'ratio': e.value,
                              'amount': 0,
                            };
                          })
                          .toList();

                      // BudgetModel 생성
                      final budget = BudgetModel(
                        userId: FirebaseAuth.instance.currentUser!.uid,
                        month: selectedMonth,
                        categories: categories,
                      );

                      // 비율 합계 확인
                      if (totalRatio != 100) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('비율 합계가 100%가 되어야 합니다. 현재: $totalRatio'),
                          ),
                        );
                        return;
                      }

                      await _budgetService.setBudget(budget);
                      await _budgetService.setUserBudget(budget);

                      // 이번 달 수입 합계 가져와서 amount 업데이트
                      final now = DateTime.now();
                      final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
                      final transactions = await _transactionService
                          .getMonthlyTransactions(now.year, now.month);
                      final totalIncome = transactions
                          .where((t) => t.type == '수입')
                          .fold(0, (sum, t) => sum + t.amount);

                      if (totalIncome > 0) {
                        await _budgetService.updateBudgetAmount(month, totalIncome);
                      }

                      if (mounted) Navigator.pop(context);
                    },
                    child: Text('저장'),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
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
