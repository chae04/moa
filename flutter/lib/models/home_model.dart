// [역할] 홈 화면 데이터 모델 (서버 HomeResponse와 1:1)
// - 합계, 카테고리별 예산·사용액, 날짜별 지출, 일일 추천 예산을 서버가 한 번에 계산해서 준다.
// - 응답 전용이라 toJson이 없다.

class HomeModel {
  final int totalIncome;
  final int totalExpense;
  final int totalSaving; // 저축 유형 합계 (자동 저축 포함)
  final int totalInvest; // 투자 유형 합계 (자동 투자 포함)
  final List<CategorySummary> categories; // 그 달에 보여 줄 카테고리 (삭제·홈 숨김 포함)
  final List<DailyExpense> dailyExpenses; // 지출이 있는 날만 들어 있음
  final int? dailyBudget; // 지난달이거나 비율이 없으면 null
  // (로컬 모드) 오늘 기준 값. 이번 달이 아니거나 서버 모드면 null
  // - 로컬 모드 이번 달의 dailyBudget은 "내일부터 남은 날의 하루 추천 금액" (오늘 넘게 쓰면 줄어듦, 마지막 날이면 null)
  final int? todayBudget; // 오늘 추천 = 오늘 아침 기준 잔액 ÷ 남은 일수(오늘 포함)
  final int? todaySpent; // 오늘 쓴 돈 (일일 예산에 포함된 카테고리를 출처로 한 오늘 거래 합)
  final int? todayRemaining; // 오늘 남은 돈 = 오늘 추천 - 오늘 쓴 돈 (음수면 초과)

  HomeModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.totalSaving,
    required this.totalInvest,
    required this.categories,
    required this.dailyExpenses,
    this.dailyBudget, // nullable이라 required 아님
    this.todayBudget,
    this.todaySpent,
    this.todayRemaining,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      totalIncome: json['totalIncome'],
      totalExpense: json['totalExpense'],
      totalSaving: json['totalSaving'],
      totalInvest: json['totalInvest'],
      categories: (json['categories'] as List) // JSON 배열 → List<dynamic>
          .map((c) => CategorySummary.fromJson(c)) // 원소마다 모델로
          .toList(),
      dailyExpenses: (json['dailyExpenses'] as List)
          .map((d) => DailyExpense.fromJson(d))
          .toList(),
      dailyBudget: json['dailyBudget'],
      todayBudget: json['todayBudget'], // 서버는 아직 안 줌 → null
      todaySpent: json['todaySpent'],
      todayRemaining: json['todayRemaining'],
    );
  }
}

// 카테고리 하나의 예산·사용액·잔액 (서버 HomeResponse.CategorySummary)
class CategorySummary {
  final int categoryId;
  final String name;
  final int budget; // 수입 × 비율 (비율 행이 없으면 0)
  final int used; // 이 카테고리를 출처로 한 거래 합 (자동 거래 제외)
  final int remaining; // budget - used (음수 가능 = 초과)
  final bool showOnHome;
  final bool includeInDaily;
  final bool deleted; // 삭제됐지만 그 달 사용액이 있어서 목록에 남은 카테고리

  CategorySummary({
    required this.categoryId,
    required this.name,
    required this.budget,
    required this.used,
    required this.remaining,
    required this.showOnHome,
    required this.includeInDaily,
    required this.deleted,
  });

  factory CategorySummary.fromJson(Map<String, dynamic> json) {
    return CategorySummary(
      categoryId: json['categoryId'],
      name: json['name'],
      budget: json['budget'],
      used: json['used'],
      remaining: json['remaining'],
      showOnHome: json['showOnHome'],
      includeInDaily: json['includeInDaily'],
      deleted: json['deleted'],
    );
  }
}

// 날짜별 지출 합계 (달력에 표시)
class DailyExpense {
  final DateTime date;
  final int amount;

  DailyExpense({required this.date, required this.amount});

    factory DailyExpense.fromJson(Map<String, dynamic> json) {
    return DailyExpense(
      date: DateTime.parse(json['date']), // "2026-11-16" → 그날 0시 DateTime
      amount: json['amount'],
    );
  }

}
