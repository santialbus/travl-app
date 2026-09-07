import '../entities/settlement_entity.dart';

abstract class SettlementRepository {
  Stream<List<SettlementEntity>> getTripSettlements(String tripId);

  Future<SettlementEntity> createSettlement({
    required String tripId,
    required String fromUserId,
    required String toUserId,
    required double amount,
    required String currency,
  });

  Future<void> markSettlementAsPaid(String settlementId);

  Future<void> markSettlementAsPending(String settlementId);

  Future<List<SettlementEntity>> getTripSettlementsOnce(String tripId);
}
