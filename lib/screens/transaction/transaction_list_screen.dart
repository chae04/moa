import 'package:flutter/material.dart';
import 'package:moa/models/transaction_model.dart';
import 'package:moa/screens/transaction/transaction_form_screen.dart';
import 'package:moa/services/transaction_service.dart';
import 'package:moa/screens/transaction/transaction_detail_screen.dart';

class TransactionListScreen extends StatefulWidget {
  final int? year;
  final int? month;
  final Function(int year, int month)? onChanged;
  const TransactionListScreen({super.key, this.year, this.month, this.onChanged});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TransactionService _transactionService = TransactionService();
  List<TransactionModel> transactions = [];
  bool isLoading = true;
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  // [2026년부터 현재+2까지의 개수]만큼 2026년부터 표시함. 즉, 2026년부터 내후년까지 표시.
  List<int> yearList = List.generate(DateTime.now().year - 2026 + 3, (i) => 2026 + i);
  List<int> monthList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  @override
  void initState() {
    super.initState();
    selectedYear = widget.year ?? DateTime.now().year;
    selectedMonth = widget.month ?? DateTime.now().month;
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
      transactions = result;
      isLoading = false;
    });
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

            Row(
              children: [
                // 년 선택
                DropdownButton<int>(
                  value: selectedYear,
                  items: yearList.map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem(value: value, child: Text('$value년'));
                  }).toList(),
                  onChanged: (int? newValue) {
                    final year = newValue!;
                    setState(() {
                      selectedYear = year;
                    });
                    widget.onChanged?.call(year, selectedMonth);
                    _loadTransactions();
                  },
                ),

                SizedBox(width: 12),

                // 월 선택
                DropdownButton<int>(
                  value: selectedMonth,
                  items: monthList.map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem(value: value, child: Text('$value월'));
                  }).toList(),
                  onChanged: (int? newValue) {
                    final month = newValue!;
                    setState(() {
                      selectedMonth = month;
                    });
                    widget.onChanged?.call(selectedYear, month);
                    _loadTransactions();
                  },
                ),
              ],
            ),

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
