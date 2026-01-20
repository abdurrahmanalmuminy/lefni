import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lefni/models/collection_record_model.dart';

class CollectionRecordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'collection_records';

  Future<String> createRecord(CollectionRecordModel record) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            record.toFirestore(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create collection record: $e');
    }
  }

  Future<CollectionRecordModel?> getRecord(String recordId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(recordId).get();
      if (doc.exists) {
        return CollectionRecordModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get collection record: $e');
    }
  }

  Future<void> updateRecord(CollectionRecordModel record) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(record.id)
          .update(record.toFirestore());
    } catch (e) {
      throw Exception('Failed to update collection record: $e');
    }
  }

  Future<void> deleteRecord(String recordId) async {
    try {
      await _firestore.collection(_collection).doc(recordId).delete();
    } catch (e) {
      throw Exception('Failed to delete collection record: $e');
    }
  }

  Stream<List<CollectionRecordModel>> getAllRecords() {
    return _firestore
        .collection(_collection)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CollectionRecordModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<CollectionRecordModel>> getRecordsByInvoice(String invoiceId) {
    return _firestore
        .collection(_collection)
        .where('invoiceId', isEqualTo: invoiceId)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CollectionRecordModel.fromFirestore(doc))
            .toList());
  }

  Future<List<CollectionRecordModel>> getRecordsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('paymentDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('paymentDate', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('paymentDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CollectionRecordModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get records by date range: $e');
    }
  }

  Future<double> getTotalCollected(DateTime start, DateTime end) async {
    try {
      final records = await getRecordsByDateRange(start, end);
      return records.fold<double>(0.0, (total, record) => total + record.amount);
    } catch (e) {
      throw Exception('Failed to calculate total collected: $e');
    }
  }
}

