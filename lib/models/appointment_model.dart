import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String clientId;
  final DateTime dateTime;
  final String purpose;
  final AppointmentStatus status;
  final bool smsReminderSent;
  final DateTime? reminderSentAt;
  final String createdBy;
  final DateTime createdAt;

  AppointmentModel({
    required this.id,
    required this.clientId,
    required this.dateTime,
    required this.purpose,
    required this.status,
    required this.smsReminderSent,
    this.reminderSentAt,
    required this.createdBy,
    required this.createdAt,
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppointmentModel(
      id: doc.id,
      clientId: (data['clientId'] as String?) ?? '',
      dateTime: data['dateTime'] != null && data['dateTime'] is Timestamp
          ? (data['dateTime'] as Timestamp).toDate()
          : DateTime.now(),
      purpose: (data['purpose'] as String?) ?? '',
      status: AppointmentStatus.fromString(data['status'] as String? ?? 'scheduled'),
      smsReminderSent: data['smsReminderSent'] as bool? ?? false,
      reminderSentAt: data['reminderSentAt'] != null && data['reminderSentAt'] is Timestamp
          ? (data['reminderSentAt'] as Timestamp).toDate()
          : null,
      createdBy: (data['createdBy'] as String?) ?? '',
      createdAt: data['createdAt'] != null && data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clientId': clientId,
      'dateTime': Timestamp.fromDate(dateTime),
      'purpose': purpose,
      'status': status.value,
      'smsReminderSent': smsReminderSent,
      if (reminderSentAt != null) 'reminderSentAt': Timestamp.fromDate(reminderSentAt!),
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

enum AppointmentStatus {
  scheduled('scheduled'),
  cancelled('cancelled'),
  done('done');

  final String value;
  const AppointmentStatus(this.value);

  static AppointmentStatus fromString(String value) {
    return AppointmentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AppointmentStatus.scheduled,
    );
  }
}

