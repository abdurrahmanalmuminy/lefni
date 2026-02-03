import 'package:cloud_firestore/cloud_firestore.dart';

/// Audit log model for tracking user actions and data changes
class AuditLogModel {
  final String id;
  final String userId;
  final String userName;
  final String action; // 'create', 'update', 'delete', 'view', 'sign', etc.
  final String resourceType; // 'case', 'contract', 'client', etc.
  final String resourceId;
  final Map<String, dynamic>? changes; // Field changes for updates
  final String? ipAddress;
  final String? userAgent;
  final DateTime timestamp;

  AuditLogModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.action,
    required this.resourceType,
    required this.resourceId,
    this.changes,
    this.ipAddress,
    this.userAgent,
    required this.timestamp,
  });

  factory AuditLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AuditLogModel(
      id: doc.id,
      userId: (data['userId'] as String?) ?? '',
      userName: (data['userName'] as String?) ?? '',
      action: (data['action'] as String?) ?? '',
      resourceType: (data['resourceType'] as String?) ?? '',
      resourceId: (data['resourceId'] as String?) ?? '',
      changes: data['changes'] as Map<String, dynamic>?,
      ipAddress: data['ipAddress'] as String?,
      userAgent: data['userAgent'] as String?,
      timestamp: data['timestamp'] != null && data['timestamp'] is Timestamp
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'action': action,
      'resourceType': resourceType,
      'resourceId': resourceId,
      if (changes != null) 'changes': changes,
      if (ipAddress != null) 'ipAddress': ipAddress,
      if (userAgent != null) 'userAgent': userAgent,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

enum AuditAction {
  create('create'),
  update('update'),
  delete('delete'),
  view('view'),
  sign('sign'),
  export('export'),
  import('import'),
  login('login'),
  logout('logout'),
  permissionChange('permission_change');

  final String value;
  const AuditAction(this.value);

  static AuditAction fromString(String value) {
    return AuditAction.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AuditAction.view,
    );
  }
}
