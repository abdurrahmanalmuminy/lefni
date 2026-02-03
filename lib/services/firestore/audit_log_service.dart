import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lefni/models/audit_log_model.dart';
import 'package:lefni/exceptions/app_exceptions.dart';
import 'package:lefni/utils/logger.dart';

/// Service for managing audit logs
class AuditLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'audit_logs';

  /// Create an audit log entry
  Future<String> createAuditLog(AuditLogModel log) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            log.toFirestore(),
          );
      AppLogger.info('Audit log created: ${log.action} on ${log.resourceType}/${log.resourceId}');
      return docRef.id;
    } on FirebaseException catch (e) {
      AppLogger.error('Failed to create audit log', e);
      throw FirestoreException('Failed to create audit log: ${e.message}', code: e.code, originalError: e);
    } catch (e) {
      AppLogger.error('Failed to create audit log', e);
      throw FirestoreException('Failed to create audit log: $e', originalError: e);
    }
  }

  /// Log a user action
  Future<void> logAction({
    required String userId,
    required String userName,
    required AuditAction action,
    required String resourceType,
    required String resourceId,
    Map<String, dynamic>? changes,
    String? ipAddress,
    String? userAgent,
  }) async {
    try {
      final log = AuditLogModel(
        id: '',
        userId: userId,
        userName: userName,
        action: action.value,
        resourceType: resourceType,
        resourceId: resourceId,
        changes: changes,
        ipAddress: ipAddress,
        userAgent: userAgent,
        timestamp: DateTime.now(),
      );
      await createAuditLog(log);
    } catch (e) {
      // Don't throw - audit logging should not break the main flow
      AppLogger.warning('Failed to log action (non-critical)', e);
    }
  }

  /// Get audit logs for a specific resource
  Stream<List<AuditLogModel>> getAuditLogsForResource(
    String resourceType,
    String resourceId, {
    int limit = 50,
  }) {
    return _firestore
        .collection(_collection)
        .where('resourceType', isEqualTo: resourceType)
        .where('resourceId', isEqualTo: resourceId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AuditLogModel.fromFirestore(doc))
            .toList());
  }

  /// Get audit logs for a user
  Stream<List<AuditLogModel>> getAuditLogsForUser(
    String userId, {
    int limit = 50,
  }) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AuditLogModel.fromFirestore(doc))
            .toList());
  }

  /// Get all audit logs (admin only, paginated)
  Stream<List<AuditLogModel>> getAllAuditLogs({int limit = 50}) {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AuditLogModel.fromFirestore(doc))
            .toList());
  }

  /// Get audit logs by action type
  Stream<List<AuditLogModel>> getAuditLogsByAction(
    AuditAction action, {
    int limit = 50,
  }) {
    return _firestore
        .collection(_collection)
        .where('action', isEqualTo: action.value)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AuditLogModel.fromFirestore(doc))
            .toList());
  }
}
