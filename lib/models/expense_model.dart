import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String? receiptImageUrl;
  final String? description;
  final String createdBy;
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.receiptImageUrl,
    this.description,
    required this.createdBy,
    required this.createdAt,
  });

  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseModel(
      id: doc.id,
      category: data['category'] as String,
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      receiptImageUrl: data['receiptImageUrl'] as String?,
      description: data['description'] as String?,
      createdBy: data['createdBy'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'category': category,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      if (receiptImageUrl != null) 'receiptImageUrl': receiptImageUrl,
      if (description != null) 'description': description,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

