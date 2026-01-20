import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lefni/models/case_model.dart';

class CaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'cases';

  // Create a new case
  Future<String> createCase(CaseModel case_) async {
    try {
      final now = DateTime.now();
      final docRef = await _firestore.collection(_collection).add(
            case_.copyWith(
              id: '',
              createdAt: now,
              updatedAt: now,
            ).toFirestore(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create case: $e');
    }
  }

  // Get case by ID
  Future<CaseModel?> getCase(String caseId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(caseId).get();
      if (doc.exists) {
        return CaseModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get case: $e');
    }
  }

  // Update case
  Future<void> updateCase(CaseModel case_) async {
    try {
      await _firestore.collection(_collection).doc(case_.id).update(
            case_.copyWith(updatedAt: DateTime.now()).toFirestore(),
          );
    } catch (e) {
      throw Exception('Failed to update case: $e');
    }
  }

  // Delete case
  Future<void> deleteCase(String caseId) async {
    try {
      await _firestore.collection(_collection).doc(caseId).delete();
    } catch (e) {
      throw Exception('Failed to delete case: $e');
    }
  }

  // Get cases by client
  Stream<List<CaseModel>> getCasesByClient(String clientId) {
    return _firestore
        .collection(_collection)
        .where('clientId', isEqualTo: clientId)
        .where('status', isEqualTo: CaseStatus.active.value)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CaseModel.fromFirestore(doc)).toList());
  }

  // Get cases by lawyer
  Stream<List<CaseModel>> getCasesByLawyer(String lawyerId) {
    return _firestore
        .collection(_collection)
        .where('leadLawyerId', isEqualTo: lawyerId)
        .where('status', isEqualTo: CaseStatus.active.value)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CaseModel.fromFirestore(doc)).toList());
  }

  // Get cases by status
  Stream<List<CaseModel>> getCasesByStatus(CaseStatus status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status.value)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CaseModel.fromFirestore(doc)).toList());
  }

  // Get cases by category
  Stream<List<CaseModel>> getCasesByCategory(CaseCategory category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category.value)
        .where('status', isEqualTo: CaseStatus.active.value)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CaseModel.fromFirestore(doc)).toList());
  }

  // Search case by case number
  Future<List<CaseModel>> searchByCaseNumber(String caseNumber) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('caseNumber', isEqualTo: caseNumber)
          .get();
      return snapshot.docs
          .map((doc) => CaseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to search cases: $e');
    }
  }

  // Add collaborator to case
  Future<void> addCollaborator(
    String caseId,
    CaseCollaborator collaborator,
  ) async {
    try {
      final caseRef = _firestore.collection(_collection).doc(caseId);
      final caseDoc = await caseRef.get();
      if (caseDoc.exists) {
        final data = caseDoc.data()!;
        final collaborators = (data['collaborators'] as List<dynamic>?) ?? [];
        collaborators.add(collaborator.toMap());
        await caseRef.update({
          'collaborators': collaborators,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }
    } catch (e) {
      throw Exception('Failed to add collaborator: $e');
    }
  }

  // Update case status
  Future<void> updateCaseStatus(String caseId, CaseStatus status) async {
    try {
      final updateData = {
        'status': status.value,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };
      if (status == CaseStatus.closed) {
        updateData['closedAt'] = Timestamp.fromDate(DateTime.now());
      }
      await _firestore.collection(_collection).doc(caseId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update case status: $e');
    }
  }
}

