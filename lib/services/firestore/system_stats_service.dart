import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lefni/models/system_stats_model.dart';

class SystemStatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'system_stats';
  final String _documentId = 'dashboard_overview';

  // Get system stats
  Future<SystemStatsModel?> getSystemStats() async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(_documentId).get();
      if (doc.exists) {
        return SystemStatsModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get system stats: $e');
    }
  }

  // Stream system stats (real-time updates)
  Stream<SystemStatsModel?> streamSystemStats() {
    return _firestore
        .collection(_collection)
        .doc(_documentId)
        .snapshots()
        .map((doc) => doc.exists ? SystemStatsModel.fromFirestore(doc) : null);
  }

  // Note: Update methods should only be called by Cloud Functions
  // These are provided for reference but should not be used from client
  Future<void> updateSystemStats(SystemStatsModel stats) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(_documentId)
          .set(stats.copyWith(lastUpdated: DateTime.now()).toFirestore());
    } catch (e) {
      throw Exception('Failed to update system stats: $e');
    }
  }
}

