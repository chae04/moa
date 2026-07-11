import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moa/models/transaction_model.dart';
import 'package:moa/services/transaction_service.dart';

class TransactionFormScreen extends StatefulWidget {
  final TransactionModel? transaction; // null이면 새 거래 추가, 있으면 기존 거래 수정
  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionFormScreen> {
  final transactionPrice = TextEditingController();
  final transactionName = TextEditingController();
  final transactionMemo = TextEditingController();
  final TransactionService _transactionService = TransactionService();

  // 드롭박스 아이템 목록
  List<String> transactionTypeList = ['수입', '지출', '저축'];
  List<String> budgetCategoryList = ['생활비', '자유비', '저축']; // dart format off
  List<String> transactionCategoryList = ['월급', '용돈', '식비', '교통', '쇼핑', '구독', '취미', '기타']; // dart format on

  // 기본값 지정 및 선택된 값 저장 변수
  String selectedTransactionType = '지출';
  String selectedTransactionCategory = '식비';
  String selectedBudgetCategory = '생활비';
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 수정 모드면 기존 값 채우기
    if (widget.transaction != null) {
      transactionName.text = widget.transaction!.title;
      transactionPrice.text = widget.transaction!.amount.toString();
      selectedTransactionType = widget.transaction!.type;
      selectedTransactionCategory = widget.transaction!.category;
      selectedBudgetCategory = widget.transaction!.budgetCategory ?? '생활비'; // null일 때 기본값
      selectedDate = widget.transaction!.date;
      transactionMemo.text = widget.transaction!.memo ?? ''; // null일 때 기본값
    }
  }

  // 날짜 선택 함수
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2026),
      lastDate: DateTime(DateTime.now().year + 2, 12, 31),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
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
                        return DropdownMenuItem<String>(value: value, child: Text(value));
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
                      items: transactionCategoryList.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
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

                if (selectedTransactionType != '수입')
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

                SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: '날짜'),
                    child: Text(
                      '${selectedDate.year}.${selectedDate.month}.${selectedDate.day}',
                    ),
                  ),
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
                    onPressed: () async {
                      final transaction = TransactionModel(
                        // ?: null 허용, ??: null일 때 기본값
                        id: widget.transaction?.id ?? '', // 수정 모드면 기존 id, 추가 모드면 빈 문자열
                        userId: FirebaseAuth.instance.currentUser!.uid,
                        title: transactionName.text,
                        amount: int.parse(transactionPrice.text),
                        type: selectedTransactionType,
                        category: selectedTransactionCategory,
                        budgetCategory: selectedTransactionType == '수입'
                            ? null
                            : selectedBudgetCategory,
                        date: selectedDate,
                        memo: transactionMemo.text,
                        createdAt: DateTime.now(),
                      );
                      // Firestore에 저장
                      if (widget.transaction == null) {
                        // 새 거래 추가 모드
                        await _transactionService.addTransaction(transaction);
                      } else {
                        // 기존 거래 수정 모드
                        await _transactionService.updateTransaction(transaction);
                      }
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
