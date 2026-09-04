import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/expense_model.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../../core/constants/firebase_constants.dart';

class ExpenseRemoteDataSource {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  ExpenseRemoteDataSource({
    FirebaseFirestore? firestore,
    Uuid? uuid,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = uuid ?? const Uuid();

  Stream<List<ExpenseModel>> getTripExpenses(String tripId) {
    return _firestore
        .collection(FirebaseConstants.expensesCollection)
        .where('tripId', isEqualTo: tripId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => ExpenseModel.fromFirestore(doc)).toList());
  }

  Future<ExpenseModel> createExpense({
    required String tripId,
    required String title,
    required double amount,
    required String currency,
    required String paidBy,
    required List<String> participants,
    required ExpenseCategory category,
  }) async {
    try {
      final id = _uuid.v4();
      final expense = ExpenseModel(
        id: id,
        tripId: tripId,
        title: title,
        amount: amount,
        currency: currency,
        paidBy: paidBy,
        participants: participants,
        category: category,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(FirebaseConstants.expensesCollection)
          .doc(id)
          .set(expense.toFirestore());

      return expense;
    } catch (e) {
      throw Exception('Failed to create expense: $e');
    }
  }

  Future<void> updateExpense({
    required String expenseId,
    required String title,
    required double amount,
    required String currency,
    required List<String> participants,
    required ExpenseCategory category,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConstants.expensesCollection)
          .doc(expenseId)
          .update({
        'title': title,
        'amount': amount,
        'currency': currency,
        'participants': participants,
        'category': category.value,
      });
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.expensesCollection)
          .doc(expenseId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }
}
