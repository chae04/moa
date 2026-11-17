import 'package:flutter/material.dart';
import 'package:moa/utils/api_error.dart';
import 'package:moa/models/transaction_model.dart';
import 'package:moa/screens/transaction/transaction_form_screen.dart';
import 'package:moa/screens/transaction/transaction_type_screen.dart';
import 'package:moa/services/transaction_service.dart';
import 'package:moa/screens/transaction/transaction_detail_screen.dart';
import 'package:moa/constants/colors.dart';

class TransactionListScreen extends StatefulWidget {
  final int? year;
  final int? month;
  final DateTime? selectedDate;
  final Function(int year, int month)? onChanged;
  const TransactionListScreen({
    super.key,
    this.year,
    this.month,
    this.selectedDate,
    this.onChanged,
  });

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TransactionService _transactionService = TransactionService();
  List<TransactionModel> transactions = [];
  bool isLoading = true;
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  late DateTime _selectedDate;

  // [2026년부터 현재+2까지의 개수]만큼 2026년부터 표시함. 즉, 2026년부터 내후년까지 표시.
  List<int> yearList = List.generate(DateTime.now().year - 2026 + 3, (i) => 2026 + i);
  List<int> monthList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  // 앞뒤 3일 날짜 리스트 생성
  List<DateTime> get _dateSlider => List.generate(7, (i) {
    return _selectedDate.add(Duration(days: i - 3));
  });

  @override
  void initState() {
    super.initState();
    selectedYear = widget.year ?? DateTime.now().year;
    selectedMonth = widget.month ?? DateTime.now().month;
    _selectedDate = widget.selectedDate ?? DateTime.now();

    _loadTransactions();
  }

  @override
  void didUpdateWidget(TransactionListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.year != widget.year || oldWidget.month != widget.month) {
      selectedYear = widget.year ?? DateTime.now().year;
      selectedMonth = widget.month ?? DateTime.now().month;
      _loadTransactions();
    }
  }

  Future<void> _loadTransactions() async {
    final List<TransactionModel> result;
    try {
      result = await _transactionService.getMonthlyTransactions(
        selectedYear,
        selectedMonth,
      );
    } catch (e) {
      // 서버 꺼짐 등: 목록은 이전 값 유지, 로딩만 끄고 알림
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorMessage(e, '거래 목록을 불러오지 못했어요.'))),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      // 선택된 날짜의 거래만 필터링
      transactions = result
          .where(
            (t) =>
                t.date.year == _selectedDate.year &&
                t.date.month == _selectedDate.month &&
                t.date.day == _selectedDate.day,
          )
          .toList();
      isLoading = false;
    });
  }

  // 상단 날짜 위젯
  Widget _buildDateSlider() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      // transitionBuilder: (child, animation) {
      //   return SlideTransition(
      //     position: Tween<Offset>(
      //       begin: Offset(1.0, 0.0),
      //       end: Offset.zero,
      //     ).animate(animation),
      //     child: child,
      //   );
      // },
      child: SizedBox(
        key: ValueKey(_selectedDate), // 날짜 바뀌면 애니메이션 트리거
        height: 60,
        child: Row(
          children: List.generate(7, (index) {
            final date = _dateSlider[index];
            final isSelected =
                date.day == _selectedDate.day &&
                date.month == _selectedDate.month &&
                date.year == _selectedDate.year;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedDate = date;
                          selectedYear = date.year;
                          selectedMonth = date.month;
                        });
                        _loadTransactions();
                      },
                      borderRadius: BorderRadius.circular(12),
                      splashColor: primaryColor.withValues(alpha: 0.3),
                      highlightColor: primaryColor.withValues(alpha: 0.1),
                      child: SizedBox(
                        height: 60,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected ? Colors.white : Colors.grey[600]!,
                              ),
                              child: Text('${date.month}/${date.day}'),
                            ),
                            AnimatedDefaultTextStyle(
                              duration: Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.grey[800]!,
                              ),
                              child: Text(
                                ['일', '월', '화', '수', '목', '금', '토'][date.weekday % 7],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 24.0, top: 60.0, right: 24.0, bottom: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('거래 목록', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

            SizedBox(height: 16),

            _buildDateSlider(),

            // 로딩 중이면 스피너, 아니면 목록 표시
            isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: transactions.length,
                      // ListView.builder itemBuilder 부분만 교체
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        final isIncome = transaction.type == '수입';
                        final isSaving = transaction.type == '저축';
                        final isInvest = transaction.type == '투자';
                        final amountColor = isIncome
                            ? Colors.blue
                            : isSaving || isInvest
                            ? Colors.green
                            : Colors.red;
                        // 수입 +, 지출 -, 저축·투자는 내 돈이 늘거나 준 게 아니라 옮긴 것이라 부호 없음
                        final amountPrefix = isIncome
                            ? '+'
                            : isSaving || isInvest
                            ? ''
                            : '-';

                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TransactionDetailScreen(transaction: transaction),
                              ),
                            ),
                            onLongPress: () => showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                    vertical: 20.0,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // 거래명
                                      Text(
                                        transaction.title,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Divider(color: Colors.grey[200]),

                                      // 수정 버튼 (자동 거래는 서버가 수정을 막으므로 숨김)
                                      if (!transaction.isAuto)
                                        ListTile(
                                          leading: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                              size: 20,
                                            ),
                                          ),
                                          title: Text('수정'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    TransactionFormScreen(
                                                      transaction: transaction,
                                                    ),
                                              ),
                                            ).then((_) => _loadTransactions());
                                          },
                                        ),

                                      // 삭제 버튼
                                      ListTile(
                                        leading: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                        ),
                                        title: Text(
                                          '삭제',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onTap: () async {
                                          Navigator.pop(context); // bottomsheet 닫기

                                          // 이중 확인 다이얼로그
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              backgroundColor: Colors.white,

                                              title: Text('거래 삭제'),
                                              content: Text(
                                                // 수입을 지우면 서버가 자동 저축·투자도 같이 지움 → 미리 알림
                                                transaction.type == '수입'
                                                    ? '${transaction.title} 삭제할까요?\n이 수입으로 만들어진 자동 저축·투자도 함께 삭제됩니다.'
                                                    : '${transaction.title} 삭제할까요?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context, false),
                                                  child: Text('취소'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context, true),
                                                  child: Text(
                                                    '삭제',
                                                    style: TextStyle(color: Colors.red),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            try {
                                              await _transactionService.deleteTransaction(
                                                transaction.id,
                                              );
                                            } catch (e) {
                                              // 이미 지워진 거래(404), 서버 꺼짐 등
                                              if (!mounted) return;
                                              final message =
                                                  apiErrorMessage(e, '삭제에 실패했어요.');
                                              ScaffoldMessenger.of(
                                                this.context,
                                              ).showSnackBar(
                                                SnackBar(content: Text(message)),
                                              );
                                            }
                                            _loadTransactions(); // 실패해도 서버 기준으로 목록 새로고침
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                // 왼쪽 : 거래명, 카테고리
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            transaction.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            transaction.category,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                          // 수입 입력 시 서버가 만든 자동 저축·투자 표시
                                          if (transaction.isAuto) ...[
                                            SizedBox(width: 6),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withValues(
                                                  alpha: 0.1,
                                                ),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '자동',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // 오른쪽 : 금액
                                Text(
                                  '$amountPrefix${transaction.amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
                                  style: TextStyle(
                                    color: amountColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionTypeScreen(date: _selectedDate),
                      ),
                    ).then((_) => _loadTransactions());
                  },
                  icon: Icon(Icons.add, size: 16),
                  label: Text('추가'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
