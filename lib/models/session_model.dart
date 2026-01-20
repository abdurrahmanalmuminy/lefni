import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lefni/l10n/app_localizations.dart';

class SessionModel {
  final String id;
  final String caseId;
  final String clientId;
  final String lawyerId;
  final DateTime scheduledAt;
  final SessionType type;
  final String location;
  final String? meetingLink;
  final RemindersSent remindersSent;
  final SessionReport? report;
  final SessionStatus status;
  final DateTime createdAt;

  SessionModel({
    required this.id,
    required this.caseId,
    required this.clientId,
    required this.lawyerId,
    required this.scheduledAt,
    required this.type,
    required this.location,
    this.meetingLink,
    required this.remindersSent,
    this.report,
    required this.status,
    required this.createdAt,
  });

  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SessionModel(
      id: doc.id,
      caseId: data['caseId'] as String,
      clientId: data['clientId'] as String,
      lawyerId: data['lawyerId'] as String,
      scheduledAt: (data['scheduledAt'] as Timestamp).toDate(),
      type: SessionType.fromString(data['type'] as String),
      location: data['location'] as String,
      meetingLink: data['meetingLink'] as String?,
      remindersSent: RemindersSent.fromMap(
          data['remindersSent'] as Map<String, dynamic>),
      report: data['report'] != null
          ? SessionReport.fromMap(data['report'] as Map<String, dynamic>)
          : null,
      status: SessionStatus.fromString(data['status'] as String),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'caseId': caseId,
      'clientId': clientId,
      'lawyerId': lawyerId,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'type': type.value,
      'location': location,
      if (meetingLink != null) 'meetingLink': meetingLink,
      'remindersSent': remindersSent.toMap(),
      if (report != null) 'report': report!.toMap(),
      'status': status.value,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      caseId: json['caseId'] as String,
      clientId: json['clientId'] as String,
      lawyerId: json['lawyerId'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      type: SessionType.fromString(json['type'] as String),
      location: json['location'] as String,
      meetingLink: json['meetingLink'] as String?,
      remindersSent:
          RemindersSent.fromMap(json['remindersSent'] as Map<String, dynamic>),
      report: json['report'] != null
          ? SessionReport.fromMap(json['report'] as Map<String, dynamic>)
          : null,
      status: SessionStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caseId': caseId,
      'clientId': clientId,
      'lawyerId': lawyerId,
      'scheduledAt': scheduledAt.toIso8601String(),
      'type': type.value,
      'location': location,
      if (meetingLink != null) 'meetingLink': meetingLink,
      'remindersSent': remindersSent.toMap(),
      if (report != null) 'report': report!.toMap(),
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  SessionModel copyWith({
    String? id,
    String? caseId,
    String? clientId,
    String? lawyerId,
    DateTime? scheduledAt,
    SessionType? type,
    String? location,
    String? meetingLink,
    RemindersSent? remindersSent,
    SessionReport? report,
    SessionStatus? status,
    DateTime? createdAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      caseId: caseId ?? this.caseId,
      clientId: clientId ?? this.clientId,
      lawyerId: lawyerId ?? this.lawyerId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      type: type ?? this.type,
      location: location ?? this.location,
      meetingLink: meetingLink ?? this.meetingLink,
      remindersSent: remindersSent ?? this.remindersSent,
      report: report ?? this.report,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum SessionType {
  courtHearing('court_hearing'),
  clientMeeting('client_meeting'),
  consultation('consultation');

  final String value;
  const SessionType(this.value);

  static SessionType fromString(String value) {
    return SessionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SessionType.consultation,
    );
  }
}

extension SessionTypeLocalization on SessionType {
  String localized(AppLocalizations localizations) {
    switch (this) {
      case SessionType.courtHearing:
        return localizations.sessionTypeCourtHearing;
      case SessionType.clientMeeting:
        return localizations.sessionTypeClientMeeting;
      case SessionType.consultation:
        return localizations.sessionTypeConsultation;
    }
  }
}

enum SessionStatus {
  scheduled('scheduled'),
  completed('completed'),
  cancelled('cancelled'),
  postponed('postponed');

  final String value;
  const SessionStatus(this.value);

  static SessionStatus fromString(String value) {
    return SessionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SessionStatus.scheduled,
    );
  }
}

class RemindersSent {
  final bool sms;
  final bool internal;
  final DateTime? smsSentAt;
  final DateTime? internalSentAt;

  RemindersSent({
    required this.sms,
    required this.internal,
    this.smsSentAt,
    this.internalSentAt,
  });

  factory RemindersSent.fromMap(Map<String, dynamic> map) {
    return RemindersSent(
      sms: map['sms'] as bool,
      internal: map['internal'] as bool,
      smsSentAt: map['smsSentAt'] != null
          ? (map['smsSentAt'] as Timestamp).toDate()
          : null,
      internalSentAt: map['internalSentAt'] != null
          ? (map['internalSentAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sms': sms,
      'internal': internal,
      if (smsSentAt != null) 'smsSentAt': Timestamp.fromDate(smsSentAt!),
      if (internalSentAt != null)
        'internalSentAt': Timestamp.fromDate(internalSentAt!),
    };
  }
}

class SessionReport {
  final String? content;
  final List<String> attachments;
  final String submittedBy;
  final DateTime? submittedAt;

  SessionReport({
    this.content,
    required this.attachments,
    required this.submittedBy,
    this.submittedAt,
  });

  factory SessionReport.fromMap(Map<String, dynamic> map) {
    return SessionReport(
      content: map['content'] as String?,
      attachments: (map['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      submittedBy: map['submittedBy'] as String,
      submittedAt: map['submittedAt'] != null
          ? (map['submittedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (content != null) 'content': content,
      'attachments': attachments,
      'submittedBy': submittedBy,
      if (submittedAt != null) 'submittedAt': Timestamp.fromDate(submittedAt!),
    };
  }
}

