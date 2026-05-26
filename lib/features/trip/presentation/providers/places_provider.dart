import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/place_remote_datasource.dart';
import '../../domain/entities/place_entity.dart';

final placeDataSourceProvider = Provider<PlaceRemoteDataSource>((ref) {
  return PlaceRemoteDataSource();
});

final tripPlacesProvider =
StreamProvider.family<List<PlaceEntity>, String>((ref, tripId) {
  final dataSource = ref.watch(placeDataSourceProvider);
  return dataSource.getTripPlaces(tripId);
});

final placeControllerProvider =
StateNotifierProvider<PlaceController, PlaceState>((ref) {
  final dataSource = ref.watch(placeDataSourceProvider);
  return PlaceController(dataSource);
});

class PlaceState {
  final bool isLoading;
  final String? error;

  PlaceState({this.isLoading = false, this.error});

  PlaceState copyWith({bool? isLoading, String? error}) {
    return PlaceState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PlaceController extends StateNotifier<PlaceState> {
  final PlaceRemoteDataSource _dataSource;

  PlaceController(this._dataSource) : super(PlaceState());

  Future<bool> createPlace({
    required String tripId,
    required String name,
    required PlaceCategory category,
    String? address,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dataSource.createPlace(
        tripId: tripId,
        name: name,
        category: category,
        address: address,
        notes: notes,
      );
      state = PlaceState();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> toggleStatus(String placeId, PlaceStatus currentStatus) async {
    try {
      final newStatus = currentStatus == PlaceStatus.pending
          ? PlaceStatus.visited
          : PlaceStatus.pending;
      await _dataSource.toggleStatus(placeId, newStatus);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deletePlace(String placeId) async {
    try {
      await _dataSource.deletePlace(placeId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}