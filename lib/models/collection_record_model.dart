import 'package:cloud_firestore/cloud_firestore.dart';

class CollectionRecordModel {
  final String id;
  final String invoiceId; // Link to FinanceModel
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod;
  final String? receiptUrl;
  final String recordedBy;
  final DateTime createdAt;

  CollectionRecordModel({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    this.receiptUrl,
    required this.recordedBy,
    required this.createdAt,
  });

  factory CollectionRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CollectionRecordModel(
      id: doc.id,
      invoiceId: (data['invoiceId'] as String?) ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: data['paymentDate'] != null && data['paymentDate'] is Timestamp
          ? (data['paymentDate'] as Timestamp).toDate()
          : DateTime.now(),
      paymentMethod: (data['paymentMethod'] as String?) ?? '',
      receiptUrl: data['receiptUrl'] as String?,
      recordedBy: (data['recordedBy'] as String?) ?? '',
      createdAt: data['createdAt'] != null && data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'invoiceId': invoiceId,
      'amount': amount,
      'paymentDate': Timestamp.fromDate(paymentDate),
      'paymentMethod': paymentMethod,
      if (receiptUrl != null) 'receiptUrl': receiptUrl,
      'recordedBy': recordedBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

