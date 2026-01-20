import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lefni/models/session_model.dart';

class SessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'sessions';

  // Create a new session
  Future<String> createSession(SessionModel session) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            session.copyWith(
              id: '',
              createdAt: DateTime.now(),
            ).toFirestore(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create session: $e');
    }
  }

  // Get session by ID
  Future<SessionModel?> getSession(String sessionId) async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(sessionId).get();
      if (doc.exists) {
        return SessionModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get session: $e');
    }
  }

  // Update session
  Future<void> updateSession(SessionModel session) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(session.id)
          .update(session.toFirestore());
    } catch (e) {
      throw Exception('Failed to update session: $e');
    }
  }

  // Delete session
  Future<void> deleteSession(String sessionId) async {
    try {
      await _firestore.collection(_collection).doc(sessionId).delete();
    } catch (e) {
      throw Exception('Failed to delete session: $e');
    }
  }

  // Get sessions by case
  Stream<List<SessionModel>> getSessionsByCase(String caseId) {
    return _firestore
        .collection(_collection)
        .where('caseId', isEqualTo: caseId)
        .orderBy('scheduledAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SessionModel.fromFirestore(doc))
            .toList());
  }

  // Get sessions by lawyer
  Stream<List<SessionModel>> getSessionsByLawyer(String lawyerId) {
    return _firestore
        .collection(_collection)
        .where('lawyerId', isEqualTo: lawyerId)
        .orderBy('scheduledAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SessionModel.fromFirestore(doc))
            .toList());
  }

  // Get sessions by client
  Stream<List<SessionModel>> getSessionsByClient(String clientId) {
    return _firestore
        .collection(_collection)
        .where('clientId', isEqualTo: clientId)
        .orderBy('scheduledAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SessionModel.fromFirestore(doc))
            .toList());
  }

  // Get all sessions
  Stream<List<SessionModel>> getAllSessions() {
    return _firestore
        .collection(_collection)
        .orderBy('scheduledAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SessionModel.fromFirestore(doc))
            .toList());
  }

  // Get upcoming sessions (for calendar)
  Stream<List<SessionModel>> getUpcomingSessions({DateTime? startDate}) {
    final start = startDate ?? DateTime.now();
    return _firestore
        .collection(_collection)
        .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('status', isEqualTo: SessionStatus.scheduled.value)
        .orderBy('scheduledAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SessionModel.fromFirestore(doc))
            .toList());
  }

  // Get sessions for tomorrow (for reminders)
  Future<List<SessionModel>> getSessionsForTomorrow() async {
    try {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final startOfDay = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection(_collection)
          .where('scheduledAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('scheduledAt', isLessThan: Timestamp.fromDate(endOfDay))
          .where('status', isEqualTo: SessionStatus.scheduled.value)
          .get();

      return snapshot.docs
          .map((doc) => SessionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get sessions for tomorrow: $e');
    }
  }

  // Update reminder status
  Future<void> updateReminderStatus(
    String sessionId,
    RemindersSent remindersSent,
  ) async {
    try {
      await _firestore.collection(_collection).doc(sessionId).update({
        'remindersSent': remindersSent.toMap(),
      });
    } catch (e) {
      throw Exception('Failed to update reminder status: $e');
    }
  }

  // Submit session report
  Future<void> submitSessionReport(
    String sessionId,
    SessionReport report,
  ) async {
    try {
      await _firestore.collection(_collection).doc(sessionId).update({
        'report': report.toMap(),
        'status': SessionStatus.completed.value,
      });
    } catch (e) {
      throw Exception('Failed to submit session report: $e');
    }
  }
}

