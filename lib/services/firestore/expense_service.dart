import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lefni/models/expense_model.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'expenses';

  Future<String> createExpense(ExpenseModel expense) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            expense.toFirestore(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create expense: $e');
    }
  }

  Future<ExpenseModel?> getExpense(String expenseId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(expenseId).get();
      if (doc.exists) {
        return ExpenseModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get expense: $e');
    }
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(expense.id)
          .update(expense.toFirestore());
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      await _firestore.collection(_collection).doc(expenseId).delete();
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }

  Stream<List<ExpenseModel>> getAllExpenses() {
    return _firestore
        .collection(_collection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseModel.fromFirestore(doc))
            .toList());
  }

  Future<List<ExpenseModel>> getExpensesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get expenses by date range: $e');
    }
  }

  Future<double> getTotalExpenses(DateTime start, DateTime end) async {
    try {
      final expenses = await getExpensesByDateRange(start, end);
      return expenses.fold<double>(0.0, (total, expense) => total + expense.amount);
    } catch (e) {
      throw Exception('Failed to calculate total expenses: $e');
    }
  }
}

