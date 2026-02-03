import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lefni/models/consultation_model.dart';
import 'package:lefni/exceptions/app_exceptions.dart';
import 'package:lefni/utils/logger.dart';

class ConsultationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'consultations';

  // Create a new consultation
  Future<String> createConsultation(ConsultationModel consultation) async {
    try {
      final now = DateTime.now();
      final docRef = await _firestore.collection(_collection).add(
            consultation.copyWith(
              id: '',
              createdAt: now,
              updatedAt: now,
            ).toFirestore(),
          );
      AppLogger.info('Consultation created: ${docRef.id}');
      return docRef.id;
    } on FirebaseException catch (e) {
      AppLogger.error('Failed to create consultation', e);
      if (e.code == 'permission-denied') {
        throw FirestoreException.permissionDenied(e);
      }
      throw FirestoreException('Failed to create consultation: ${e.message}', code: e.code, originalError: e);
    } catch (e) {
      AppLogger.error('Failed to create consultation', e);
      throw FirestoreException('Failed to create consultation: $e', originalError: e);
    }
  }

  // Get consultation by ID
  Future<ConsultationModel?> getConsultation(String consultationId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(consultationId).get();
      if (doc.exists) {
        return ConsultationModel.fromFirestore(doc);
      }
      return null;
    } on FirebaseException catch (e) {
      AppLogger.error('Failed to get consultation: $consultationId', e);
      if (e.code == 'permission-denied') {
        throw FirestoreException.permissionDenied(e);
      }
      throw FirestoreException('Failed to get consultation: ${e.message}', code: e.code, originalError: e);
    } catch (e) {
      AppLogger.error('Failed to get consultation: $consultationId', e);
      throw FirestoreException('Failed to get consultation: $e', originalError: e);
    }
  }

  // Update consultation
  Future<void> updateConsultation(ConsultationModel consultation) async {
    try {
      await _firestore.collection(_collection).doc(consultation.id).update(
            consultation.copyWith(updatedAt: DateTime.now()).toFirestore(),
          );
      AppLogger.info('Consultation updated: ${consultation.id}');
    } on FirebaseException catch (e) {
      AppLogger.error('Failed to update consultation: ${consultation.id}', e);
      if (e.code == 'permission-denied') {
        throw FirestoreException.permissionDenied(e);
      }
      throw FirestoreException('Failed to update consultation: ${e.message}', code: e.code, originalError: e);
    } catch (e) {
      AppLogger.error('Failed to update consultation: ${consultation.id}', e);
      throw FirestoreException('Failed to update consultation: $e', originalError: e);
    }
  }

  // Assign consultation to lawyer
  Future<void> assignConsultation(String consultationId, String lawyerId) async {
    try {
      await _firestore.collection(_collection).doc(consultationId).update({
        'assignedLawyerId': lawyerId,
        'assignedAt': Timestamp.fromDate(DateTime.now()),
        'status': ConsultationStatus.assigned.value,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      AppLogger.info('Consultation $consultationId assigned to lawyer $lawyerId');
    } on FirebaseException catch (e) {
      AppLogger.error('Failed to assign consultation: $consultationId', e);
      if (e.code == 'permission-denied') {
        throw FirestoreException.permissionDenied(e);
      }
      throw FirestoreException('Failed to assign consultation: ${e.message}', code: e.code, originalError: e);
    } catch (e) {
      AppLogger.error('Failed to assign consultation: $consultationId', e);
      throw FirestoreException('Failed to assign consultation: $e', originalError: e);
    }
  }

  // Get consultations by client (paginated)
  Stream<List<ConsultationModel>> getConsultationsByClient(String clientId, {int limit = 20}) {
    return _firestore
        .collection(_collection)
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConsultationModel.fromFirestore(doc))
            .toList());
  }

  // Get consultations by lawyer (paginated)
  Stream<List<ConsultationModel>> getConsultationsByLawyer(String lawyerId, {int limit = 20}) {
    return _firestore
        .collection(_collection)
        .where('assignedLawyerId', isEqualTo: lawyerId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConsultationModel.fromFirestore(doc))
            .toList());
  }

  // Get all consultations with optional status filter (paginated)
  Stream<List<ConsultationModel>> getAllConsultations({
    ConsultationStatus? status,
    int limit = 20,
  }) {
    Query query = _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true);
    
    if (status != null) {
      query = query.where('status', isEqualTo: status.value);
    }
    
    return query
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConsultationModel.fromFirestore(doc))
            .toList());
  }

  // Get pending consultations (unassigned)
  Stream<List<ConsultationModel>> getPendingConsultations({int limit = 20}) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: ConsultationStatus.pending.value)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConsultationModel.fromFirestore(doc))
            .toList());
  }

  // Delete consultation (admin only)
  Future<void> deleteConsultation(String consultationId) async {
    try {
      await _firestore.collection(_collection).doc(consultationId).delete();
      AppLogger.info('Consultation deleted: $consultationId');
    } on FirebaseException catch (e) {
      AppLogger.error('Failed to delete consultation: $consultationId', e);
      if (e.code == 'permission-denied') {
        throw FirestoreException.permissionDenied(e);
      }
      throw FirestoreException('Failed to delete consultation: ${e.message}', code: e.code, originalError: e);
    } catch (e) {
      AppLogger.error('Failed to delete consultation: $consultationId', e);
      throw FirestoreException('Failed to delete consultation: $e', originalError: e);
    }
  }
}
