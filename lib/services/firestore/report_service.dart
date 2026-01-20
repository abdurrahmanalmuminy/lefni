import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lefni/models/case_model.dart';
import 'package:lefni/services/firestore/financial_service.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FinancialService _financialService = FinancialService();

  // Monthly report data
  Future<Map<String, dynamic>> getMonthlyReport(int year, int month) async {
    try {
      final start = DateTime(year, month, 1);
      final end = DateTime(year, month + 1, 1);

      // Get cases stats
      final casesSnapshot = await _firestore
          .collection('cases')
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThan: Timestamp.fromDate(end))
          .get();

      final newCases = casesSnapshot.docs.length;
      final closedCases = casesSnapshot.docs
          .where((doc) => doc.data()['status'] == CaseStatus.closed.value)
          .length;

      // Get financial data
      final revenues = await _financialService.getTotalRevenues(
        startDate: start,
        endDate: end,
      );
      final expenses = await _financialService.getTotalExpenses(
        startDate: start,
        endDate: end,
      );

      // Get clients
      final clientsSnapshot = await _firestore
          .collection('clients')
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThan: Timestamp.fromDate(end))
          .get();

      return {
        'year': year,
        'month': month,
        'newCases': newCases,
        'closedCases': closedCases,
        'revenues': revenues,
        'expenses': expenses,
        'profit': revenues - expenses,
        'newClients': clientsSnapshot.docs.length,
      };
    } catch (e) {
      throw Exception('Failed to generate monthly report: $e');
    }
  }

  // Yearly report data
  Future<Map<String, dynamic>> getYearlyReport(int year) async {
    try {
      final start = DateTime(year, 1, 1);
      final end = DateTime(year + 1, 1, 1);

      final casesSnapshot = await _firestore
          .collection('cases')
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThan: Timestamp.fromDate(end))
          .get();

      final revenues = await _financialService.getTotalRevenues(
        startDate: start,
        endDate: end,
      );
      final expenses = await _financialService.getTotalExpenses(
        startDate: start,
        endDate: end,
      );

      final clientsSnapshot = await _firestore
          .collection('clients')
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThan: Timestamp.fromDate(end))
          .get();

      return {
        'year': year,
        'totalCases': casesSnapshot.docs.length,
        'activeCases': casesSnapshot.docs
            .where((doc) => doc.data()['status'] == CaseStatus.active.value)
            .length,
        'closedCases': casesSnapshot.docs
            .where((doc) => doc.data()['status'] == CaseStatus.closed.value)
            .length,
        'revenues': revenues,
        'expenses': expenses,
        'profit': revenues - expenses,
        'totalClients': clientsSnapshot.docs.length,
        'monthlyBreakdown': await _financialService.getMonthlyRevenues(year),
      };
    } catch (e) {
      throw Exception('Failed to generate yearly report: $e');
    }
  }

  // Cases statistics
  Future<Map<String, dynamic>> getCasesStats() async {
    try {
      final snapshot = await _firestore.collection('cases').get();

      final total = snapshot.docs.length;
      final byStatus = <String, int>{};
      final byCategory = <String, int>{};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String;
        final category = data['category'] as String;

        byStatus[status] = (byStatus[status] ?? 0) + 1;
        byCategory[category] = (byCategory[category] ?? 0) + 1;
      }

      return {
        'total': total,
        'byStatus': byStatus,
        'byCategory': byCategory,
        'active': byStatus[CaseStatus.active.value] ?? 0,
        'closed': byStatus[CaseStatus.closed.value] ?? 0,
        'prospect': byStatus[CaseStatus.prospect.value] ?? 0,
      };
    } catch (e) {
      throw Exception('Failed to get cases statistics: $e');
    }
  }

  // Client reports
  Future<Map<String, dynamic>> getClientReports(String? clientId) async {
    try {
      QuerySnapshot snapshot;
      if (clientId != null) {
        snapshot = await _firestore
            .collection('clients')
            .where(FieldPath.documentId, isEqualTo: clientId)
            .get();
      } else {
        snapshot = await _firestore.collection('clients').get();
      }

      final clients = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'],
          'type': data['type'],
          'activeCases': data['stats']?['activeCases'] ?? 0,
          'totalInvoiced': data['stats']?['totalInvoiced'] ?? 0.0,
        };
      }).toList();

      return {
        'totalClients': clients.length,
        'individuals': clients.where((c) => c['type'] == 'individual').length,
        'businesses': clients.where((c) => c['type'] == 'business').length,
        'clients': clients,
      };
    } catch (e) {
      throw Exception('Failed to get client reports: $e');
    }
  }

  // Financial reports
  Future<Map<String, dynamic>> getFinancialReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start = startDate ?? DateTime(DateTime.now().year, 1, 1);
      final end = endDate ?? DateTime.now();

      final revenues = await _financialService.getTotalRevenues(
        startDate: start,
        endDate: end,
      );
      final expenses = await _financialService.getTotalExpenses(
        startDate: start,
        endDate: end,
      );
      final collected = await _financialService.getTotalCollected(
        startDate: start,
        endDate: end,
      );
      final pending = await _financialService.getPendingFees();

      return {
        'revenues': revenues,
        'expenses': expenses,
        'profit': revenues - expenses,
        'collected': collected,
        'pending': pending,
        'startDate': start.toIso8601String(),
        'endDate': end.toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to generate financial report: $e');
    }
  }

  // Performance reports
  Future<Map<String, dynamic>> getPerformanceReport() async {
    try {
      // Get task completion stats
      final tasksSnapshot = await _firestore.collection('tasks').get();
      final totalTasks = tasksSnapshot.docs.length;
      final completedTasks = tasksSnapshot.docs
          .where((doc) => doc.data()['status'] == 'completed')
          .length;

      // Get session stats
      final sessionsSnapshot = await _firestore.collection('sessions').get();
      final totalSessions = sessionsSnapshot.docs.length;
      final completedSessions = sessionsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'completed')
          .length;

      // Get user activity (last 30 days)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final usersSnapshot = await _firestore
          .collection('users')
          .where('lastLogin',
              isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      return {
        'taskCompletionRate': totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0,
        'sessionCompletionRate': totalSessions > 0 ? (completedSessions / totalSessions) * 100 : 0,
        'activeUsers': usersSnapshot.docs.length,
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'totalSessions': totalSessions,
        'completedSessions': completedSessions,
      };
    } catch (e) {
      throw Exception('Failed to generate performance report: $e');
    }
  }
}

