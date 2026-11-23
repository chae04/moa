import 'package:flutter/material.dart';
import 'package:moa/utils/api_error.dart';
import 'package:moa/models/budget_category_model.dart';
import 'package:moa/models/transaction_model.dart';
import 'package:moa/data/app_repositories.dart'; // 모드(로컬/서버)에 맞는 저장소
import 'package:moa/data/repositories.dart';
import 'package:moa/app_mode.dart';
import 'package:moa/constants/categories.dart';
import 'package:moa/constants/colors.dart';
import 'package:moa/constants/styles.dart';

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
  final TransactionRepository _transactionService = AppRepositories.transactions;

  List<BudgetCategoryModel> budgetCategories = [];
  final CategoryRepository _budgetCategoryService = AppRepositories.categories;

  final _nameFocus = FocusNode();
  final _memoFocus = FocusNode();

  bool isLoading = false;

  // 수입·지출 카테고리 이름 목록 (로컬: 사용자가 관리하는 목록 / 서버: 고정 목록). 불러오기 전에는 빈 목록
  List<String> incomeCategories = [];
  List<String> expenseCategories = [];
  bool entryCategoriesLoaded = false;

  // 선택된 유형에 맞는 카테고리 목록 반환
  // 수정하는 거래의 카테고리가 지금 목록에 없으면(이름을 바꿨거나 지움) 그 이름도 넣어 줌 → Dropdown 크래시 방지
  List<String> get currentCategoryList {
    final list = [
      ...(selectedTransactionType == '수입' ? incomeCategories : expenseCategories),
    ];
    if (selectedTransactionCategory.isNotEmpty &&
        !list.contains(selectedTransactionCategory)) {
      list.add(selectedTransactionCategory);
    }
    return list;
  }

  // 지출의 예산 출처 드롭다운에서 "모아 둔 돈에서 꺼내 쓰기"를 나타내는 특별한 값 (실제 카테고리 id는 1부터라 겹치지 않음)
  static const int fromSaving = -1; // 저축에서
  static const int fromInvest = -2; // 투자에서

  // 기본값 지정 및 선택된 값 저장 변수
  String selectedTransactionType = '지출';
  String selectedTransactionCategory = ''; // 카테고리 목록을 불러온 뒤 첫 번째로 채움
  DateTime selectedDate = DateTime.now();

  int? selectedBudgetCategoryId; // 선택된 예산 카테고리 ID (선택 전에는 null)

  @override
  void initState() {
    super.initState();
    _loadBudgetCategories();
    _loadEntryCategories();
    // 유형 선택 화면에서 넘어온 경우 (카테고리 기본값은 목록을 불러온 뒤 첫 번째로)
    if (widget.type != null) {
      selectedTransactionType = widget.type!;
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
      selectedBudgetCategoryId = widget.transaction!.budgetCategoryId; // 변경
      // 저축·투자에서 꺼내 쓴 지출이면 드롭다운의 특별한 값으로
      if (widget.transaction!.fundSource == '저축') selectedBudgetCategoryId = fromSaving;
      if (widget.transaction!.fundSource == '투자') selectedBudgetCategoryId = fromInvest;
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
    final List<BudgetCategoryModel> cats;
    try {
      cats = await _budgetCategoryService.getCategories();
    } catch (e) {
      // 서버 꺼짐 등: 예산 카테고리 드롭다운만 비어 있게 두고 알림
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiErrorMessage(e, '예산 카테고리를 불러오지 못했어요.'))));
      return;
    }
    if (!mounted) return;
    setState(() {
      budgetCategories = cats;
      // 수정 모드에서는 initState에서 기존 출처를 넣어 둠 → 비어 있을 때만 첫 번째로 채움
      if (cats.isNotEmpty && selectedBudgetCategoryId == null) {
        selectedBudgetCategoryId = cats.first.id;
      }
    });
  }

  // 수입·지출 카테고리 목록 불러오기
  Future<void> _loadEntryCategories() async {
    try {
      final income = await AppRepositories.entryCategories.getCategories('수입');
      final expense = await AppRepositories.entryCategories.getCategories('지출');
      if (!mounted) return;
      setState(() {
        incomeCategories = income.map((c) => c.name).toList();
        expenseCategories = expense.map((c) => c.name).toList();
        entryCategoriesLoaded = true;
        // 새 거래면 그 유형의 첫 번째 카테고리를 기본값으로
        if (selectedTransactionCategory.isEmpty) {
          final list = selectedTransactionType == '수입'
              ? incomeCategories
              : expenseCategories;
          if (list.isNotEmpty) selectedTransactionCategory = list.first;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiErrorMessage(e, '카테고리를 불러오지 못했어요.'))));
    }
  }

  // 예산 카테고리 드롭다운 항목
  // 수정하는 거래의 출처가 이미 삭제된 카테고리면 목록에 없음 → Dropdown은 value가 items에 없으면 크래시하므로
  // 거래에 저장된 이름으로 항목을 하나 더 만들어 줌 (서버는 출처를 안 바꾸면 삭제된 카테고리도 유지)
  // withFundSources: 지출일 때 "저축에서", "투자에서" 항목도 추가 (로컬 모드 전용)
  List<DropdownMenuItem<int>> _budgetCategoryItems({bool withFundSources = false}) {
    final items = budgetCategories
        .where((c) => c.name != '저축')
        .map<DropdownMenuItem<int>>((c) {
          return DropdownMenuItem<int>(
            value: c.id,
            child: Text(c.name, style: TextStyle(fontSize: 14)),
          );
        })
        .toList();

    final old = widget.transaction;
    final exists = budgetCategories.any((c) => c.id == selectedBudgetCategoryId);
    if (old != null &&
        old.budgetCategoryId != null &&
        old.budgetCategoryId == selectedBudgetCategoryId &&
        !exists) {
      items.add(
        DropdownMenuItem<int>(
          value: old.budgetCategoryId,
          child: Text('${old.budgetCategoryName} (삭제됨)', style: TextStyle(fontSize: 14)),
        ),
      );
    }
    // 모아 둔 돈에서 꺼내 쓰기: 이번 달 예산 카테고리는 줄지 않고, 지출 합계에는 들어감
    if (withFundSources && isLocalMode) {
      items.add(
        DropdownMenuItem<int>(
          value: fromSaving,
          child: Text('저축에서 꺼내 쓰기', style: TextStyle(fontSize: 14)),
        ),
      );
      items.add(
        DropdownMenuItem<int>(
          value: fromInvest,
          child: Text('투자에서 꺼내 쓰기', style: TextStyle(fontSize: 14)),
        ),
      );
    }
    return items;
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
                    initialValue: selectedTransactionType,
                    dropdownColor: Colors.white, // 목록 배경색
                    borderRadius: BorderRadius.circular(12), // 목록 모서리
                    items: transactionTypeList.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    // 서버가 유형 변경을 막음(400) → null이면 비활성화: 값은 보이지만 바꿀 수 없음
                    onChanged: null,
                  ),
                  SizedBox(height: 20),
                ],

                // 카테고리 드롭다운 (수입·지출만. 저축·투자는 서버가 유형 이름으로 채움)
                if (entryCategoriesLoaded &&
                    (selectedTransactionType == '수입' ||
                        selectedTransactionType == '지출')) ...[
                  DropdownButtonFormField<String>(
                    // initialValue는 처음 한 번만 쓰이므로, 값이 바뀌면 key로 새로 그림
                    key: ValueKey('entry-$selectedTransactionCategory'),
                    decoration: inputDecoration('카테고리'),
                    initialValue: selectedTransactionCategory,
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

                // 저축·투자일 때 차감할 예산 선택
                if (selectedTransactionType == '저축' ||
                    selectedTransactionType == '투자') ...[
                  DropdownButtonFormField<int>(
                    key: ValueKey(
                      'source-$selectedBudgetCategoryId-${budgetCategories.length}',
                    ),
                    decoration: inputDecoration('예산 출처'),
                    initialValue: selectedBudgetCategoryId,
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    items: _budgetCategoryItems(),
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedBudgetCategoryId = newValue;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                ],

                // 예산 카테고리 드롭다운 (지출일 때만 표시)
                if (selectedTransactionType == '지출') ...[
                  DropdownButtonFormField<int>(
                    key: ValueKey(
                      'budget-$selectedBudgetCategoryId-${budgetCategories.length}',
                    ),
                    decoration: inputDecoration('예산 카테고리'),
                    initialValue: selectedBudgetCategoryId,
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    items: _budgetCategoryItems(withFundSources: true),
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedBudgetCategoryId = newValue;
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
                              final isSavingOrInvest =
                                  selectedTransactionType == '저축' ||
                                  selectedTransactionType == '투자';
                              final transaction = TransactionModel(
                                // ?: null 허용, ??: null일 때 기본값
                                id: widget.transaction?.id ?? 0, // 수정 모드면 기존 id, 추가 모드면 0
                                title: transactionName.text,
                                amount: int.parse(transactionPrice.text),
                                type: selectedTransactionType,
                                // 저축·투자는 서버가 유형 이름으로 덮어씀 (여기서도 같은 값으로 보냄)
                                category: isSavingOrInvest
                                    ? selectedTransactionType
                                    : selectedTransactionCategory,
                                // 수입은 출처 없음. 지출·저축·투자는 화면에서 고른 출처
                                // (특별한 값 -1/-2 = 저축·투자에서 꺼내 쓰기 → 카테고리 id 대신 fundSource)
                                budgetCategoryId:
                                    selectedTransactionType == '수입' ||
                                        (selectedBudgetCategoryId ?? 0) < 0
                                    ? null
                                    : selectedBudgetCategoryId,
                                fundSource: selectedTransactionType != '지출'
                                    ? null
                                    : selectedBudgetCategoryId == fromSaving
                                    ? '저축'
                                    : selectedBudgetCategoryId == fromInvest
                                    ? '투자'
                                    : null,
                                date: selectedDate,
                                memo: transactionMemo.text,
                              );

                              // 저장소에 저장 (추가 or 수정)
                              // 수입이면 자동 저축·투자는 저장소(로컬 구현/서버)가 만듦 → 화면은 거래 하나만 보냄
                              if (widget.transaction == null) {
                                await _transactionService.addTransaction(transaction);
                              } else {
                                await _transactionService.updateTransaction(transaction);
                              }
                              if (!context.mounted) return;
                              Navigator.popUntil(context, (route) => route.isFirst);
                            } on FormatException {
                              // 금액 칸이 비었거나 숫자가 아님 (int.parse 실패)
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text('금액을 숫자로 입력해주세요.')));
                              setState(() => isLoading = false);
                            } catch (e) {
                              // 규칙 위반(로컬 AppException / 서버 400: 금액·거래명·출처 등), 서버 꺼짐
                              if (!context.mounted) return;
                              final message = apiErrorMessage(e, '저장에 실패했어요.');
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(message)));
                              setState(() => isLoading = false);
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
