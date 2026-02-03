import 'package:cloud_firestore/cloud_firestore.dart';

class ConsultationModel {
  final String id;
  final String clientId;
  final String category; // Main category key from JSON (e.g., "personal_status")
  final String? subCategory; // Sub-category key from JSON
  final Map<String, dynamic>? caseType; // Selected case type from JSON {id, ar, en}
  final String description;
  final ConsultationStatus status;
  final String? assignedLawyerId;
  final DateTime? assignedAt;
  final String? response;
  final DateTime? responseAt;
  final List<String> attachments; // File URLs
  final DateTime createdAt;
  final DateTime updatedAt;

  ConsultationModel({
    required this.id,
    required this.clientId,
    required this.category,
    this.subCategory,
    this.caseType,
    required this.description,
    required this.status,
    this.assignedLawyerId,
    this.assignedAt,
    this.response,
    this.responseAt,
    required this.attachments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConsultationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ConsultationModel(
      id: doc.id,
      clientId: (data['clientId'] as String?) ?? '',
      category: (data['category'] as String?) ?? '',
      subCategory: data['subCategory'] as String?,
      caseType: data['caseType'] as Map<String, dynamic>?,
      description: (data['description'] as String?) ?? '',
      status: ConsultationStatus.fromString(data['status'] as String? ?? 'pending'),
      assignedLawyerId: data['assignedLawyerId'] as String?,
      assignedAt: data['assignedAt'] != null && data['assignedAt'] is Timestamp
          ? (data['assignedAt'] as Timestamp).toDate()
          : null,
      response: data['response'] as String?,
      responseAt: data['responseAt'] != null && data['responseAt'] is Timestamp
          ? (data['responseAt'] as Timestamp).toDate()
          : null,
      attachments: (data['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .whereType<String>()
              .toList() ??
          [],
      createdAt: data['createdAt'] != null && data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null && data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clientId': clientId,
      'category': category,
      if (subCategory != null) 'subCategory': subCategory,
      if (caseType != null) 'caseType': caseType,
      'description': description,
      'status': status.value,
      if (assignedLawyerId != null) 'assignedLawyerId': assignedLawyerId,
      if (assignedAt != null) 'assignedAt': Timestamp.fromDate(assignedAt!),
      if (response != null) 'response': response,
      if (responseAt != null) 'responseAt': Timestamp.fromDate(responseAt!),
      'attachments': attachments,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ConsultationModel copyWith({
    String? id,
    String? clientId,
    String? category,
    String? subCategory,
    Map<String, dynamic>? caseType,
    String? description,
    ConsultationStatus? status,
    String? assignedLawyerId,
    DateTime? assignedAt,
    String? response,
    DateTime? responseAt,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConsultationModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      caseType: caseType ?? this.caseType,
      description: description ?? this.description,
      status: status ?? this.status,
      assignedLawyerId: assignedLawyerId ?? this.assignedLawyerId,
      assignedAt: assignedAt ?? this.assignedAt,
      response: response ?? this.response,
      responseAt: responseAt ?? this.responseAt,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum ConsultationStatus {
  pending('pending'),
  assigned('assigned'),
  inProgress('in_progress'),
  completed('completed'),
  cancelled('cancelled');

  final String value;
  const ConsultationStatus(this.value);

  static ConsultationStatus fromString(String value) {
    return ConsultationStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ConsultationStatus.pending,
    );
  }
}
