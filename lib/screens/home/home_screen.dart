import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalIncome = 0; // 총 수입
  int totalExpense = 0; // 총 지출
  int totalSaving = 0; // 총 저축

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

  // 카테고리별 예산
  Map<String, int> budgetByCategory = {
    '생활비': 0,
    '저축': 0,
    '행복비': 0,
    '교통비': 0,
    '투자': 0,
  };

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
                Text('수입: $totalIncome'),
                Text('지출: $totalExpense'),
                Text('저축: $totalSaving'),
              ],
            ),

            Column(
              children: [
                LinearProgressIndicator(
                  value: budgetByCategory['생활비'] == 0
                      ? 0
                      : (expenseByCategory['식비']! +
                                expenseByCategory['쇼핑']! +
                                expenseByCategory['고정비']! +
                                expenseByCategory['구독']!) /
                            budgetByCategory['생활비']!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
