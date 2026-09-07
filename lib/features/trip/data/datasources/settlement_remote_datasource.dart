import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travl/features/trip/data/datasources/expense_remote_datasource.dart';
import 'package:uuid/uuid.dart';

import '../models/settlement_model.dart';
import '../../../../core/constants/firebase_constants.dart';

class SettlementRemoteDataSource {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  final ExpenseRemoteDataSource _expenseDataSource;

  SettlementRemoteDataSource({
    FirebaseFirestore? firestore,
    Uuid? uuid,
    ExpenseRemoteDataSource? expenseDataSource,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = uuid ?? const Uuid(),
        _expenseDataSource = expenseDataSource ?? ExpenseRemoteDataSource();

  Stream<List<SettlementModel>> getTripSettlements(String tripId) {
    return _firestore
        .collection(FirebaseConstants.settlementsCollection)
        .where('tripId', isEqualTo: tripId)
        .orderBy('isPaid')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => SettlementModel.fromFirestore(doc))
            .toList());
  }

  Future<SettlementModel> createSettlement({
    required String tripId,
    required String fromUserId,
    required String toUserId,
    required double amount,
    required String currency,
  }) async {
    try {
      final id = _uuid.v4();

      final settlement = SettlementModel(
        id: id,
        tripId: tripId,
        fromUserId: fromUserId,
        toUserId: toUserId,
        amount: amount,
        currency: currency,
        isPaid: false,
        paidAt: null,
      );

      await _firestore
          .collection(FirebaseConstants.settlementsCollection)
          .doc(id)
          .set(settlement.toFirestore());

      return settlement;
    } catch (e) {
      throw Exception('Failed to create settlement: $e');
    }
  }

  Future<void> markSettlementAsPaid(String settlementId) async {
    try {
      final settlementDoc = await _firestore
          .collection(FirebaseConstants.settlementsCollection)
          .doc(settlementId)
          .get();

      if (!settlementDoc.exists) {
        throw Exception('Settlement not found');
      }

      final settlement = SettlementModel.fromFirestore(settlementDoc);

      if (settlement.isPaid) {
        return;
      }

      await _expenseDataSource.createSettlementExpense(
        tripId: settlement.tripId,
        amount: settlement.amount,
        currency: settlement.currency,
        paidBy: settlement.fromUserId,
        paidTo: settlement.toUserId,
      );

      await _firestore
          .collection(FirebaseConstants.settlementsCollection)
          .doc(settlementId)
          .update({
        'isPaid': true,
        'paidAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to mark settlement as paid: $e');
    }
  }

  Future<void> markSettlementAsPending(String settlementId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.settlementsCollection)
          .doc(settlementId)
          .update({
        'isPaid': false,
        'paidAt': null,
      });
    } catch (e) {
      throw Exception('Failed to mark settlement as pending: $e');
    }
  }

  Future<List<SettlementModel>> getTripSettlementsOnce(String tripId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.settlementsCollection)
          .where('tripId', isEqualTo: tripId)
          .get();

      return snapshot.docs
          .map((doc) => SettlementModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get settlements: $e');
    }
  }
}
