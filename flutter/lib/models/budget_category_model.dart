// [역할] 예산 카테고리 데이터 모델 (서버 CategoryResponse와 1:1)
// - 서버 응답 JSON → 모델: fromJson
// - 모델 → 서버 요청 JSON(CategoryRequest): toJson
// - id는 서버 DB의 숫자 ID(Long)를 그대로 int로 쓴다.
// - 삭제된 카테고리는 서버가 목록에서 빼고 주므로 isDeleted 필드가 없다.
// - 누구의 카테고리인지는 토큰으로 판단하므로 userId 필드가 없다.

class BudgetCategoryModel {
  final int id;
  String name;
  int orderIndex; // 표시 순서 (서버가 정함)
  bool includeInDaily;
  bool showOnHome;

  BudgetCategoryModel({
    required this.id,
    required this.name,
    required this.orderIndex,
    required this.includeInDaily,
    required this.showOnHome,
  });

  // 서버 응답 {"id": 3, "name": "식비", "orderIndex": 0, ...} → 모델
  factory BudgetCategoryModel.fromJson(Map<String, dynamic> json) {
    return BudgetCategoryModel(
      id: json['id'],
      name: json['name'],
      orderIndex: json['orderIndex'],
      includeInDaily: json['includeInDaily'],
      showOnHome: json['showOnHome'],
    );
  }

  // 수정 요청 본문 (서버 CategoryRequest: name, showOnHome, includeInDaily)
  // id는 URL(/api/categories/{id})로 보내므로 본문에 넣지 않음
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'showOnHome': showOnHome,
      'includeInDaily': includeInDaily,
    };
  }
}
