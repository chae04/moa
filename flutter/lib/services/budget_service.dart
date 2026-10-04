import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moa/models/budget_model.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // 이번 달 문서 ID 생성 ({userid}_{yyyy-mm})
  String _getDocId(String month) => '${_uid}_$month';

  // 기본 예산 비율 저장 (템플릿 - 새 달 시작할 때 참고)
  Future<void> setUserBudget(BudgetModel budget) async {
    await _firestore.collection('userBudgets').doc(_uid).set(budget.toMap());
  }

  // 월별 실제 예산 저장 (수입 기반으로 amount 계산된 데이터)
  Future<void> setBudget(BudgetModel budget) async {
    await _firestore
        .collection('budgets')
        .doc(_getDocId(budget.month))
        .set(budget.toMap());
  }

  // 해당 월 예산 불러오기
  Future<BudgetModel?> getBudget(String month) async {
    final doc = await _firestore.collection('budgets').doc(_getDocId(month)).get();

    if (!doc.exists) return null; // 설정된 예산 없으면 null 반환
    return BudgetModel.fromMap(doc.data()!);
  }

  // 사용자 기본 예산 비율 불러오기
  Future<BudgetModel?> getUserBudget() async {
    final doc = await _firestore.collection('userBudgets').doc(_uid).get();
    if (!doc.exists) return null;
    return BudgetModel.fromMap(doc.data()!);
  }

  // 수입 입력되면 amount 업데이트
  Future<void> updateBudgetAmount(String month, int income) async {
    final budget = await getBudget(month);
    if (budget == null) return;

    // 비율에 맞게 amount 계산
    final updatedCategories = budget.categories.map((c) {
      return {
        'category': c['category'],
        'ratio': c['ratio'],
        'amount': (income * c['ratio'] / 100).round(),
      };
    }).toList();

    await _firestore.collection('budgets').doc(_getDocId(month)).update({
      'categories': updatedCategories,
    });
  }
}
