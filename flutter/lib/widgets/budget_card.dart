// [역할] 홈 화면의 예산 카테고리 카드 (카테고리 하나 = 카드 하나)
// - 이름, 남은 돈, "예산 중 몇 % 남음", 남은 비율 바
// - 다 써서 넘기면 "초과 ○○원"(빨강)과 빈 바

import 'package:flutter/material.dart';
import 'package:moa/utils/format.dart';

class BudgetCard extends StatelessWidget {
  final String name;
  final int remaining; // 남은 돈 (음수면 초과)
  final int budget; // 이번 달 예산 (수입 × 비율)

  const BudgetCard({
    super.key,
    required this.name,
    required this.remaining,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    final over = remaining < 0;
    final ratio = budget <= 0 ? 0.0 : (remaining / budget).clamp(0.0, 1.0); // 남은 비율 0~1

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Color(0xFFFFF8EE), // 종이 봉투 느낌의 연한 색
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Color(0xFFEADBC8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                over || remaining == 0 ? Icons.mail_outline : Icons.mail,
                size: 18,
                color: Color(0xFFB08968),
              ),
              SizedBox(width: 6),
              Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Spacer(),
              Text(
                over ? '초과 ${formatWon(-remaining)}' : formatWon(remaining),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: over ? Colors.red : Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            '예산 ${formatWon(budget)} 중 ${(ratio * 100).round()}% 남음',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
          SizedBox(height: 10),
          // 남은 비율 바 (가득 = 하나도 안 씀, 비어 있음 = 다 씀)
          LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
            backgroundColor: Color(0xFFEADBC8),
            color: over ? Colors.red : Color(0xFFB08968),
          ),
        ],
      ),
    );
  }
}
