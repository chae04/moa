import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moa/models/transaction_model.dart';
import 'package:moa/services/transaction_service.dart';
import 'package:moa/services/budget_service.dart';
import 'package:moa/constants/categories.dart';

class TransactionFormScreen extends StatefulWidget {
  final TransactionModel? transaction; // null이면 새 거래 추가, 있으면 기존 거래 수정
  final String? type; // 거래 유형 (수입/지출/저축) - 유형 선택 화면에서 넘어올 때 사용
  final DateTime? date;
  const TransactionFormScreen({super.key, this.transaction, this.type, this.date});

  @override
  State<TransactionFormScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionFormScreen> {
  final transactionPrice = TextEditingController();
  final transactionName = TextEditingController();
  final transactionMemo = TextEditingController();
  final TransactionService _transactionService = TransactionService();
  final BudgetService _budgetService = BudgetService();

  // 선택된 유형에 맞는 카테고리 목록 반환
  List<String> get currentCategoryList =>
      selectedTransactionType == '수입' ? incomeCategoryList : expenseCategoryList;

  // 기본값 지정 및 선택된 값 저장 변수
  String selectedTransactionType = '지출';
  String selectedTransactionCategory = '식비';
  String selectedBudgetCategory = '생활비';
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 유형 선택 화면에서 넘어온 경우
    if (widget.type != null) {
      selectedTransactionType = widget.type!;
      if (widget.type == '수입') {
        selectedTransactionCategory = incomeCategoryList[0]; // 월급
      } else if (widget.type == '지출') {
        selectedTransactionCategory = expenseCategoryList[0]; // 식비
      } // 저축은 카테고리 없으니까 초기화 불필요
    }

    if (widget.date != null) {
      selectedDate = widget.date!;
    }

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
                          // 유형 바꾸면 카테고리 초기화
                          selectedTransactionCategory = newValue == '수입'
                              ? incomeCategoryList[0]
                              : expenseCategoryList[0];
                        });
                      },
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // 카테고리 드롭다운 (저축이면 숨김)
                if (selectedTransactionType != '저축')
                  InputDecorator(
                    decoration: InputDecoration(labelText: '카테고리'),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        isDense: true,
                        items: currentCategoryList.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
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

                // 예산 카테고리 드롭다운 (지출일 때만 표시)
                if (selectedTransactionType == '지출')
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

                // 날짜 선택
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

                // 메모
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
                // 저장 버튼
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
                            ? null // 수입은 예산 카테고리 없음
                            : selectedBudgetCategory == '저축'
                            ? '저축' // 저축이면 자동으로 저축 예산으로
                            : selectedBudgetCategory, // 지출이면 사용자가 선택한 예산 카테고리
                        date: selectedDate,
                        memo: transactionMemo.text,
                        createdAt: DateTime.now(),
                      );

                      // 수입이면 예산 amount 업데이트
                      if (selectedTransactionType == '수입') {
                        final now = DateTime.now();
                        final month =
                            '${now.year}-${now.month.toString().padLeft(2, '0')}';

                        // 이번 달 거래 목록 불러오기
                        final transactions = await _transactionService
                            .getMonthlyTransactions(now.year, now.month);

                        // 이번 달 수입 합계 계산
                        final totalIncome =
                            transactions
                                .where((t) => t.type == '수입')
                                .fold(0, (sum, t) => sum + t.amount) +
                            int.parse(transactionPrice.text);

                        await _budgetService.updateBudgetAmount(month, totalIncome);
                      }

                      // Firestore에 저장 (추가 or 수정)
                      if (widget.transaction == null) {
                        // 새 거래 추가 모드
                        await _transactionService.addTransaction(transaction);
                      } else {
                        // 기존 거래 수정 모드
                        await _transactionService.updateTransaction(transaction);
                      }
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: Text('저장'),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
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
