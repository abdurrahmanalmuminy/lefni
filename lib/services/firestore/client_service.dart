import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lefni/models/client_model.dart';
import 'package:lefni/exceptions/app_exceptions.dart';
import 'package:lefni/utils/logger.dart';
import 'package:lefni/services/cache/cache_service.dart';

class ClientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'clients';

  // Create a new client (DEPRECATED - Use createClientWithUser for admin-created clients)
  // This method should only be used for legacy clients without user accounts
  // For new clients, always use createClientWithUser() to ensure clientId == userId
  @Deprecated('Use createClientWithUser() instead to ensure clientId == userId')
  Future<String> createClient(ClientModel client) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            client.copyWith(
              id: '', // Will be set by Firestore
              createdAt: DateTime.now(),
            ).toFirestore(),
          );
      return docRef.id;
    } on FirebaseException catch (e) {
      AppLogger.error('Failed to create client', e);
      if (e.code == 'permission-denied') {
        throw FirestoreException.permissionDenied(e);
      }
      throw FirestoreException('Failed to create client: ${e.message}', code: e.code, originalError: e);
    } catch (e) {
      AppLogger.error('Failed to create client', e);
      throw FirestoreException('Failed to create client: $e', originalError: e);
    }
  }

  // Get client by ID (with caching)
  Future<ClientModel?> getClient(String clientId) async {
    try {
      // Check cache first
      final cacheKey = 'client_$clientId';
      final cached = await CacheService.get(cacheKey, (json) => ClientModel.fromJson(json));
      if (cached != null) {
        return cached;
      }

      final doc = await _firestore.collection(_collection).doc(clientId).get();
      if (doc.exists) {
        final client = ClientModel.fromFirestore(doc);
        // Cache for 15 minutes
        await CacheService.set(
          cacheKey,
          client,
          (c) => c.toJson(),
          ttl: const Duration(minutes: 15),
        );
        return client;
      }
      return null;
    } on FirebaseException catch (e) {
      AppLogger.error('Failed to get client: $clientId', e);
      if (e.code == 'permission-denied') {
        throw FirestoreException.permissionDenied(e);
      }
      throw FirestoreException('Failed to get client: ${e.message}', code: e.code, originalError: e);
    } catch (e) {
      AppLogger.error('Failed to get client: $clientId', e);
      throw FirestoreException('Failed to get client: $e', originalError: e);
    }
  }

  // Update client
  Future<void> updateClient(ClientModel client) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(client.id)
          .update(client.toFirestore());
    } on FirebaseException catch (e) {
      AppLogger.error('Failed to update client: ${client.id}', e);
      if (e.code == 'permission-denied') {
        throw FirestoreException.permissionDenied(e);
      }
      throw FirestoreException('Failed to update client: ${e.message}', code: e.code, originalError: e);
    } catch (e) {
      AppLogger.error('Failed to update client: ${client.id}', e);
      throw FirestoreException('Failed to update client: $e', originalError: e);
    }
  }

  // Delete client
  Future<void> deleteClient(String clientId) async {
    try {
      await _firestore.collection(_collection).doc(clientId).delete();
    } catch (e) {
      throw Exception('Failed to delete client: $e');
    }
  }

  // Get all clients (paginated, optimized)
  Stream<List<ClientModel>> getAllClients({int limit = 20}) {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClientModel.fromFirestore(doc))
            .toList());
  }

  // Get client list summary (optimized for list views - only essential fields)
  Future<List<Map<String, dynamic>>> getClientListSummary({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'],
          'type': data['type'],
          'contact': data['contact'],
          'createdAt': data['createdAt'],
        };
      }).toList();
    } catch (e) {
      AppLogger.error('Failed to get client list summary', e);
      throw FirestoreException('Failed to get client list: $e', originalError: e);
    }
  }

  // Get all clients with pagination support
  Future<List<ClientModel>> getAllClientsPaginated({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true);
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final snapshot = await query.limit(limit).get();
      return snapshot.docs
          .map((doc) => ClientModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Failed to get paginated clients', e);
      throw FirestoreException('Failed to get clients: $e', originalError: e);
    }
  }

  // Get clients by type
  Stream<List<ClientModel>> getClientsByType(ClientType type) {
    return _firestore
        .collection(_collection)
        .where('type', isEqualTo: type.value)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClientModel.fromFirestore(doc))
            .toList());
  }

  // Search clients by identity number
  Future<List<ClientModel>> searchByIdentityNumber(String identityNumber) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('identityNumber', isEqualTo: identityNumber)
          .get();
      return snapshot.docs
          .map((doc) => ClientModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to search clients: $e');
    }
  }

  // Update client stats
  Future<void> updateClientStats(String clientId, ClientStats stats) async {
    try {
      await _firestore.collection(_collection).doc(clientId).update({
        'stats': stats.toMap(),
      });
    } catch (e) {
      throw Exception('Failed to update client stats: $e');
    }
  }

  // Create client document for a user (when user signs up via phone)
  // Uses the user's uid as the client document ID to ensure clientId == userId
  // This maintains consistency with createClientWithUser() for access control
  Future<String> createClientForUser({
    required String userId,
    required String phoneNumber,
    String? email,
    String? address,
    String? name,
    String? region,
    String? city,
  }) async {
    try {
      // Create a basic client document linked to the user
      // Use userId as document ID to ensure clientId == userId for access control
      final client = ClientModel(
        id: userId, // Use user's uid as client document ID
        type: ClientType.individual, // Default to individual
        identityNumber: '', // Can be updated later
        name: name ?? '', // Can be updated later
        contact: ClientContact(
          phone: phoneNumber,
          email: email ?? '',
          address: _buildAddress(address, region, city),
        ),
        stats: ClientStats(
          activeCases: 0,
          totalInvoiced: 0.0,
        ),
        createdAt: DateTime.now(),
        userId: userId, // Also set userId field for reference
      );

      // Use userId as document ID instead of auto-generated ID
      await _firestore
          .collection(_collection)
          .doc(userId)
          .set(client.toFirestore());
      
      return userId; // Return userId (which is also the clientId)
    } catch (e) {
      throw Exception('Failed to create client for user: $e');
    }
  }

  // Get client by user ID
  Future<ClientModel?> getClientByUserId(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return ClientModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get client by user ID: $e');
    }
  }

  // Create client with user account (for admin-created clients)
  // This creates both a Firebase Auth user and a client document
  // The client document ID will be the user's uid, ensuring clientId == userId
  Future<String> createClientWithUser({
    required String email,
    required String password,
    required ClientModel client,
    String? region,
    String? city,
  }) async {
    try {
      // Create Firebase Auth user via Cloud Function
      String userId;
      if (kIsWeb) {
        // For web, use HTTP call
        userId = await _createClientUserViaHttp(
          email: email,
          password: password,
          name: client.name,
          phone: client.contact.phone,
          region: region,
          city: city,
        );
      } else {
        // For mobile, use Cloud Functions SDK
        final functions = FirebaseFunctions.instance;
        final callable = functions.httpsCallable('createClientUser');
        
        final result = await callable.call({
          'email': email,
          'password': password,
          'name': client.name,
          'phone': client.contact.phone,
          'region': region,
          'city': city,
        });

        final data = result.data as Map<String, dynamic>;
        userId = data['uid'] as String;
      }

      // Create client document using user's uid as document ID
      // This ensures clientId == userId for access control
      final clientWithUserId = client.copyWith(
        id: userId, // Use user's uid as client document ID
        userId: userId, // Also set userId field for reference
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(userId)
          .set(clientWithUserId.toFirestore());

      return userId; // Return the clientId (which is the userId)
    } on CloudFunctionException catch (e) {
      AppLogger.error('Failed to create client with user', e);
      rethrow;
    } on FirebaseException catch (e) {
      AppLogger.error('Failed to create client with user', e);
      if (e.code == 'permission-denied') {
        throw FirestoreException.permissionDenied(e);
      }
      throw FirestoreException('Failed to create client with user: ${e.message}', code: e.code, originalError: e);
    } catch (e) {
      AppLogger.error('Failed to create client with user', e);
      throw FirestoreException('Failed to create client with user: $e', originalError: e);
    }
  }

  // HTTP-based implementation for web
  Future<String> _createClientUserViaHttp({
    required String email,
    required String password,
    required String name,
    required String phone,
    String? region,
    String? city,
  }) async {
    try {
      // Get current user's ID token for authentication
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated to create clients');
      }

      final idToken = await currentUser.getIdToken();
      
      // Get the Cloud Functions URL
      final projectId = FirebaseAuth.instance.app.options.projectId;
      final functionUrl = 'https://us-central1-$projectId.cloudfunctions.net/createClientUser';

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
            'name': name,
            'phone': phone,
            if (region != null) 'region': region,
            if (city != null) 'city': city,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['result'] != null) {
          final result = data['result'] as Map<String, dynamic>;
          if (result['uid'] != null) {
            return result['uid'] as String;
          }
          throw Exception('UID not found in response');
        }
        throw Exception('Invalid response format: missing result');
      } else {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          final error = errorData['error'] as Map<String, dynamic>?;
          final message = error?['message'] as String? ?? 
                         errorData['message'] as String? ?? 
                         'Failed to create client user (Status: ${response.statusCode})';
          throw Exception(message);
        } catch (_) {
          throw Exception('Failed to create client user: ${response.statusCode} - ${response.body}');
        }
      }
    } on NetworkException catch (e) {
      AppLogger.error('Network error creating client user', e);
      rethrow;
    } catch (e) {
      AppLogger.error('Failed to create client user via HTTP', e);
      if (e is CloudFunctionException) {
        rethrow;
      }
      throw CloudFunctionException.failed('createClientUser', e);
    }
  }

  // Helper method to build address string from components
  String _buildAddress(String? address, String? region, String? city) {
    final parts = <String>[];
    if (address != null && address.isNotEmpty) {
      parts.add(address);
    }
    if (city != null && city.isNotEmpty) {
      parts.add(city);
    }
    if (region != null && region.isNotEmpty) {
      parts.add(region);
    }
    return parts.join(', ');
  }
}

