import 'package:flutter/material.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key});

  @override
  State<TransactionFormScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionFormScreen> {
  final transactionPrice = TextEditingController();
  final transactionName = TextEditingController();
  final transactionType = TextEditingController();
  final transactionCategory = TextEditingController();
  final budgetCategory = TextEditingController();
  final transactionDate = TextEditingController();
  final transactionMemo = TextEditingController();

  List<String> transactionTypeList = ['수입', '지출', '저축'];
  String selectedTransactionType = '지출'; // 기본값

  List<String> transactionCategoryList = [
    '월급',
    '용돈',
    '식비',
    '교통',
    '쇼핑',
    '구독',
    '취미',
    '기타',
  ];
  String selectedTransactionCategory = '식비';

  List<String> budgetCategoryList = ['생활비', '자유비', '저축'];
  String selectedBudgetCategory = '생활비';

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
                '거래 입력 폼',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            Column(
              children: [
                TextField(
                  controller: transactionPrice,
                  decoration: InputDecoration(labelText: '금액'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: transactionName,
                  decoration: InputDecoration(labelText: '거래명'),
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 20),

                InputDecorator(
                  decoration: InputDecoration(labelText: '유형'),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      isDense: true,
                      items: transactionTypeList.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      value: selectedTransactionType,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedTransactionType = newValue!;
                        });
                      },
                    ),
                  ),
                ),

                SizedBox(height: 20),
                InputDecorator(
                  decoration: InputDecoration(labelText: '카테고리'),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      isDense: true,
                      items: transactionCategoryList
                          .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          })
                          .toList(),
                      value: selectedTransactionCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedTransactionCategory = newValue!;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                InputDecorator(
                  decoration: InputDecoration(labelText: '예산 카테고리'),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      isDense: true,
                      items: budgetCategoryList.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      value: selectedBudgetCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedBudgetCategory = newValue!;
                        });
                      },
                    ),
                  ),
                ),
                TextField(
                  controller: transactionDate,
                  decoration: InputDecoration(labelText: '날짜'),
                  keyboardType: TextInputType.datetime,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: transactionMemo,
                  decoration: InputDecoration(labelText: '메모'),
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                ),
              ],
            ),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
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
                    child: Text('홈'),
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
