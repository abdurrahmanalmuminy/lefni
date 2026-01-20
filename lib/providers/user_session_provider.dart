import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lefni/models/user_model.dart';
import 'package:lefni/services/auth/auth_service.dart';
import 'package:lefni/services/firestore/user_service.dart';

class UserSessionProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = true;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null && _userModel != null;
  UserRole? get userRole => _userModel?.role;

  UserSessionProvider() {
    _init();
  }

  void _init() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) async {
      _firebaseUser = user;
      if (user != null) {
        await _loadUserModel(user);
      } else {
        _userModel = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserModel(User user) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Wait for auth token to be ready before accessing Firestore
      // This ensures the token is propagated to Firestore security rules
      await user.getIdToken(true); // Force refresh to ensure token is ready
      
      // Small delay to ensure token propagation
      await Future.delayed(const Duration(milliseconds: 200));

      // Retry logic with exponential backoff for permission errors
      UserModel? model;
      int retries = 5;
      int attempt = 0;
      
      while (model == null && retries > 0) {
        try {
          model = await _userService.getUser(user.uid);
          if (model != null) {
            break; // Success, exit retry loop
          }
        } catch (e) {
          // Check if it's a permission-denied error
          final errorString = e.toString().toLowerCase();
          if (errorString.contains('permission-denied') || 
              errorString.contains('permission denied')) {
            // Permission error - wait longer and retry
            attempt++;
            if (retries > 1) {
              // Exponential backoff: 200ms, 400ms, 800ms, 1600ms
              final delayMs = 200 * (1 << (attempt - 1));
              await Future.delayed(Duration(milliseconds: delayMs));
              // Force token refresh before retry
              await user.getIdToken(true);
            }
          } else {
            // Other error - don't retry, just throw
            rethrow;
          }
        }
        retries--;
      }
      
      _userModel = model;
    } catch (e) {
      // Log error for debugging
      debugPrint('Error loading user model: $e');
      _userModel = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    if (_firebaseUser != null) {
      await _loadUserModel(_firebaseUser!);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _firebaseUser = null;
    _userModel = null;
    notifyListeners();
  }
}

