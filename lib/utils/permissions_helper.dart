import 'package:lefni/providers/user_session_provider.dart';
import 'package:lefni/models/user_model.dart';

/// Helper class for checking user permissions
class PermissionsHelper {
  /// Check if user can perform write operations (create, update, delete)
  /// Inactive users (awaiting review) can only read
  static bool canWrite(UserSessionProvider userSession) {
    final userModel = userSession.userModel;
    if (userModel == null) return false;
    
    // Clients are always active once they complete onboarding
    if (userModel.role == UserRole.client) {
      return userModel.isActive;
    }
    
    // For other roles (lawyers, etc.), must be active to write
    return userModel.isActive;
  }
  
  /// Check if user can read data
  /// All authenticated users can read
  static bool canRead(UserSessionProvider userSession) {
    return userSession.isAuthenticated;
  }
  
  /// Check if user is awaiting review (inactive non-client)
  static bool isAwaitingReview(UserSessionProvider userSession) {
    final userModel = userSession.userModel;
    if (userModel == null) return false;
    
    // Clients don't have review status
    if (userModel.role == UserRole.client) return false;
    
    // Non-active users are awaiting review
    return !userModel.isActive;
  }
}
