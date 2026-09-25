class BudgetCategoryModel {
  final String id;
  final String userId;
  String name;
  int order;
  bool includeInDaily;

  BudgetCategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.order,
    required this.includeInDaily,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'order': order,
      'includeInDaily': includeInDaily,
    };
  }

  factory BudgetCategoryModel.fromMap(String id, Map<String, dynamic> map) {
    return BudgetCategoryModel(
      id: id,
      userId: map['userId'],
      name: map['name'],
      order: map['order'],
      includeInDaily: map['includeInDaily'] ?? false,
    );
  }
}
