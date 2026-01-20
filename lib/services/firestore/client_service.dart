import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lefni/models/client_model.dart';

class ClientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'clients';

  // Create a new client
  Future<String> createClient(ClientModel client) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            client.copyWith(
              id: '', // Will be set by Firestore
              createdAt: DateTime.now(),
            ).toFirestore(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create client: $e');
    }
  }

  // Get client by ID
  Future<ClientModel?> getClient(String clientId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(clientId).get();
      if (doc.exists) {
        return ClientModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get client: $e');
    }
  }

  // Update client
  Future<void> updateClient(ClientModel client) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(client.id)
          .update(client.toFirestore());
    } catch (e) {
      throw Exception('Failed to update client: $e');
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

  // Get all clients
  Stream<List<ClientModel>> getAllClients() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClientModel.fromFirestore(doc))
            .toList());
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

  // Create client document for a user (when user signs up)
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
      final client = ClientModel(
        id: '', // Will be set by Firestore
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
        userId: userId,
      );

      final docRef = await _firestore.collection(_collection).add(
            client.toFirestore(),
          );
      return docRef.id;
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

