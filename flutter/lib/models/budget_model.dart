// [역할] 예산 비율 묶음 모델 (서버 BudgetRatioResponse와 1:1)
// - 서버 응답 JSON → 모델: fromJson
// - 모델 → 서버 요청 JSON(BudgetRatioRequest): toJson
// - 금액(amount)은 서버가 조회할 때 계산하므로 저장하지 않는다.
// - 누구의 비율인지는 토큰으로 판단하므로 userId 필드가 없다.

class BudgetModel {
  final String? applyFrom; // 적용 시작 월 "YYYY-MM". 비율을 한 번도 저장 안 했으면 null
  int savingRatio; // 저축 비율
  int investRatio; // 투자 비율
  List<CategoryRatio> categories; // 카테고리별 비율

  BudgetModel({
    this.applyFrom, // nullable이라 required가 아님
    required this.savingRatio,
    required this.investRatio,
    required this.categories,
  });

  // 서버 응답 {"applyFrom": "2026-11", "savingRatio": 20, ..., "categories": [{...}]} → 모델
  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      applyFrom: json['applyFrom'], // 비율이 없으면 서버가 null을 줌
      savingRatio: json['savingRatio'],
      investRatio: json['investRatio'],
      categories:
          (json['categories'] as List) // JSON 배열은 List<dynamic>으로 들어옴
              .map((c) => CategoryRatio.fromJson(c)) // 원소 하나하나를 CategoryRatio로
              .toList(),
    );
  }

  // 저장 요청 본문 (서버 BudgetRatioRequest: applyFrom, savingRatio, investRatio, categories)
  Map<String, dynamic> toJson() {
    return {
      'applyFrom': applyFrom, // 키 이름 = 서버 DTO 필드 이름 (Jackson이 이름으로 매칭)
      'savingRatio': savingRatio,
      'investRatio': investRatio,
      'categories': categories
          .map((c) => c.toJson()) // CategoryRatio 객체 → Map
          .toList(), // map()의 결과(Iterable)를 JSON 배열이 되는 List로
    };
  }
}

// 카테고리 하나의 비율 (서버의 중첩 클래스 CategoryRatio와 대응)
class CategoryRatio {
  final int categoryId; // 서버 Long → Dart int
  final String name; // 응답에만 있음 (화면 표시용)
  int ratio;

  CategoryRatio({required this.categoryId, required this.name, required this.ratio});

  factory CategoryRatio.fromJson(Map<String, dynamic> json) {
    return CategoryRatio(
      categoryId: json['categoryId'],
      name: json['name'],
      ratio: json['ratio'],
    );
  }

  // 요청 본문: 서버 BudgetRatioRequest.CategoryRatio에는 categoryId, ratio만 있음
  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'ratio': ratio,
      // name은 보내지 않음: 서버 요청 DTO에 없고, 이름은 categoryId로 서버가 알고 있음
    };
  }
}
