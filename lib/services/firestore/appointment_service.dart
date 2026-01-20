import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lefni/models/appointment_model.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'appointments';

  Future<String> createAppointment(AppointmentModel appointment) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            appointment.toFirestore(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }

  Future<AppointmentModel?> getAppointment(String appointmentId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(appointmentId).get();
      if (doc.exists) {
        return AppointmentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get appointment: $e');
    }
  }

  Future<void> updateAppointment(AppointmentModel appointment) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(appointment.id)
          .update(appointment.toFirestore());
    } catch (e) {
      throw Exception('Failed to update appointment: $e');
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore.collection(_collection).doc(appointmentId).delete();
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }

  Stream<List<AppointmentModel>> getAllAppointments() {
    return _firestore
        .collection(_collection)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<AppointmentModel>> getAppointmentsByClient(String clientId) {
    return _firestore
        .collection(_collection)
        .where('clientId', isEqualTo: clientId)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromFirestore(doc))
            .toList());
  }

  Future<List<AppointmentModel>> getAppointmentsForDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection(_collection)
          .where('dateTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('dateTime', isLessThan: Timestamp.fromDate(endOfDay))
          .where('status', isEqualTo: AppointmentStatus.scheduled.value)
          .get();

      return snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get appointments for date: $e');
    }
  }

  Future<void> updateReminderStatus(String appointmentId, bool sent) async {
    try {
      await _firestore.collection(_collection).doc(appointmentId).update({
        'smsReminderSent': sent,
        'reminderSentAt': sent ? Timestamp.fromDate(DateTime.now()) : null,
      });
    } catch (e) {
      throw Exception('Failed to update reminder status: $e');
    }
  }
}

