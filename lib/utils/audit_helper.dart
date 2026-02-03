import 'package:firebase_auth/firebase_auth.dart';
import 'package:lefni/models/audit_log_model.dart';
import 'package:lefni/services/firestore/audit_log_service.dart';
import 'package:lefni/services/firestore/user_service.dart';
import 'package:lefni/utils/logger.dart';

/// Helper class for audit logging that automatically gets current user info
class AuditHelper {
  final AuditLogService _auditService = AuditLogService();
  final UserService _userService = UserService();

  /// Log an action with automatic user detection
  Future<void> logAction({
    required AuditAction action,
    required String resourceType,
    required String resourceId,
    Map<String, dynamic>? changes,
    String? ipAddress,
    String? userAgent,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        AppLogger.warning('Cannot log action: user not authenticated');
        return;
      }

      // Get user model for user name
      final userModel = await _userService.getUser(currentUser.uid);
      final userName = userModel?.profile.name ?? userModel?.email ?? currentUser.uid;

      await _auditService.logAction(
        userId: currentUser.uid,
        userName: userName,
        action: action,
        resourceType: resourceType,
        resourceId: resourceId,
        changes: changes,
        ipAddress: ipAddress,
        userAgent: userAgent,
      );
    } catch (e) {
      // Don't throw - audit logging should not break the main flow
      AppLogger.warning('Failed to log action (non-critical)', e);
    }
  }
}
