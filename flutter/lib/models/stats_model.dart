// [역할] 통계 화면 데이터 모델 (서버 CategoryStatsResponse, YearlyStatsResponse와 1:1)
// - 서버 응답 JSON → 모델: fromJson (서버 모드)
// - 로컬 모드는 LocalStatsRepository가 같은 모델을 직접 만든다.
// - 통계는 카테고리 테이블이 아니라 거래에서 만든다 (카테고리를 지우거나 이름을 바꿔도 지난 통계가 그대로)

// 한 달의 카테고리별 지출
class CategoryStatsModel {
  final int totalExpense;
  final List<CategoryAmount> categories; // 금액 큰 순

  const CategoryStatsModel({required this.totalExpense, required this.categories});

  factory CategoryStatsModel.fromJson(Map<String, dynamic> json) => CategoryStatsModel(
    totalExpense: (json['totalExpense'] as num).toInt(), // 서버는 Long → JSON 숫자
    categories: (json['categories'] as List)
        .map(
          (c) => CategoryAmount(
            category: c['category'],
            amount: (c['amount'] as num).toInt(),
          ),
        )
        .toList(),
  );
}

class CategoryAmount {
  final String category; // 거래의 category 문자열 (식비, 교통 ...)
  final int amount;

  const CategoryAmount({required this.category, required this.amount});
}

// 1년 추이: 월별 수입 - 지출
class YearlyStatsModel {
  final int totalIncome;
  final int totalExpense;
  final int totalSaved; // 올해 모은 돈 = 총수입 - 총지출 (홈의 "저축" = 저축 유형 합계와 다른 값)
  final List<MonthSummary> months; // 항상 12개 (1~12월)

  const YearlyStatsModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.totalSaved,
    required this.months,
  });

  factory YearlyStatsModel.fromJson(Map<String, dynamic> json) => YearlyStatsModel(
    totalIncome: (json['totalIncome'] as num).toInt(),
    totalExpense: (json['totalExpense'] as num).toInt(),
    totalSaved: (json['totalSaved'] as num).toInt(),
    months: (json['months'] as List)
        .map(
          (m) => MonthSummary(
            month: m['month'],
            income: (m['income'] as num).toInt(),
            expense: (m['expense'] as num).toInt(),
          ),
        )
        .toList(),
  );
}

class MonthSummary {
  final int month; // 1~12
  final int income;
  final int expense;

  const MonthSummary({required this.month, required this.income, required this.expense});

  int get saved => income - expense; // 그 달 모은 돈
}
