import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moa/models/budget_category_model.dart';

class BudgetCategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // 카테고리 목록 불러오기
  Future<List<BudgetCategoryModel>> getCategories() async {
    final snapshot = await _firestore
        .collectionGroup('budgetCategories')
        .where('userId', isEqualTo: _uid)
        .orderBy('order')
        .get();

    return snapshot.docs
        .map((doc) => BudgetCategoryModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  // 카테고리 추가
  Future<void> addCategory(BudgetCategoryModel category) async {
    await _firestore.collection('budgetCategories').add(category.toMap());
  }

  // 카테고리 이름 수정
  Future<void> updateCategory(BudgetCategoryModel category) async {
    await _firestore
        .collection('budgetCategories')
        .doc(category.id)
        .update(category.toMap());
  }

  // 기본 카테고리 초기 생성 (회원가입 시)
  Future<void> createDefaultCategories() async {
    final defaults = [
      {'name': '생활비', 'order': 0, 'includeInDaily': true},
      {'name': '저축', 'order': 1, 'includeInDaily': true},
      {'name': '자유비', 'order': 2, 'includeInDaily': false},
      {'name': '투자', 'order': 3, 'includeInDaily': false},
    ];

    for (var c in defaults) {
      await _firestore.collection('budgetCategories').add({'userId': _uid, ...c});
    }
  }
}
