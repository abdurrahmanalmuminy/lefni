import 'package:cloud_firestore/cloud_firestore.dart';

/// Generic base service for Firestore CRUD operations
abstract class BaseFirestoreService<T> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName;

  BaseFirestoreService(this.collectionName);

  /// Convert Firestore document to model
  T fromFirestore(DocumentSnapshot doc);

  /// Convert model to Firestore map
  Map<String, dynamic> toFirestore(T model);

  /// Get document ID from model
  String getId(T model);

  /// Create a new document
  Future<String> create(T model) async {
    try {
      final docRef = await _firestore.collection(collectionName).add(
            toFirestore(model),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create document: $e');
    }
  }

  /// Get document by ID
  Future<T?> getById(String id) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(id).get();
      if (doc.exists) {
        return fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get document: $e');
    }
  }

  /// Update document
  Future<void> update(T model) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(getId(model))
          .update(toFirestore(model));
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  /// Delete document
  Future<void> delete(String id) async {
    try {
      await _firestore.collection(collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  /// Get all documents
  Stream<List<T>> getAll() {
    return _firestore
        .collection(collectionName)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => fromFirestore(doc)).toList());
  }

  /// Query documents by field
  Stream<List<T>> queryByField(String field, dynamic value) {
    return _firestore
        .collection(collectionName)
        .where(field, isEqualTo: value)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => fromFirestore(doc)).toList());
  }
}

