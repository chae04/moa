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
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return ListTile(
                          title: Text(transaction.title),
                          subtitle: Text(transaction.category),
                          trailing: Text('${transaction.amount}원'),
                          onTap: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TransactionDetailScreen(transaction: transaction),
                              ),
                            ),
                          },
                          onLongPress: () => {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('수정'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TransactionFormScreen(
                                            transaction: transaction,
                                          ),
                                        ),
                                      ).then((_) => _loadTransactions()); // 폼에서 돌아오면 재로드
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text('삭제'),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      await _transactionService.deleteTransaction(
                                        transaction.id,
                                      );
                                      _loadTransactions(); // 목록 새로고침
                                    },
                                  ),
                                ],
                              ),
                            ),
                          },
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
