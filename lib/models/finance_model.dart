import 'package:cloud_firestore/cloud_firestore.dart';

class FinanceModel {
  final String id;
  final FinanceType type;
  final String clientId;
  final String? caseId; // nullable reference
  final List<FinanceItem> items;
  final double subtotal;
  final double vat;
  final double total;
  final String currency; // 'SAR' default
  final FinanceStatus status;
  final String? pdfUrl;
  final DateTime? dueDate;
  final DateTime? paidAt;
  final String? paymentMethod;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;

  FinanceModel({
    required this.id,
    required this.type,
    required this.clientId,
    this.caseId,
    required this.items,
    required this.subtotal,
    required this.vat,
    required this.total,
    required this.currency,
    required this.status,
    this.pdfUrl,
    this.dueDate,
    this.paidAt,
    this.paymentMethod,
    this.notes,
    required this.createdAt,
    required this.createdBy,
  });

  factory FinanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FinanceModel(
      id: doc.id,
      type: FinanceType.fromString(data['type'] as String),
      clientId: data['clientId'] as String,
      caseId: data['caseId'] as String?,
      items: (data['items'] as List<dynamic>?)
              ?.map((e) => FinanceItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (data['subtotal'] as num).toDouble(),
      vat: (data['vat'] as num).toDouble(),
      total: (data['total'] as num).toDouble(),
      currency: data['currency'] as String? ?? 'SAR',
      status: FinanceStatus.fromString(data['status'] as String),
      pdfUrl: data['pdfUrl'] as String?,
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      paidAt: data['paidAt'] != null
          ? (data['paidAt'] as Timestamp).toDate()
          : null,
      paymentMethod: data['paymentMethod'] as String?,
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.value,
      'clientId': clientId,
      if (caseId != null) 'caseId': caseId,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'vat': vat,
      'total': total,
      'currency': currency,
      'status': status.value,
      if (pdfUrl != null) 'pdfUrl': pdfUrl,
      if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate!),
      if (paidAt != null) 'paidAt': Timestamp.fromDate(paidAt!),
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (notes != null) 'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  factory FinanceModel.fromJson(Map<String, dynamic> json) {
    return FinanceModel(
      id: json['id'] as String,
      type: FinanceType.fromString(json['type'] as String),
      clientId: json['clientId'] as String,
      caseId: json['caseId'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => FinanceItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (json['subtotal'] as num).toDouble(),
      vat: (json['vat'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'SAR',
      status: FinanceStatus.fromString(json['status'] as String),
      pdfUrl: json['pdfUrl'] as String?,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'] as String)
          : null,
      paymentMethod: json['paymentMethod'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'clientId': clientId,
      if (caseId != null) 'caseId': caseId,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'vat': vat,
      'total': total,
      'currency': currency,
      'status': status.value,
      if (pdfUrl != null) 'pdfUrl': pdfUrl,
      if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
      if (paidAt != null) 'paidAt': paidAt!.toIso8601String(),
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (notes != null) 'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  FinanceModel copyWith({
    String? id,
    FinanceType? type,
    String? clientId,
    String? caseId,
    List<FinanceItem>? items,
    double? subtotal,
    double? vat,
    double? total,
    String? currency,
    FinanceStatus? status,
    String? pdfUrl,
    DateTime? dueDate,
    DateTime? paidAt,
    String? paymentMethod,
    String? notes,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return FinanceModel(
      id: id ?? this.id,
      type: type ?? this.type,
      clientId: clientId ?? this.clientId,
      caseId: caseId ?? this.caseId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      vat: vat ?? this.vat,
      total: total ?? this.total,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      dueDate: dueDate ?? this.dueDate,
      paidAt: paidAt ?? this.paidAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

enum FinanceType {
  invoice('invoice'),
  paymentReceipt('payment_receipt'),
  expense('expense'),
  fee('fee');

  final String value;
  const FinanceType(this.value);

  static FinanceType fromString(String value) {
    return FinanceType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FinanceType.invoice,
    );
  }
}

enum FinanceStatus {
  unpaid('unpaid'),
  partial('partial'),
  paid('paid'),
  overdue('overdue'),
  draft('draft');

  final String value;
  const FinanceStatus(this.value);

  static FinanceStatus fromString(String value) {
    return FinanceStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FinanceStatus.draft,
    );
  }
}

class FinanceItem {
  final String service;
  final double price;
  final int? quantity;
  final String? description;

  FinanceItem({
    required this.service,
    required this.price,
    this.quantity,
    this.description,
  });

  factory FinanceItem.fromMap(Map<String, dynamic> map) {
    return FinanceItem(
      service: map['service'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] != null ? (map['quantity'] as num).toInt() : null,
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'service': service,
      'price': price,
      if (quantity != null) 'quantity': quantity,
      if (description != null) 'description': description,
    };
  }
}

