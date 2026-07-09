import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String userId;
  String title;
  int amount;
  String type; // income / expense / saving
  String category;
  String? budgetCategory; // expense / saving만 사용, 수입은 null (? : null 허용)
  DateTime date;
  String? memo;
  final DateTime createdAt;
  DateTime? updatedAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    this.budgetCategory, // null 가능
    required this.date,
    this.memo,
    required this.createdAt,
    this.updatedAt,
  });

  // Firestore에 저장할 때 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'budgetCategory': budgetCategory,
      'date': date,
      'memo': memo,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Firestore에서 불러올 때 Map을 모델로 변환
  factory TransactionModel.fromMap(String id, Map<String, dynamic> map) {
    return TransactionModel(
      id: id,
      userId: map['userId'],
      title: map['title'],
      amount: map['amount'],
      type: map['type'],
      category: map['category'],
      budgetCategory: map['budgetcategory'],
      date: (map['date'] as Timestamp).toDate(),
      memo: map['memo'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
}
