// 수입 카테고리
const List<String> incomeCategoryList = ['월급', '용돈', '기타'];

// 지출 카테고리
const List<String> expenseCategoryList = [
  '식비',
  '교통',
  '쇼핑',
  '구독',
  '취미',
  '고정비',
  '공부',
  '기타',
];

// 예산 카테고리
const List<String> budgetCategoryList = ['생활비', '자유비', '교통비', '저축', '투자'];

// 저축 제외한 예산 카테고리 (추가 저축할 때 차감할 예산 선택용)
const List<String> budgetCategoryExcludeSaving = ['생활비', '자유비', '교통비', '투자'];

// 일일 예산 추천에 포함 할 카테고리
const List<String> dailyBudgetDefault = ['생활비', '자유비', '교통비'];

// 거래 유형
const List<String> transactionTypeList = ['수입', '지출', '저축'];

// 카테고리별 지출 초기값 : 0
Map<String, int> get initialExpenseByCategory => {
  for (var c in expenseCategoryList) c: 0,
};

// 예산 카테고리 초기값 : 0
Map<String, int> get initialBudgetCategory => {for (var c in budgetCategoryList) c: 0};
