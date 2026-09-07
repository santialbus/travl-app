import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/settlement_entity.dart';

class SettlementModel extends SettlementEntity {
  const SettlementModel({
    required super.id,
    required super.tripId,
    required super.fromUserId,
    required super.toUserId,
    required super.amount,
    required super.currency,
    required super.isPaid,
    super.paidAt,
  });

  factory SettlementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SettlementModel(
      id: doc.id,
      tripId: data['tripId'] as String,
      fromUserId: data['fromUserId'] as String,
      toUserId: data['toUserId'] as String,
      amount: (data['amount'] as num).toDouble(),
      currency: data['currency'] as String,
      isPaid: data['isPaid'] as bool? ?? false,
      paidAt: data['paidAt'] != null
          ? (data['paidAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'tripId': tripId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'amount': amount,
      'currency': currency,
      'isPaid': isPaid,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
    };
  }
}
