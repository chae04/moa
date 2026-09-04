import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moa/models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 로그인한 유저 uid
  String get _uid => _auth.currentUser!.uid; // ! : null이 아님을 보장

  // 거래 추가
  Future<void> addTransaction(TransactionModel transaction) async {
    await _firestore.collection('transactions').add(transaction.toMap());
  }

  // 거래 수정
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _firestore
        .collection('transactions')
        .doc(transaction.id)
        .update(transaction.toMap());
  }

  // 거래 삭제
  Future<void> deleteTransaction(String id) async {
    await _firestore.collection('transactions').doc(id).delete();
  }

  // 이번 달 거래 조회
  Future<List<TransactionModel>> getMonthlyTransactions(int year, int month) async {
    final start = DateTime(year, month, 1); // 이번달 1일
    final end = DateTime(year, month + 1, 1); // 다음달 1일

    final snapshot = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: _uid)
        .where('date', isGreaterThanOrEqualTo: start) // 이번달 1일 이후
        .where('date', isLessThan: end) // 다음달 1일 이전
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromMap(doc.id, doc.data()))
        .toList();
  }
}
