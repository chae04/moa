// [역할] 수입·지출 카테고리 하나 (월급, 식비 등. 거래의 category 칸에 들어가는 이름 목록)
// - 예산 카테고리(BudgetCategoryModel: 생활비, 자유비)와 다른 것: 이건 "무엇에 썼나/어디서 벌었나" 분류
// - 로컬 모드: entry_categories 테이블에서 관리 (추가·이름 변경·삭제 가능)
// - 서버 모드: 서버에 테이블이 없어서 constants/categories.dart의 고정 목록 (id는 순서 번호)

class EntryCategoryModel {
  final int id;
  final String kind; // '수입' 또는 '지출'
  final String name;

  const EntryCategoryModel({required this.id, required this.kind, required this.name});
}
