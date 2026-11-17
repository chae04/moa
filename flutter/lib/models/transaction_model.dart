// [역할] 거래 데이터 모델 (서버 TransactionResponse와 1:1)
// - 서버 응답 JSON → 모델: fromJson
// - 모델 → 서버 요청 JSON(TransactionRequest): toJson
// - 누구의 거래인지는 토큰으로 판단하므로 userId 필드가 없다.
// - 자동 거래(수입 입력 시 서버가 만든 저축·투자)는 sourceTransactionId가 있다.

class TransactionModel {
  final int id; // 서버 DB id. 새 거래를 만들 때는 아직 없으므로 0 (toJson에 안 넣음)
  String title;
  int amount;
  String type; // 수입 / 지출 / 저축 / 투자
  String category; // 저축·투자는 서버가 유형 이름으로 채움
  int? budgetCategoryId; // 지출·저축·투자만 사용, 수입은 null (? : null 허용)
  final String? budgetCategoryName; // 응답에만 있음 (삭제된 카테고리 이름도 표시 가능)
  DateTime date;
  String? memo;
  final int? sourceTransactionId; // 자동 거래면 원본 수입의 id, 아니면 null

  TransactionModel({
    this.id = 0, // 새 거래는 생략 가능
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    this.budgetCategoryId, // null 가능
    this.budgetCategoryName,
    required this.date,
    this.memo,
    this.sourceTransactionId,
  });

  // 자동 거래 여부 (서버가 수정을 막으므로 화면에서 수정 버튼을 숨기는 데 사용)
  bool get isAuto => sourceTransactionId != null;

  // 서버 응답 → 모델
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      type: json['type'],
      category: json['category'],
      budgetCategoryId: json['budgetCategoryId'],
      budgetCategoryName: json['budgetCategoryName'],
      date: DateTime.parse(json['date']), // "2026-11-16" → 그날 0시 DateTime
      memo: json['memo'],
      sourceTransactionId: json['sourceTransactionId'],
    );
  }

  // 요청 본문 (서버 TransactionRequest: title, amount, type, category, budgetCategoryId, date, memo)
  // id는 URL(/api/transactions/{id})로 보내고, budgetCategoryName·sourceTransactionId는 서버가 정하는 값이라 안 보냄
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'budgetCategoryId': budgetCategoryId,
      'date': _formatDate(date), // 서버 LocalDate는 "yyyy-MM-dd"만 받음
      'memo': memo,
    };
  }

  // DateTime → "2026-11-16"
  // toIso8601String()은 "2026-11-16T00:00:00.000"처럼 시간까지 붙어서 서버 LocalDate가 400을 냄
  static String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
