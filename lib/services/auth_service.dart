import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moa/models/budget_model.dart';
import 'package:moa/services/budget_category_service.dart';
import 'package:moa/services/budget_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BudgetCategoryService _budgetCategoryService = BudgetCategoryService();
  final BudgetService _budgetService = BudgetService();

  // 회원가입
  Future<void> signUp({
    required String email,
    required String password,
    required List<Map<String, dynamic>> budgetCategories,
    required Map<String, bool> includeInDaily,
    required int savingRatio,
    required int investRatio,
  }) async {
    // Firebase Auth에 이메일/비밀번호로 계정 생성
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        // 자동생성된 uid,
        email: email,
        password: password,
      );

      try {
        // 기본 예산 카테고리 생성
        await _budgetCategoryService.createDefaultCategories(budgetCategories);

        // 생성된 카테고리 ID 가져오기
        final createdCats = await _budgetCategoryService.getCategories();

        // 카테고리 ID 매핑해서 예산 저장
        final cats = budgetCategories.map((c) {
          final matched = createdCats.firstWhere((cat) => cat.name == c['name']);
          print('matched.id: ${matched.id}');

          return <String, dynamic>{
            'categoryId': matched.id,
            'name': c['name'],
            'ratio': c['ratio'],
            'amount': 0,
            'includeInDaily': includeInDaily[c['name']] ?? false,
          };
        }).toList();

        // 예산 비율 저장
        final uid = userCredential.user!.uid;
        final month =
            '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

        final budget = BudgetModel(
          userId: uid,
          month: month,
          categories: cats,
          savingRatio: savingRatio,
          investRatio: investRatio,
        );

        await _budgetService.setBudget(budget);
        await _budgetService.setUserBudget(budget);
      } catch (e) {
        // Firestore 실패하면 Auth 계정도 삭제
        print('Firestore 저장 실패($e)');
        await userCredential.user!.delete();
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
    print('Firestore 저장 완료');
  }

  // 로그인
  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 탈퇴 시 연결된 데이터 삭제
  Future<void> deleteAccount(String password) async {
    await reauthenticate(password); // 재인증

    final uid = _auth.currentUser!.uid;

    final transactions = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .get();
    for (var doc in transactions.docs) {
      await doc.reference.delete();
    }

    final budgets = await _firestore
        .collection('budgets')
        .where('userId', isEqualTo: uid)
        .get();
    for (var doc in budgets.docs) {
      await doc.reference.delete();
    }

    await _firestore.collection('userBudgets').doc(uid).delete();

    final categories = await _firestore
        .collection('budgetCategories')
        .where('userId', isEqualTo: uid)
        .get();
    for (var doc in categories.docs) {
      await doc.reference.delete();
    }

    await _auth.currentUser!.delete();
  }

  // 탈퇴 전 재인증 (비밀번호)
  Future<void> reauthenticate(String password) async {
    final user = _auth.currentUser!;
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }
}
