import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travl/features/trip/presentation/providers/expenses_provider.dart';

import '../../data/datasources/settlement_remote_datasource.dart';
import '../../data/repositories/settlement_repository_impl.dart';
import '../../domain/entities/settlement_entity.dart';
import '../../domain/repositories/settlement_repository.dart';

final settlementDataSourceProvider =
    Provider<SettlementRemoteDataSource>((ref) {
  final expenseDataSource = ref.watch(expenseDataSourceProvider);

  return SettlementRemoteDataSource(
    expenseDataSource: expenseDataSource,
  );
});

final settlementRepositoryProvider = Provider<SettlementRepository>((ref) {
  final dataSource = ref.watch(settlementDataSourceProvider);
  return SettlementRepositoryImpl(dataSource);
});

final tripSettlementsProvider =
    StreamProvider.family<List<SettlementEntity>, String>(
  (ref, tripId) {
    final repository = ref.watch(settlementRepositoryProvider);
    return repository.getTripSettlements(tripId);
  },
);

final settlementControllerProvider =
    StateNotifierProvider<SettlementController, SettlementState>((ref) {
  final repository = ref.watch(settlementRepositoryProvider);
  return SettlementController(repository);
});

class SettlementState {
  final bool isLoading;
  final String? error;

  SettlementState({
    this.isLoading = false,
    this.error,
  });

  SettlementState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return SettlementState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SettlementController extends StateNotifier<SettlementState> {
  final SettlementRepository _repository;

  SettlementController(this._repository) : super(SettlementState());

  Future<bool> createSettlement({
    required String tripId,
    required String fromUserId,
    required String toUserId,
    required double amount,
    required String currency,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      await _repository.createSettlement(
        tripId: tripId,
        fromUserId: fromUserId,
        toUserId: toUserId,
        amount: amount,
        currency: currency,
      );

      state = SettlementState();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> markAsPaid(String settlementId) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      await _repository.markSettlementAsPaid(settlementId);
      state = SettlementState();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> markAsPending(String settlementId) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      await _repository.markSettlementAsPending(settlementId);
      state = SettlementState();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }
}
