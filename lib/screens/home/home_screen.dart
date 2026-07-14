import 'package:flutter/material.dart';
import 'package:moa/screens/transaction/transaction_form_screen.dart';
import 'package:moa/screens/transaction/transaction_list_screen.dart';
import 'package:moa/services/transaction_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:moa/screens/budget/budget_form_screen.dart';
import 'package:moa/services/budget_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalIncome = 0; // 총 수입
  int totalExpense = 0; // 총 지출
  int totalSaving = 0; // 총 저축

  final TransactionService _transactionService = TransactionService();
  final BudgetService _budgetService = BudgetService();

  // 카테고리별 지출
  Map<String, int> expenseByCategory = {
    '식비': 0,
    '교통': 0,
    '쇼핑': 0,
    '구독': 0,
    '취미': 0,
    '고정비': 0,
    '기타': 0,
  };

  // 예산 카테고리별 사용 금액
  Map<String, int> usedByBudgetCategory = {
    '생활비': 0,
    '저축': 0,
    '자유비': 0,
    '교통비': 0,
    '투자': 0,
  };

  // 카테고리별 예산
  Map<String, int> budgetByCategory = {'생활비': 0, '저축': 0, '자유비': 0, '교통비': 0, '투자': 0};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final transactions = await _transactionService.getMonthlyTransactions(
      now.year,
      now.month,
    );

    setState(() {
      totalIncome = transactions
          .where((t) => t.type == '수입')
          .fold(0, (sum, t) => sum + t.amount);
      totalExpense = transactions
          .where((t) => t.type == '지출')
          .fold(0, (sum, t) => sum + t.amount);
      totalSaving = transactions
          .where((t) => t.type == '저축')
          .fold(0, (sum, t) => sum + t.amount);

      // usedByBudgetCategory 초기화
      usedByBudgetCategory = {'생활비': 0, '저축': 0, '자유비': 0, '교통비': 0, '투자': 0};

      for (var t in transactions) {
        if (t.budgetCategory != null) {
          usedByBudgetCategory[t.budgetCategory!] =
              (usedByBudgetCategory[t.budgetCategory!] ?? 0) + t.amount;
        }
      }
    });

    // 예산 데이터 불러오기
    final budget = await _budgetService.getBudget(month);
    if (budget != null) {
      print('categories: ${budget.categories}');

      setState(() {
        for (var c in budget.categories) {
          print('category: ${c['category']}, amount: ${c['amount']}');

          budgetByCategory[c['category']] = c['amount'];
        }
      });
    }
    print('budgetByCategory: $budgetByCategory');
    print('usedByBudgetCategory: $usedByBudgetCategory');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                SizedBox(
                  height: 400,
                  child: TableCalendar(
                    // 2026/01/01부터 2년 뒤 12/31까지 표시
                    firstDay: DateTime.utc(2026, 1, 1),
                    lastDay: DateTime(DateTime.now().year + 2, 12, 31),
                    focusedDay: DateTime.now(),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text('수입: $totalIncome'),
                Text('지출: $totalExpense'),
                Text('저축: $totalSaving'),
              ],
            ),
            Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Text('생활비'),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: budgetByCategory['생활비'] == 0
                            ? 0
                            : usedByBudgetCategory['생활비']! / budgetByCategory['생활비']!,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Text('교통비'),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: budgetByCategory['교통비'] == 0
                            ? 0
                            : usedByBudgetCategory['교통비']! / budgetByCategory['교통비']!,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Text('생활비'),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: budgetByCategory['자유비'] == 0
                            ? 0
                            : usedByBudgetCategory['자유비']! / budgetByCategory['자유비']!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransactionFormScreen(),
                        ),
                      ).then((_) => _loadData());
                    },
                    child: Text('거래 추가'),
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransactionListScreen(),
                        ),
                      ).then((_) => _loadData());
                    },
                    child: Text('거래 목록'),
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BudgetFormScreen()),
                      ).then((_) => _loadData());
                    },
                    child: Text('예산 설정'),
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
