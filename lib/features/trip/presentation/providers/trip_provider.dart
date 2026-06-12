import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/trip_remote_datasource.dart';
import '../../data/repositories/trip_repository_impl.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/repositories/trip_repository.dart';

// Data Source Provider
final tripDataSourceProvider = Provider<TripRemoteDataSource>((ref) {
  return TripRemoteDataSource();
});

// Repository Provider
final tripRepositoryProvider = Provider<TripRepository>((ref) {
  final dataSource = ref.watch(tripDataSourceProvider);
  return TripRepositoryImpl(dataSource);
});

// User Trips Stream Provider
final userTripsProvider = StreamProvider.family<List<TripEntity>, String>((ref, userId) {
  final repository = ref.watch(tripRepositoryProvider);
  return repository.getUserTrips(userId);
});

// Single Trip Stream Provider
final tripStreamProvider = StreamProvider.family<TripEntity, String>((ref, tripId) {
  final repository = ref.watch(tripRepositoryProvider);
  return repository.getTripStream(tripId);
});

// Trip Controller
final tripControllerProvider = StateNotifierProvider<TripController, TripState>((ref) {
  final repository = ref.watch(tripRepositoryProvider);
  return TripController(repository);
});

// Trip State
class TripState {
  final bool isLoading;
  final String? error;
  final TripEntity? currentTrip;

  TripState({
    this.isLoading = false,
    this.error,
    this.currentTrip,
  });

  TripState copyWith({
    bool? isLoading,
    String? error,
    TripEntity? currentTrip,
  }) {
    return TripState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentTrip: currentTrip ?? this.currentTrip,
    );
  }
}

// Trip Controller
class TripController extends StateNotifier<TripState> {
  final TripRepository _repository;

  TripController(this._repository) : super(TripState());

  Future<TripEntity?> createTrip({
    required String name,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required String ownerId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final trip = await _repository.createTrip(
        name: name,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        ownerId: ownerId,
      );
      state = state.copyWith(isLoading: false, currentTrip: trip);
      return trip;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<TripEntity?> joinTripByCode(String inviteCode, String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final trip = await _repository.joinTripByCode(inviteCode, userId);
      state = state.copyWith(isLoading: false, currentTrip: trip);
      return trip;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<void> deleteTrip(String tripId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteTrip(tripId);
      state = TripState();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> leaveTrip(String tripId, String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.leaveTrip(tripId, userId);
      state = TripState();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateTrip({
    required String tripId,
    required String name,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateTrip(
        tripId: tripId,
        name: name,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
      );
      state = TripState();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> updateMemberRole({
    required String tripId,
    required String userId,
    required String newRole,
  }) async {
    try {
      await (_repository as TripRepositoryImpl).updateMemberRole(
        tripId: tripId,
        userId: userId,
        newRole: newRole,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}