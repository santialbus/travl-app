class SettlementEntity {
  final String id;
  final String tripId;
  final String fromUserId;
  final String toUserId;
  final double amount;
  final String currency;
  final bool isPaid;
  final DateTime? paidAt;

  const SettlementEntity({
    required this.id,
    required this.tripId,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    required this.currency,
    required this.isPaid,
    this.paidAt,
  });
}
