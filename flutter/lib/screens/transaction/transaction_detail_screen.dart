import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:moa/models/transaction_model.dart';

class TransactionDetailScreen extends StatefulWidget {
  final TransactionModel transaction;
  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  // 변수 선언
  late String transactionName;
  late int transactionPrice;
  late String transactionType;
  late String transactionCategory;
  late int? budgetCategoryId;
  late String date;
  late String memo;

  @override
  void initState() {
    super.initState();
    transactionName = widget.transaction.title;
    transactionPrice = widget.transaction.amount;
    transactionType = widget.transaction.type;
    transactionCategory = widget.transaction.category;
    budgetCategoryId = widget.transaction.budgetCategoryId;
    date = DateFormat('yyyy.MM.dd').format(widget.transaction.date);
    memo = widget.transaction.memo ?? '';
  }

  // budgetCategory 이름: 서버 응답에 들어 있음 (삭제된 카테고리여도 원래 이름이 옴)
  // → 카테고리 목록을 따로 불러와 id로 찾을 필요가 없어짐
  String get budgetCategoryName => widget.transaction.budgetCategoryName ?? '';

  @override
  Widget build(BuildContext context) {
    final isIncome = transactionType == '수입';
    final isSaving = transactionType == '저축';
    final isInvest = transactionType == '투자';
    final amountColor = isIncome
        ? Colors.blue
        : isSaving || isInvest
        ? Colors.green
        : Colors.red;
    // 수입 +, 지출 -, 저축·투자는 부호 없음 (목록 화면과 같은 규칙)
    final amountPrefix = isIncome
        ? '+'
        : isSaving || isInvest
        ? ''
        : '-';

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 24.0, top: 60.0, right: 24.0, bottom: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 상단 타이틀
            Text('거래 상세', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 32),

            // 거래 정보 카드
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 거래명 + 카테고리
                  Row(
                    children: [
                      Text(
                        transactionName,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Text(
                        transactionCategory,
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // 금액
                  Text(
                    '$amountPrefix${transactionPrice.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: amountColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  Divider(color: Colors.grey[200]),
                  SizedBox(height: 16),

                  // 유형
                  _buildDetailRow('유형', transactionType),
                  SizedBox(height: 12),

                  // 자동 거래 표시 (수입을 입력하면 서버가 비율대로 만든 저축·투자)
                  if (widget.transaction.isAuto) ...[
                    _buildDetailRow('구분', '수입에서 자동 생성'),
                    SizedBox(height: 12),
                  ],

                  // 예산 카테고리 (수입이 아닐 때만)
                  if (budgetCategoryId != null)
                    Column(
                      children: [
                        _buildDetailRow('예산 카테고리', budgetCategoryName),
                        SizedBox(height: 12),
                      ],
                    ),

                  // 날짜
                  _buildDetailRow('날짜', date),
                  SizedBox(height: 12),

                  // 메모
                  if (memo.isNotEmpty) _buildDetailRow('메모', memo),
                ],
              ),
            ),

            Spacer(),

            // 목록 보기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('목록 보기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: TextStyle(color: Colors.grey, fontSize: 13)),
        ),
        Text(value, style: TextStyle(fontSize: 13)),
      ],
    );
  }
}
