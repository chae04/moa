class BudgetModel {
  final String userId;
  final String month; // 2026-07 형식
  List<Map<String, dynamic>> categories; // [{category: '생활비', ratio: 50, amount: 250000}]

  int savingRatio; // 저축 비율
  int investRatio; // 투자 비율

  BudgetModel({
    required this.userId,
    required this.month,
    required this.categories,
    this.savingRatio = 0,
    this.investRatio = 0,
  });

  // Firestore에 저장할 때 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'month': month,
      'categories': categories,
      'savingRatio': savingRatio,
      'investRatio': investRatio,
    };
  }

  // Firestore에서 불러올 때 Map을 모델로 변환
  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      userId: map['userId'],
      month: map['month'],
      categories: List<Map<String, dynamic>>.from(
        (map['categories'] as List).map((e) => Map<String, dynamic>.from(e)),
      ),
      savingRatio: map['savingRatio'] ?? 0,
      investRatio: map['investRatio'] ?? 0,
    );
  }
}
