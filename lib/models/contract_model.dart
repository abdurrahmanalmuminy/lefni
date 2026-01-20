import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lefni/l10n/app_localizations.dart';

class ContractModel {
  final String id;
  final String clientId;
  final String? caseId; // nullable reference
  final PartyType partyType;
  final String title;
  final String content; // HTML/Markdown for editing
  final List<ContractFile> files;
  final SignatureStatus signatureStatus;
  final ContractMetadata metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContractModel({
    required this.id,
    required this.clientId,
    this.caseId,
    required this.partyType,
    required this.title,
    required this.content,
    required this.files,
    required this.signatureStatus,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContractModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContractModel(
      id: doc.id,
      clientId: data['clientId'] as String,
      caseId: data['caseId'] as String?,
      partyType: PartyType.fromString(data['partyType'] as String),
      title: data['title'] as String,
      content: data['content'] as String,
      files: (data['files'] as List<dynamic>?)
              ?.map((e) => ContractFile.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      signatureStatus: SignatureStatus.fromMap(
          data['signatureStatus'] as Map<String, dynamic>),
      metadata: ContractMetadata.fromMap(
          data['metadata'] as Map<String, dynamic>),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clientId': clientId,
      if (caseId != null) 'caseId': caseId,
      'partyType': partyType.value,
      'title': title,
      'content': content,
      'files': files.map((f) => f.toMap()).toList(),
      'signatureStatus': signatureStatus.toMap(),
      'metadata': metadata.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      caseId: json['caseId'] as String?,
      partyType: PartyType.fromString(json['partyType'] as String),
      title: json['title'] as String,
      content: json['content'] as String,
      files: (json['files'] as List<dynamic>?)
              ?.map((e) => ContractFile.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      signatureStatus: SignatureStatus.fromMap(
          json['signatureStatus'] as Map<String, dynamic>),
      metadata:
          ContractMetadata.fromMap(json['metadata'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      if (caseId != null) 'caseId': caseId,
      'partyType': partyType.value,
      'title': title,
      'content': content,
      'files': files.map((f) => f.toMap()).toList(),
      'signatureStatus': signatureStatus.toMap(),
      'metadata': metadata.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ContractModel copyWith({
    String? id,
    String? clientId,
    String? caseId,
    PartyType? partyType,
    String? title,
    String? content,
    List<ContractFile>? files,
    SignatureStatus? signatureStatus,
    ContractMetadata? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContractModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      caseId: caseId ?? this.caseId,
      partyType: partyType ?? this.partyType,
      title: title ?? this.title,
      content: content ?? this.content,
      files: files ?? this.files,
      signatureStatus: signatureStatus ?? this.signatureStatus,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum PartyType {
  client('client'),
  lawyer('lawyer'),
  engineer('engineer'),
  accountant('accountant'),
  translator('translator');

  final String value;
  const PartyType(this.value);

  static PartyType fromString(String value) {
    return PartyType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PartyType.client,
    );
  }
}

extension PartyTypeLocalization on PartyType {
  String localized(AppLocalizations localizations) {
    switch (this) {
      case PartyType.client:
        return localizations.partyTypeClient;
      case PartyType.lawyer:
        return localizations.partyTypeLawyer;
      case PartyType.engineer:
        return localizations.partyTypeEngineer;
      case PartyType.accountant:
        return localizations.partyTypeAccountant;
      case PartyType.translator:
        return localizations.partyTypeTranslator;
    }
  }
}

class ContractFile {
  final String name;
  final String url;
  final FileType type;

  ContractFile({
    required this.name,
    required this.url,
    required this.type,
  });

  factory ContractFile.fromMap(Map<String, dynamic> map) {
    return ContractFile(
      name: map['name'] as String,
      url: map['url'] as String,
      type: FileType.fromString(map['type'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
      'type': type.value,
    };
  }
}

enum FileType {
  word('word'),
  pdf('pdf');

  final String value;
  const FileType(this.value);

  static FileType fromString(String value) {
    return FileType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FileType.pdf,
    );
  }
}

class SignatureStatus {
  final bool isSigned;
  final DateTime? signedAt;
  final SignatureStatusType status;
  final String? ipAddress;

  SignatureStatus({
    required this.isSigned,
    this.signedAt,
    required this.status,
    this.ipAddress,
  });

  factory SignatureStatus.fromMap(Map<String, dynamic> map) {
    return SignatureStatus(
      isSigned: map['isSigned'] as bool,
      signedAt: map['signedAt'] != null
          ? (map['signedAt'] as Timestamp).toDate()
          : null,
      status: SignatureStatusType.fromString(map['status'] as String),
      ipAddress: map['ipAddress'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isSigned': isSigned,
      if (signedAt != null) 'signedAt': Timestamp.fromDate(signedAt!),
      'status': status.value,
      if (ipAddress != null) 'ipAddress': ipAddress,
    };
  }
}

enum SignatureStatusType {
  pending('pending'),
  accepted('accepted'),
  rejected('rejected');

  final String value;
  const SignatureStatusType(this.value);

  static SignatureStatusType fromString(String value) {
    return SignatureStatusType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SignatureStatusType.pending,
    );
  }
}

class ContractMetadata {
  final bool isArchived;
  final List<String> tags;

  ContractMetadata({
    required this.isArchived,
    required this.tags,
  });

  factory ContractMetadata.fromMap(Map<String, dynamic> map) {
    return ContractMetadata(
      isArchived: map['isArchived'] as bool,
      tags: (map['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isArchived': isArchived,
      'tags': tags,
    };
  }
}

// Audit Log Model for sub-collection
class ContractAuditLog {
  final String action; // 'open', 'view', 'sign'
  final DateTime timestamp;
  final String userId;
  final String? ipAddress;
  final String? userAgent;

  ContractAuditLog({
    required this.action,
    required this.timestamp,
    required this.userId,
    this.ipAddress,
    this.userAgent,
  });

  factory ContractAuditLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContractAuditLog(
      action: data['action'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userId: data['userId'] as String,
      ipAddress: data['ipAddress'] as String?,
      userAgent: data['userAgent'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'action': action,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
      if (ipAddress != null) 'ipAddress': ipAddress,
      if (userAgent != null) 'userAgent': userAgent,
    };
  }
}

