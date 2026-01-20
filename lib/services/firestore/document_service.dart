import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lefni/models/document_model.dart';

class DocumentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'documents';

  Future<String> createDocument(DocumentModel document) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            document.toFirestore(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create document: $e');
    }
  }

  Future<DocumentModel?> getDocument(String documentId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(documentId).get();
      if (doc.exists) {
        return DocumentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get document: $e');
    }
  }

  Future<void> updateDocument(DocumentModel document) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(document.id)
          .update(document.toFirestore());
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      await _firestore.collection(_collection).doc(documentId).delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  Stream<List<DocumentModel>> getAllDocuments() {
    return _firestore
        .collection(_collection)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DocumentModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<DocumentModel>> getDocumentsByCategory(DocumentCategory category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category.value)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DocumentModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<DocumentModel>> getDocumentsByCase(String caseId) {
    return _firestore
        .collection(_collection)
        .where('caseId', isEqualTo: caseId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DocumentModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<DocumentModel>> getDocumentsByClient(String clientId) {
    return _firestore
        .collection(_collection)
        .where('clientId', isEqualTo: clientId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DocumentModel.fromFirestore(doc))
            .toList());
  }

  Future<List<DocumentModel>> searchDocuments(String query) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('fileName', isGreaterThanOrEqualTo: query)
          .where('fileName', isLessThanOrEqualTo: '$query\uf8ff')
          .get();
      return snapshot.docs
          .map((doc) => DocumentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to search documents: $e');
    }
  }
}

