import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moa/models/budget_category_model.dart';
import 'package:moa/models/transaction_model.dart';
import 'package:moa/services/budget_category_service.dart';
import 'package:moa/services/transaction_service.dart';
import 'package:moa/constants/categories.dart';
import 'package:moa/constants/colors.dart';
import 'package:moa/constants/styles.dart';
import 'package:moa/services/budget_service.dart';

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
  final BudgetService _budgetService = BudgetService(); // 수입 저장할 때 저축 자동 생성
  final TransactionService _transactionService = TransactionService();

  List<BudgetCategoryModel> budgetCategories = [];
  final BudgetCategoryService _budgetCategoryService = BudgetCategoryService();

  final _nameFocus = FocusNode();
  final _memoFocus = FocusNode();

  bool isLoading = false;

  // 선택된 유형에 맞는 카테고리 목록 반환
  List<String> get currentCategoryList =>
      selectedTransactionType == '수입' ? incomeCategoryList : expenseCategoryList;

  // 기본값 지정 및 선택된 값 저장 변수
  String selectedTransactionType = '지출';
  String selectedTransactionCategory = '식비';
  DateTime selectedDate = DateTime.now();

  String selectedBudgetCategoryId = '';

  @override
  void initState() {
    super.initState();
    _loadBudgetCategories();
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
      selectedBudgetCategoryId = widget.transaction!.budgetCategoryId ?? ''; // 변경
      selectedDate = widget.transaction!.date;
      transactionMemo.text = widget.transaction!.memo ?? ''; // null일 때 기본값
    }
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _memoFocus.dispose();
    super.dispose();
  }

  // 날짜 선택 함수
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        DateTime tempDate = selectedDate;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CalendarDatePicker(
                  initialDate: selectedDate,
                  firstDate: DateTime(2026),
                  lastDate: DateTime(DateTime.now().year + 2, 12, 31),
                  onDateChanged: (date) {
                    tempDate = date;
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('취소'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, tempDate),
                      child: Text('확인', style: TextStyle(color: primaryColor)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      primaryFocus?.unfocus();
    }
  }

  Future<void> _loadBudgetCategories() async {
    final cats = await _budgetCategoryService.getCategories();
    setState(() {
      budgetCategories = cats;
      if (cats.isNotEmpty) {
        selectedBudgetCategoryId = cats.first.id;
      }
    });
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
                widget.transaction != null ? '거래 수정' : (widget.type ?? '거래 추가'),
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            Column(
              children: [
                TextField(
                  controller: transactionPrice,
                  decoration: inputDecoration('금액'),
                  keyboardType: TextInputType.number,
                  autofocus: widget.transaction != null ? false : true,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_nameFocus),
                  readOnly: // 수입은 금액 수정 불가
                      widget.transaction != null && widget.transaction!.type == '수입',
                ),
                SizedBox(height: 20),
                TextField(
                  controller: transactionName,
                  decoration: inputDecoration('거래명'),
                  focusNode: _nameFocus,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_memoFocus),
                ),
                SizedBox(height: 20),

                if (widget.transaction != null) ...[
                  DropdownButtonFormField<String>(
                    decoration: inputDecoration('유형'),
                    value: selectedTransactionType,
                    dropdownColor: Colors.white, // 목록 배경색
                    borderRadius: BorderRadius.circular(12), // 목록 모서리
                    items: transactionTypeList.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedTransactionType = newValue!;
                        selectedTransactionCategory = newValue == '수입'
                            ? incomeCategoryList[0]
                            : expenseCategoryList[0];
                      });
                    },
                  ),
                  SizedBox(height: 20),
                ],

                // 카테고리 드롭다운 (저축이면 숨김)
                if (selectedTransactionType != '저축') ...[
                  DropdownButtonFormField<String>(
                    decoration: inputDecoration('카테고리'),
                    value: selectedTransactionCategory,
                    dropdownColor: Colors.white, // 목록 배경색
                    borderRadius: BorderRadius.circular(12), // 목록 모서리
                    items: currentCategoryList.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedTransactionCategory = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                ],

                // 저축일 때 차감할 예산 선택
                if (selectedTransactionType == '저축') ...[
                  DropdownButtonFormField(
                    decoration: inputDecoration('예산 출처'),
                    value: selectedBudgetCategoryId.isEmpty
                        ? null
                        : selectedBudgetCategoryId,
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    items: budgetCategories
                        .where((c) => c.name != '저축')
                        .map<DropdownMenuItem<String>>((c) {
                          return DropdownMenuItem<String>(
                            value: c.id,
                            child: Text(c.name, style: TextStyle(fontSize: 14)),
                          );
                        })
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedBudgetCategoryId = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                ],

                // 예산 카테고리 드롭다운 (지출일 때만 표시)
                if (selectedTransactionType == '지출') ...[
                  DropdownButtonFormField<String>(
                    decoration: inputDecoration('예산 카테고리'),
                    value: selectedBudgetCategoryId.isEmpty
                        ? null
                        : selectedBudgetCategoryId,
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    items: budgetCategories
                        .where((c) => c.name != '저축') // 저축 제외
                        .map<DropdownMenuItem<String>>((c) {
                          return DropdownMenuItem<String>(
                            value: c.id,
                            child: Text(c.name),
                          );
                        })
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedBudgetCategoryId = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                ],

                // 날짜 선택
                GestureDetector(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: InputDecorator(
                    decoration: inputDecoration('날짜'),
                    child: Text(
                      '${selectedDate.year}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // 메모
                TextField(
                  controller: transactionMemo,
                  decoration: inputDecoration('메모'),
                  keyboardType: TextInputType.multiline,
                  focusNode: _memoFocus,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                ),
              ],
            ),
            Column(
              children: [
                // 저장 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() => isLoading = true);
                            try {
                              final transaction = TransactionModel(
                                // ?: null 허용, ??: null일 때 기본값
                                id:
                                    widget.transaction?.id ??
                                    '', // 수정 모드면 기존 id, 추가 모드면 빈 문자열
                                userId: FirebaseAuth.instance.currentUser!.uid,
                                title: transactionName.text,
                                amount: int.parse(transactionPrice.text),
                                type: selectedTransactionType,
                                category: selectedTransactionType == '저축'
                                    ? '저축'
                                    : selectedTransactionCategory,
                                budgetCategoryId: selectedTransactionType == '수입'
                                    ? null
                                    : selectedTransactionType == '저축'
                                    ? budgetCategories
                                          .firstWhere((c) => c.name == '저축')
                                          .id
                                    : selectedBudgetCategoryId,
                                date: selectedDate,
                                memo: transactionMemo.text,
                                createdAt: DateTime.now(),
                              );

                              // Firestore에 저장 (추가 or 수정)
                              if (widget.transaction == null) {
                                // 새 거래 추가 모드
                                await _transactionService.addTransaction(transaction);

                                // 수입이면 설정된 비율만큼 저축 자동 생성
                                if (selectedTransactionType == '수입') {
                                  final userBudget = await _budgetService.getUserBudget();
                                  if (userBudget != null) {
                                    final savingCategory = userBudget.categories
                                        .firstWhere(
                                          (c) => c['name'] == '저축',
                                          orElse: () => {'ratio': 0},
                                        );
                                    final savingRatio = savingCategory['ratio'] as int;

                                    if (savingRatio > 0) {
                                      final savingAmount =
                                          (int.parse(transactionPrice.text) *
                                                  savingRatio /
                                                  100)
                                              .round();
                                      final savingTransaction = TransactionModel(
                                        id: '',
                                        title: '자동 저축',
                                        userId: FirebaseAuth.instance.currentUser!.uid,
                                        amount: savingAmount,
                                        type: '저축',
                                        category: '저축',
                                        budgetCategoryId: budgetCategories
                                            .firstWhere((c) => c.name == '저축')
                                            .id,
                                        date: selectedDate,
                                        memo: '수입의 $savingRatio 자동 저축',
                                        createdAt: DateTime.now(),
                                      );
                                      await _transactionService.addTransaction(
                                        savingTransaction,
                                      );
                                    }
                                  }
                                }
                              } else {
                                // 기존 거래 수정 모드
                                await _transactionService.updateTransaction(transaction);
                              }
                              Navigator.popUntil(context, (route) => route.isFirst);
                            } catch (e) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
                              if (mounted) setState(() => isLoading = false);
                            }
                          },
                    child: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text('저장'),
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
