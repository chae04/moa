import 'package:flutter/material.dart';
import 'package:moa/models/transaction_model.dart';
import 'package:moa/screens/transaction/transaction_form_screen.dart';
import 'package:moa/services/transaction_service.dart';
import 'package:moa/screens/transaction/transaction_detail_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TransactionService _transactionService = TransactionService();
  List<TransactionModel> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final now = DateTime.now();
    final result = await _transactionService.getMonthlyTransactions(now.year, now.month);

    setState(() {
      transactions = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('거래 목록', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),

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

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('홈'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
