import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lefni/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Create a new user
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection(_collection).doc(user.uid).set(
            user.copyWith(createdAt: DateTime.now()).toFirestore(),
          );
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Get user by ID
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Update user
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(user.uid)
          .update(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Delete user
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Get users by role
  Stream<List<UserModel>> getUsersByRole(UserRole role) {
    return _firestore
        .collection(_collection)
        .where('role', isEqualTo: role.value)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  // Get all active users
  Stream<List<UserModel>> getAllActiveUsers() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  // Search user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user by email: $e');
    }
  }

  // Update user permissions
  Future<void> updateUserPermissions(
    String uid,
    List<String> permissions,
  ) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'permissions': permissions,
      });
    } catch (e) {
      throw Exception('Failed to update user permissions: $e');
    }
  }

  // Update last login
  Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'lastLogin': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update last login: $e');
    }
  }

  // Deactivate user
  Future<void> deactivateUser(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'isActive': false,
      });
    } catch (e) {
      throw Exception('Failed to deactivate user: $e');
    }
  }

  // Activate user
  Future<void> activateUser(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'isActive': true,
      });
    } catch (e) {
      throw Exception('Failed to activate user: $e');
    }
  }

  // Create user via cloud function (admin-created users)
  Future<String> createUserViaCloudFunction({
    required String email,
    required String password,
    String? phoneNumber,
    required UserRole role,
    required UserProfile profile,
  }) async {
    try {
      if (kIsWeb) {
        // Use HTTP call for web (dart2js compatibility)
        return await _createUserViaHttp(
          email: email,
          password: password,
          phoneNumber: phoneNumber,
          role: role,
          profile: profile,
        );
      } else {
        // Use Cloud Functions SDK for mobile
        final functions = FirebaseFunctions.instance;
        final callable = functions.httpsCallable('createUser');
        
        final result = await callable.call({
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
          'role': role.value,
          'profile': profile.toMap(),
        });

        final data = result.data as Map<String, dynamic>;
        return data['uid'] as String;
      }
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // HTTP-based implementation for web
  Future<String> _createUserViaHttp({
    required String email,
    required String password,
    String? phoneNumber,
    required UserRole role,
    required UserProfile profile,
  }) async {
    try {
      // Get current user's ID token for authentication
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated to create users');
      }

      final idToken = await currentUser.getIdToken();
      
      // Get the Cloud Functions URL for v2 callable functions
      final projectId = FirebaseAuth.instance.app.options.projectId;
      
      // For v2 callable functions, the URL format is:
      // https://REGION-PROJECT_ID.cloudfunctions.net/FUNCTION_NAME
      final functionUrl = 'https://us-central1-$projectId.cloudfunctions.net/createUser';

      // Make HTTP POST request
      final response = await http.post(
        Uri.parse(functionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'data': {
            'email': email,
            'password': password,
            if (phoneNumber != null) 'phoneNumber': phoneNumber,
            'role': role.value,
            'profile': profile.toMap(),
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        // v2 callable functions return result directly in 'result' field
        if (data['result'] != null) {
          final result = data['result'] as Map<String, dynamic>;
          if (result['uid'] != null) {
            return result['uid'] as String;
          }
          throw Exception('UID not found in response');
        }
        throw Exception('Invalid response format: missing result');
      } else {
        // Parse error response
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          final error = errorData['error'] as Map<String, dynamic>?;
          final message = error?['message'] as String? ?? 
                         errorData['message'] as String? ?? 
                         'Failed to create user (Status: ${response.statusCode})';
          throw Exception(message);
        } catch (_) {
          throw Exception('Failed to create user: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to create user: $e');
    }
  }
}

