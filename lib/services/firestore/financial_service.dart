import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lefni/models/finance_model.dart';
import 'package:lefni/services/firestore/expense_service.dart';
import 'package:lefni/services/firestore/collection_record_service.dart';

class FinancialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ExpenseService _expenseService = ExpenseService();
  final CollectionRecordService _collectionService = CollectionRecordService();

  // Calculate total revenues from paid invoices
  Future<double> getTotalRevenues({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start = startDate ?? DateTime(DateTime.now().year, 1, 1);
      final end = endDate ?? DateTime.now();

      final snapshot = await _firestore
          .collection('finances')
          .where('type', isEqualTo: FinanceType.invoice.value)
          .where('status', isEqualTo: FinanceStatus.paid.value)
          .where('paidAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('paidAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      return snapshot.docs.fold<double>(
        0.0,
        (total, doc) {
          final data = doc.data();
          return total + (data['total'] as num).toDouble();
        },
      );
    } catch (e) {
      throw Exception('Failed to calculate total revenues: $e');
    }
  }

  // Calculate pending fees (unpaid invoices)
  Future<double> getPendingFees() async {
    try {
      final snapshot = await _firestore
          .collection('finances')
          .where('type', isEqualTo: FinanceType.fee.value)
          .where('status', whereIn: [
            FinanceStatus.unpaid.value,
            FinanceStatus.partial.value,
            FinanceStatus.overdue.value,
          ])
          .get();

      return snapshot.docs.fold<double>(
        0.0,
        (total, doc) {
          final data = doc.data();
          return total + (data['total'] as num).toDouble();
        },
      );
    } catch (e) {
      throw Exception('Failed to calculate pending fees: $e');
    }
  }

  // Calculate total expenses
  Future<double> getTotalExpenses({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start = startDate ?? DateTime(DateTime.now().year, 1, 1);
      final end = endDate ?? DateTime.now();
      return await _expenseService.getTotalExpenses(start, end);
    } catch (e) {
      throw Exception('Failed to calculate total expenses: $e');
    }
  }

  // Calculate net profit (revenues - expenses)
  Future<double> getNetProfit({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final revenues = await getTotalRevenues(startDate: startDate, endDate: endDate);
      final expenses = await getTotalExpenses(startDate: startDate, endDate: endDate);
      return revenues - expenses;
    } catch (e) {
      throw Exception('Failed to calculate net profit: $e');
    }
  }

  // Get monthly revenue breakdown
  Future<Map<String, double>> getMonthlyRevenues(int year) async {
    try {
      final Map<String, double> monthlyData = {};
      
      for (int month = 1; month <= 12; month++) {
        final start = DateTime(year, month, 1);
        final end = DateTime(year, month + 1, 1);
        final revenue = await getTotalRevenues(startDate: start, endDate: end);
        monthlyData[month.toString()] = revenue;
      }
      
      return monthlyData;
    } catch (e) {
      throw Exception('Failed to get monthly revenues: $e');
    }
  }

  // Get total collected (from collection records)
  Future<double> getTotalCollected({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start = startDate ?? DateTime(DateTime.now().year, 1, 1);
      final end = endDate ?? DateTime.now();
      return await _collectionService.getTotalCollected(start, end);
    } catch (e) {
      throw Exception('Failed to calculate total collected: $e');
    }
  }
}

