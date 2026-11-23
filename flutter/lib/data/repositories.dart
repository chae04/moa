// [역할] 화면이 데이터를 읽고 쓰는 "약속"(인터페이스) 모음
// - 화면은 이 인터페이스만 알고, 실제 저장 위치(폰 안 로컬 DB / Spring 서버)는 모른다.
// - 구현은 두 가지:
//   1) 서버 구현: services/의 HTTP 클래스 (BudgetCategoryService 등) — 지금 앱이 쓰는 것
//   2) 로컬 구현: data/local/ 의 drift 클래스 — 할 일 목록 4번에서 하나씩 추가
// - Spring에서 Service가 Repository "인터페이스"에 의존하고, 구현(JPA)은 갈아끼울 수 있는 것과 같은 구조
// - abstract interface class: 메서드 목록만 있고 구현은 없는 클래스. 구현 쪽은 `implements`로 모든 메서드를 반드시 채워야 함

import 'package:moa/models/budget_category_model.dart';
import 'package:moa/models/budget_model.dart';
import 'package:moa/models/entry_category_model.dart';
import 'package:moa/models/home_model.dart';
import 'package:moa/models/stats_model.dart';
import 'package:moa/models/transaction_model.dart';

// 예산 카테고리 (서버 /api/categories)
abstract interface class CategoryRepository {
  // 삭제 제외, 표시 순서대로
  Future<List<BudgetCategoryModel>> getCategories();

  // 순서는 맨 뒤로. 홈 표시 최대 5개 초과면 실패
  Future<void> addCategory({
    required String name,
    required bool showOnHome,
    bool includeInDaily = false,
  });

  // 이름, 홈 표시, 일일 포함 수정
  Future<void> updateCategory(BudgetCategoryModel category);

  // 소프트 삭제. 최소 1개 유지, 현재·이후 비율에 남아 있으면 실패
  Future<void> deleteCategory(int id);

  // 표시 순서를 바꿀 수 있는지 (서버 모드는 서버 API가 없어서 false → 화면에서 끌기 숨김)
  bool get canReorder;

  // orderedIds 순서대로 표시 순서를 다시 매김 (삭제 안 된 카테고리 id가 빠짐없이 한 번씩 있어야 함)
  Future<void> reorderCategories(List<int> orderedIds);
}

// 예산 비율 (서버 /api/budget-ratios)
abstract interface class RatioRepository {
  // month("2026-11")에 적용되는 묶음. 저장한 적이 없으면 applyFrom == null인 빈 묶음
  Future<BudgetModel> getRatios(String month);

  // budget.applyFrom 월부터 적용. 같은 월이면 교체. 합계 100이 아니거나 지난 달이면 실패
  Future<BudgetModel> saveRatios(BudgetModel budget);
}

// 거래 (서버 /api/transactions)
abstract interface class TransactionRepository {
  // 수입이면 비율대로 저축·투자 자동 거래도 생성
  Future<void> addTransaction(TransactionModel transaction);

  // 유형 변경, 수입 금액 변경, 자동 거래 수정은 실패. 수입 날짜를 바꾸면 자동 거래 날짜도 이동
  Future<void> updateTransaction(TransactionModel transaction);

  // 수입이면 자동 거래도 같이 삭제
  Future<void> deleteTransaction(int id);

  // 해당 월의 거래 (날짜 최신순)
  Future<List<TransactionModel>> getMonthlyTransactions(int year, int month);
}

// 홈 요약 (서버 /api/home)
abstract interface class HomeRepository {
  // 합계, 카테고리별 예산·사용액·잔액, 날짜별 지출, 일일 추천 예산
  Future<HomeModel> getHome(int year, int month);
}

// 수입·지출 카테고리 (월급, 식비 등. 거래의 category 이름 목록)
// - 로컬: 추가·이름 변경·삭제 가능 / 서버: 서버에 테이블이 없어서 고정 목록, 수정 불가
abstract interface class EntryCategoryRepository {
  // 목록을 바꿀 수 있는지 (서버 모드는 false → 관리 화면을 열지 않음)
  bool get isEditable;

  // kind = '수입' 또는 '지출'. 삭제 제외, 순서대로
  Future<List<EntryCategoryModel>> getCategories(String kind);

  // 이름 1~10자, 같은 종류 안에서 이름 중복 불가
  Future<void> addCategory(String kind, String name);

  // 이름만 변경. 지난 거래의 카테고리 이름은 그대로 (거래는 이름 문자열을 저장하므로)
  Future<void> renameCategory(int id, String name);

  // 소프트 삭제. 종류마다 최소 1개 유지
  Future<void> deleteCategory(int id);
}

// 통계 (서버 /api/stats)
abstract interface class StatsRepository {
  // 그 달 카테고리별 지출 (금액 큰 순)
  Future<CategoryStatsModel> getCategoryStats(int year, int month);

  // 1~12월 수입·지출, 올해 모은 돈
  Future<YearlyStatsModel> getYearlyStats(int year);
}
