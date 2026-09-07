import '../../domain/entities/settlement_entity.dart';
import '../../domain/repositories/settlement_repository.dart';
import '../datasources/settlement_remote_datasource.dart';

class SettlementRepositoryImpl implements SettlementRepository {
  final SettlementRemoteDataSource _dataSource;

  SettlementRepositoryImpl(this._dataSource);

  @override
  Stream<List<SettlementEntity>> getTripSettlements(String tripId) {
    return _dataSource.getTripSettlements(tripId);
  }

  @override
  Future<SettlementEntity> createSettlement({
    required String tripId,
    required String fromUserId,
    required String toUserId,
    required double amount,
    required String currency,
  }) async {
    return await _dataSource.createSettlement(
      tripId: tripId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      amount: amount,
      currency: currency,
    );
  }

  @override
  Future<void> markSettlementAsPaid(String settlementId) async {
    await _dataSource.markSettlementAsPaid(settlementId);
  }

  @override
  Future<void> markSettlementAsPending(String settlementId) async {
    await _dataSource.markSettlementAsPending(settlementId);
  }

  @override
  Future<List<SettlementEntity>> getTripSettlementsOnce(String tripId) {
    return _dataSource.getTripSettlementsOnce(tripId);
  }
}
