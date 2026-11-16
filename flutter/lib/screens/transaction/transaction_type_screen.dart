import 'package:flutter/material.dart';
import 'package:moa/screens/transaction/transaction_form_screen.dart';

class TransactionTypeScreen extends StatelessWidget {
  final DateTime? date;
  const TransactionTypeScreen({super.key, this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 60.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              '어떤 거래인가요?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Column(
              children: [
                _buildTypeButton(context, '수입', Colors.blue),
                SizedBox(height: 16),
                _buildTypeButton(context, '지출', Colors.red),
                SizedBox(height: 16),
                _buildTypeButton(context, '저축', Colors.green),
                SizedBox(height: 16),
                _buildTypeButton(context, '투자', Colors.green),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('돌아가기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(BuildContext context, String type, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionFormScreen(type: type, date: date),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withOpacity(0.3)),
          ),
        ),
        child: Text(type, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
