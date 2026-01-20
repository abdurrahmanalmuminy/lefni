import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lefni/models/finance_model.dart';

class FinanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'finances';

  // Create a new finance record
  Future<String> createFinance(FinanceModel finance) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            finance.copyWith(
              id: '',
              createdAt: DateTime.now(),
            ).toFirestore(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create finance record: $e');
    }
  }

  // Get finance record by ID
  Future<FinanceModel?> getFinance(String financeId) async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(financeId).get();
      if (doc.exists) {
        return FinanceModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get finance record: $e');
    }
  }

  // Update finance record
  Future<void> updateFinance(FinanceModel finance) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(finance.id)
          .update(finance.toFirestore());
    } catch (e) {
      throw Exception('Failed to update finance record: $e');
    }
  }

  // Delete finance record
  Future<void> deleteFinance(String financeId) async {
    try {
      await _firestore.collection(_collection).doc(financeId).delete();
    } catch (e) {
      throw Exception('Failed to delete finance record: $e');
    }
  }

  // Get finances by client
  Stream<List<FinanceModel>> getFinancesByClient(String clientId) {
    return _firestore
        .collection(_collection)
        .where('clientId', isEqualTo: clientId)
        .where('status', isEqualTo: FinanceStatus.unpaid.value)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FinanceModel.fromFirestore(doc))
            .toList());
  }

  // Get finances by case
  Stream<List<FinanceModel>> getFinancesByCase(String caseId) {
    return _firestore
        .collection(_collection)
        .where('caseId', isEqualTo: caseId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FinanceModel.fromFirestore(doc))
            .toList());
  }

  // Get finances by type
  Stream<List<FinanceModel>> getFinancesByType(FinanceType type) {
    return _firestore
        .collection(_collection)
        .where('type', isEqualTo: type.value)
        .where('status', isEqualTo: FinanceStatus.unpaid.value)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FinanceModel.fromFirestore(doc))
            .toList());
  }

  // Get finances by status
  Stream<List<FinanceModel>> getFinancesByStatus(FinanceStatus status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status.value)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FinanceModel.fromFirestore(doc))
            .toList());
  }

  // Get overdue finances
  Future<List<FinanceModel>> getOverdueFinances() async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: FinanceStatus.unpaid.value)
          .where('dueDate', isLessThan: Timestamp.fromDate(now))
          .orderBy('dueDate', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => FinanceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get overdue finances: $e');
    }
  }

  // Get monthly finances (for reports)
  Future<List<FinanceModel>> getMonthlyFinances({
    required DateTime month,
  }) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 1);

      final snapshot = await _firestore
          .collection(_collection)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfMonth))
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FinanceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get monthly finances: $e');
    }
  }

  // Update finance status
  Future<void> updateFinanceStatus(
    String financeId,
    FinanceStatus status,
  ) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.value,
      };
      if (status == FinanceStatus.paid) {
        updateData['paidAt'] = Timestamp.fromDate(DateTime.now());
      }
      await _firestore.collection(_collection).doc(financeId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update finance status: $e');
    }
  }

  // Mark as paid
  Future<void> markAsPaid(
    String financeId,
    String paymentMethod,
  ) async {
    try {
      await _firestore.collection(_collection).doc(financeId).update({
        'status': FinanceStatus.paid.value,
        'paidAt': Timestamp.fromDate(DateTime.now()),
        'paymentMethod': paymentMethod,
      });
    } catch (e) {
      throw Exception('Failed to mark as paid: $e');
    }
  }
}

