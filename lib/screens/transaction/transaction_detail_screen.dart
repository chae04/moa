import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:moa/models/transaction_model.dart';

class TransactionDetailScreen extends StatefulWidget {
  final TransactionModel transaction;
  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailScreen> createState() => _transactionDetailScreenState();
}

class _transactionDetailScreenState extends State<TransactionDetailScreen> {
  // 변수 선언
  late String transactionName;
  late int transactionPrice;
  late String transactionType;
  late String transactionCategory;
  late String? budgetCategory;
  late String date;
  late String memo;

  @override
  void initState() {
    super.initState();
    transactionName = widget.transaction.title;
    transactionPrice = widget.transaction.amount;
    transactionType = widget.transaction.type;
    transactionCategory = widget.transaction.category;
    budgetCategory = widget.transaction.budgetCategory;
    // date = widget.transaction.date;
    date = DateFormat('yyyy.MM.dd').format(widget.transaction.date);

    memo = widget.transaction.memo ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('거래명: $transactionName'),
            Text('금액: $transactionPrice'),
            Text('유형: $transactionType'),
            Text('카테고리: $transactionCategory'),
            Text('예산 카테고리: $budgetCategory'),
            Text('날짜: $date'),
            Text('메모: $memo'),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('목록 보기')),
          ],
        ),
      ),
    );
  }
}
