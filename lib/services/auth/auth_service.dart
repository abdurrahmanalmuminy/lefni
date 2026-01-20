import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lefni/services/firestore/user_service.dart';
import 'package:lefni/services/firestore/client_service.dart';
import 'package:lefni/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  final ClientService _clientService = ClientService();
  
  String? _verificationId;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current Firebase Auth user
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password
  Future<UserModel> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Sign in failed: No user returned');
      }

      // Wait for auth token to be ready before accessing Firestore
      await userCredential.user!.getIdToken(true);
      await Future.delayed(const Duration(milliseconds: 200));

      // Get user model from Firestore
      var userModel = await _userService.getUser(userCredential.user!.uid);
      
      // If user document doesn't exist, create it with minimal data
      if (userModel == null) {
        final newUser = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? email.trim(),
          phoneNumber: userCredential.user!.phoneNumber,
          role: UserRole.client, // Default role, admin can change later
          profile: UserProfile(),
          permissions: [],
          isActive: true,
          createdAt: DateTime.now(),
        );
        await _userService.createUser(newUser);
        userModel = newUser;
      } else {
        // Update last login timestamp only if user exists
        await _userService.updateLastLogin(userCredential.user!.uid);
      }

      // Check if user is active
      if (!userModel.isActive) {
        await signOut();
        throw Exception('User account is deactivated');
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Get current user model from Firestore
  Future<UserModel?> getCurrentUserModel() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      return await _userService.getUser(user.uid);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Sign up with email and password
  Future<UserModel> signUp(
    String email,
    String password, {
    String? phoneNumber,
    UserRole? role,
    UserProfile? profile,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Sign up failed: No user returned');
      }

      // Wait for auth token to be ready before accessing Firestore
      await userCredential.user!.getIdToken(true);
      await Future.delayed(const Duration(milliseconds: 200));

      // Create user document in Firestore with provided or default values
      final newUser = UserModel(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email ?? email.trim(),
        phoneNumber: phoneNumber ?? userCredential.user!.phoneNumber,
        role: role ?? UserRole.client, // Default role, admin can change later
        profile: profile ?? UserProfile(),
        permissions: [],
        isActive: false, // New signups are inactive until admin activates
        createdAt: DateTime.now(),
      );

      await _userService.createUser(newUser);

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  /// Send verification code to phone number
  Future<void> signInWithPhoneNumber(String phoneNumber) async {
    try {
      // For web platform, Firebase Auth automatically handles reCAPTCHA
      // Make sure reCAPTCHA is configured in Firebase Console
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-verification completed (SMS code automatically detected)
          // This is handled automatically by Firebase
        },
        verificationFailed: (FirebaseAuthException e) {
          // Handle reCAPTCHA errors specifically
          if (kIsWeb && (e.code == 'missing-recaptcha-token' || 
                         e.code == 'invalid-app-credential' ||
                         e.message?.contains('reCAPTCHA') == true)) {
            throw Exception(
              'reCAPTCHA verification failed. Please ensure reCAPTCHA is properly configured in Firebase Console and the reCAPTCHA script is loaded.'
            );
          }
          throw _handleAuthException(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to send verification code: $e');
    }
  }

  /// Verify phone number with OTP code
  Future<UserModel?> verifyPhoneNumber(
    String smsCode, {
    bool isSignUp = false,
    String? region,
    String? city,
    bool prepareSignup = false, // If true, don't create user even if isSignUp is true
  }) async {
    try {
      if (_verificationId == null) {
        throw Exception('Verification ID not found. Please request a new code.');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Verification failed: No user returned');
      }

      // Wait for auth token to be ready before accessing Firestore
      await userCredential.user!.getIdToken(true);
      await Future.delayed(const Duration(milliseconds: 200));

      // Get user model from Firestore
      var userModel = await _userService.getUser(userCredential.user!.uid);

      if (userModel == null && isSignUp && !prepareSignup) {
        // Create new user for signup
        final phoneNumber = userCredential.user!.phoneNumber ?? '';
        userModel = UserModel(
          uid: userCredential.user!.uid,
          email: '', // Phone auth doesn't provide email
          phoneNumber: phoneNumber,
          role: UserRole.client,
          profile: UserProfile(),
          permissions: [],
          isActive: false, // New signups are inactive until admin activates
          createdAt: DateTime.now(),
        );

        await _userService.createUser(userModel);

        // Create client document for the user
        await _clientService.createClientForUser(
          userId: userCredential.user!.uid,
          phoneNumber: phoneNumber,
          email: null,
          address: '',
          name: null,
          region: region,
          city: city,
        );
      } else if (userModel == null) {
        // User doesn't exist but trying to sign in
        if (prepareSignup) {
          // For signup preparation, return null - user will be created later
          return null;
        }
        // User doesn't exist but trying to sign in
        await signOut();
        throw Exception('No account found with this phone number. Please sign up first.');
      } else {
        // Update last login timestamp
        await _userService.updateLastLogin(userCredential.user!.uid);
      }

      // Check if user is active
      if (!userModel.isActive) {
        await signOut();
        throw Exception('User account is deactivated');
      }

      // Clear verification state
      _verificationId = null;

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Verification failed: $e');
    }
  }

  /// Sign up with phone number (alias for verifyPhoneNumber with isSignUp=true)
  Future<UserModel> signUpWithPhoneNumber(String phoneNumber, String smsCode, {String? region, String? city}) async {
    // First send verification code if not already sent
    if (_verificationId == null) {
      await signInWithPhoneNumber(phoneNumber);
      // Wait a bit for code to be sent
      await Future.delayed(const Duration(milliseconds: 500));
    }
    final result = await verifyPhoneNumber(smsCode, isSignUp: true, region: region, city: city);
    if (result == null) {
      throw Exception('Signup failed: Unable to create user');
    }
    return result;
  }

  /// Resend verification code
  Future<void> resendVerificationCode(String phoneNumber) async {
    _verificationId = null;
    await signInWithPhoneNumber(phoneNumber);
  }

  /// Complete phone signup after OTP verification (user is already authenticated)
  /// Creates Firestore user and client documents with region and city
  Future<UserModel> completePhoneSignup({
    required String region,
    required String city,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User not authenticated. Please verify your phone number first.');
      }

      // Wait for auth token to be ready before accessing Firestore
      await user.getIdToken(true);
      await Future.delayed(const Duration(milliseconds: 200));

      // Check if user already exists
      var userModel = await _userService.getUser(user.uid);
      
      if (userModel == null) {
        // Create new user for signup
        final phoneNumber = user.phoneNumber ?? '';
        userModel = UserModel(
          uid: user.uid,
          email: '', // Phone auth doesn't provide email
          phoneNumber: phoneNumber,
          role: UserRole.client,
          profile: UserProfile(),
          permissions: [],
          isActive: false, // New signups are inactive until admin activates
          createdAt: DateTime.now(),
        );

        await _userService.createUser(userModel);

        // Create client document for the user with region and city
        await _clientService.createClientForUser(
          userId: user.uid,
          phoneNumber: phoneNumber,
          email: null,
          address: '',
          name: null,
          region: region,
          city: city,
        );
      } else {
        // User already exists, just update last login
        await _userService.updateLastLogin(user.uid);
      }

      // Check if user is active
      if (!userModel.isActive) {
        await signOut();
        throw Exception('User account is deactivated');
      }

      return userModel;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to complete signup: $e');
    }
  }

  /// Handle Firebase Auth exceptions and return user-friendly messages
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email');
      case 'wrong-password':
        return Exception('Incorrect password');
      case 'invalid-email':
        return Exception('Invalid email address');
      case 'user-disabled':
        return Exception('This account has been disabled');
      case 'too-many-requests':
        return Exception('Too many failed attempts. Please try again later');
      case 'operation-not-allowed':
        return Exception('Sign in method is not enabled');
      case 'email-already-in-use':
        return Exception('This email is already registered');
      case 'weak-password':
        return Exception('Password is too weak. Please use a stronger password');
      case 'invalid-verification-code':
        return Exception('Invalid verification code');
      case 'invalid-phone-number':
        return Exception('Invalid phone number format');
      case 'session-expired':
        return Exception('Verification session expired. Please request a new code');
      case 'quota-exceeded':
        return Exception('SMS quota exceeded. Please try again later');
      default:
        return Exception('Authentication failed: ${e.message}');
    }
  }
}

