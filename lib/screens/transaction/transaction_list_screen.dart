import 'package:flutter/material.dart';
import 'package:moa/models/transaction_model.dart';
import 'package:moa/screens/transaction/transaction_form_screen.dart';
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
    final result = await _transactionService.getMonthlyTransactions(
      selectedYear,
      selectedMonth,
    );

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

  // 슬라이더 위젯
  Widget _buildDateSlider() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = _dateSlider[index];
          final isSelected =
              date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
                selectedYear = date.year;
                selectedMonth = date.month;
              });
              _loadTransactions();
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200), // 애니메이션 속도
              width: 45,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${date.month}/${date.day}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  Text(
                    ['일', '월', '화', '수', '목', '금', '토'][date.weekday % 7],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
                        final amountColor = isIncome
                            ? Colors.blue
                            : isSaving
                            ? Colors.green
                            : Colors.red;
                        final amountPrefix = isIncome ? '+' : '-';

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
                            onLongPress: () => showModalBottomSheet(
                              context: context,
                              builder: (context) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('수정'),
                                    onTap: () {
                                      Navigator.pop(context); // BottomSheet 닫기
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TransactionFormScreen(
                                            transaction: transaction,
                                          ),
                                        ),
                                      ).then((_) => _loadTransactions());
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.delete, color: Colors.red),
                                    title: Text(
                                      '삭제',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onTap: () async {
                                      Navigator.pop(context); // BottomSheet 닫기
                                      await _transactionService.deleteTransaction(
                                        transaction.id,
                                      );
                                      _loadTransactions();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            child: Row(
                              children: [
                                // 왼쪽 : 거래명, 카테고리, 날짜
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
                                        ],
                                      ),

                                      SizedBox(height: 4),

                                      Text(
                                        '${transaction.date.year}.${transaction.date.month.toString().padLeft(2, '0')}.${transaction.date.day.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 11,
                                        ),
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
          ],
        ),
      ),
    );
  }
}
