class BudgetModel {
  final String userId;
  final String month; // 2026-07 형식
  List<Map<String, dynamic>> categories; // [{category: '생활비', ratio: 50, amount: 250000}]

  BudgetModel({required this.userId, required this.month, required this.categories});

  // Firestore에 저장할 때 Map으로 변환
  Map<String, dynamic> toMap() {
    return {'userId': userId, 'month': month, 'categories': categories};
  }

  // Firestore에서 불러올 때 Map을 모델로 변환
  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      userId: map['userId'],
      month: map['month'],
      categories: List<Map<String, dynamic>>.from(
        (map['categories'] as List).map((e) => Map<String, dynamic>.from(e)),
      ),
    );
  }
}
