import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lefni/l10n/app_localizations.dart';

class CaseModel {
  final String id;
  final String caseNumber;
  final String clientId;
  final String leadLawyerId;
  // Classification fields from Saudi court classifications JSON
  final String category; // Main category key from JSON (e.g., "personal_status")
  final String? subCategory; // Sub-category key from JSON
  final Map<String, dynamic>? caseType; // Selected case type from JSON {id, ar, en}
  final CaseStatus status;
  final CourtDetails courtDetails;
  final List<CaseCollaborator> collaborators;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? closedAt;

  CaseModel({
    required this.id,
    required this.caseNumber,
    required this.clientId,
    required this.leadLawyerId,
    required this.category,
    this.subCategory,
    this.caseType,
    required this.status,
    required this.courtDetails,
    required this.collaborators,
    required this.createdAt,
    required this.updatedAt,
    this.closedAt,
  });

  factory CaseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CaseModel(
      id: doc.id,
      caseNumber: (data['caseNumber'] as String?) ?? '',
      clientId: (data['clientId'] as String?) ?? '',
      leadLawyerId: (data['leadLawyerId'] as String?) ?? '',
      category: (data['category'] as String?) ?? '',
      subCategory: data['subCategory'] as String?,
      caseType: data['caseType'] as Map<String, dynamic>?,
      status: CaseStatus.fromString(data['status'] as String? ?? 'prospect'),
      courtDetails: CourtDetails.fromMap(
          data['courtDetails'] as Map<String, dynamic>? ?? {}),
      collaborators: (data['collaborators'] as List<dynamic>?)
              ?.map((e) {
                try {
                  return CaseCollaborator.fromMap(e as Map<String, dynamic>);
                } catch (_) {
                  return null;
                }
              })
              .whereType<CaseCollaborator>()
              .toList() ??
          [],
      createdAt: data['createdAt'] != null && data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null && data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      closedAt: data['closedAt'] != null && data['closedAt'] is Timestamp
          ? (data['closedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'caseNumber': caseNumber,
      'clientId': clientId,
      'leadLawyerId': leadLawyerId,
      'category': category,
      if (subCategory != null) 'subCategory': subCategory,
      if (caseType != null) 'caseType': caseType,
      'status': status.value,
      'courtDetails': courtDetails.toMap(),
      'collaborators': collaborators.map((c) => c.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (closedAt != null) 'closedAt': Timestamp.fromDate(closedAt!),
    };
  }

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: json['id'] as String,
      caseNumber: json['caseNumber'] as String,
      clientId: json['clientId'] as String,
      leadLawyerId: json['leadLawyerId'] as String,
      category: json['category'] as String,
      subCategory: json['subCategory'] as String?,
      caseType: json['caseType'] as Map<String, dynamic>?,
      status: CaseStatus.fromString(json['status'] as String),
      courtDetails:
          CourtDetails.fromMap(json['courtDetails'] as Map<String, dynamic>),
      collaborators: (json['collaborators'] as List<dynamic>?)
              ?.map((e) => CaseCollaborator.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      closedAt: json['closedAt'] != null
          ? DateTime.parse(json['closedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caseNumber': caseNumber,
      'clientId': clientId,
      'leadLawyerId': leadLawyerId,
      'category': category,
      if (subCategory != null) 'subCategory': subCategory,
      if (caseType != null) 'caseType': caseType,
      'status': status.value,
      'courtDetails': courtDetails.toMap(),
      'collaborators': collaborators.map((c) => c.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (closedAt != null) 'closedAt': closedAt!.toIso8601String(),
    };
  }

  CaseModel copyWith({
    String? id,
    String? caseNumber,
    String? clientId,
    String? leadLawyerId,
    String? category,
    String? subCategory,
    Map<String, dynamic>? caseType,
    CaseStatus? status,
    CourtDetails? courtDetails,
    List<CaseCollaborator>? collaborators,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? closedAt,
  }) {
    return CaseModel(
      id: id ?? this.id,
      caseNumber: caseNumber ?? this.caseNumber,
      clientId: clientId ?? this.clientId,
      leadLawyerId: leadLawyerId ?? this.leadLawyerId,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      caseType: caseType ?? this.caseType,
      status: status ?? this.status,
      courtDetails: courtDetails ?? this.courtDetails,
      collaborators: collaborators ?? this.collaborators,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      closedAt: closedAt ?? this.closedAt,
    );
  }
}

// CaseCategory enum removed - now using JSON classifications
// category, subCategory, and caseType fields from Saudi court classifications JSON

enum CaseStatus {
  prospect('prospect'),
  active('active'),
  closed('closed');

  final String value;
  const CaseStatus(this.value);

  static CaseStatus fromString(String value) {
    return CaseStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CaseStatus.prospect,
    );
  }
}

extension CaseStatusLocalization on CaseStatus {
  String localized(AppLocalizations localizations) {
    switch (this) {
      case CaseStatus.prospect:
        return localizations.caseStatusProspect;
      case CaseStatus.active:
        return localizations.caseStatusActive;
      case CaseStatus.closed:
        return localizations.caseStatusClosed;
    }
  }
}

class CourtDetails {
  final String courtName;
  final String circuit;
  final String? judge;

  CourtDetails({
    required this.courtName,
    required this.circuit,
    this.judge,
  });

  factory CourtDetails.fromMap(Map<String, dynamic> map) {
    return CourtDetails(
      courtName: (map['courtName'] as String?) ?? '',
      circuit: (map['circuit'] as String?) ?? '',
      judge: map['judge'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courtName': courtName,
      'circuit': circuit,
      if (judge != null) 'judge': judge,
    };
  }
}

class CaseCollaborator {
  final String userId;
  final CollaboratorRole role;
  final DateTime assignedAt;

  CaseCollaborator({
    required this.userId,
    required this.role,
    required this.assignedAt,
  });

  factory CaseCollaborator.fromMap(Map<String, dynamic> map) {
    return CaseCollaborator(
      userId: (map['userId'] as String?) ?? '',
      role: CollaboratorRole.fromString(map['role'] as String? ?? 'engineer'),
      assignedAt: map['assignedAt'] != null && map['assignedAt'] is Timestamp
          ? (map['assignedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'role': role.value,
      'assignedAt': Timestamp.fromDate(assignedAt),
    };
  }
}

enum CollaboratorRole {
  engineer('engineer'),
  translator('translator'),
  accountant('accountant');

  final String value;
  const CollaboratorRole(this.value);

  static CollaboratorRole fromString(String value) {
    return CollaboratorRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CollaboratorRole.engineer,
    );
  }
}

