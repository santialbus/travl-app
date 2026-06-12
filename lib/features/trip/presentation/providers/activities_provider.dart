import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/activity_remote_datasource.dart';
import '../../domain/entities/activity_entity.dart';

// Data Source Provider
final activityDataSourceProvider = Provider<ActivityRemoteDataSource>((ref) {
  return ActivityRemoteDataSource();
});

// Day Activities Stream Provider
final dayActivitiesProvider = StreamProvider.family<List<ActivityEntity>, String>((ref, dayId) {
  final dataSource = ref.watch(activityDataSourceProvider);
  return dataSource.getDayActivities(dayId);
});

// Trip Activities Stream Provider
final tripActivitiesProvider = StreamProvider.family<List<ActivityEntity>, String>((ref, tripId) {
  final dataSource = ref.watch(activityDataSourceProvider);
  return dataSource.getTripActivities(tripId);
});

// Activity Controller
final activityControllerProvider = StateNotifierProvider<ActivityController, ActivityState>((ref) {
  final dataSource = ref.watch(activityDataSourceProvider);
  return ActivityController(dataSource);
});

// Activity State
class ActivityState {
  final bool isLoading;
  final String? error;

  ActivityState({
    this.isLoading = false,
    this.error,
  });

  ActivityState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return ActivityState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Activity Controller
class ActivityController extends StateNotifier<ActivityState> {
  final ActivityRemoteDataSource _dataSource;

  ActivityController(this._dataSource) : super(ActivityState());

  Future<bool> createActivity({
    required String tripId,
    required String dayId,
    required String title,
    required ActivityType type,
    String? description,
    DateTime? time,
    String? locationName,
    double? latitude,
    double? longitude,
    required String createdBy,
    // ✅ Nuevos
    String? flightNumber,
    String? trainNumber,
    String? transportCompany,
    String? bookingReference,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dataSource.createActivity(
        tripId: tripId,
        dayId: dayId,
        title: title,
        type: type,
        description: description,
        time: time,
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
        createdBy: createdBy,
        flightNumber: flightNumber,
        trainNumber: trainNumber,
        transportCompany: transportCompany,
        bookingReference: bookingReference,
      );
      state = ActivityState();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateActivity({
    required String activityId,
    required String title,
    required ActivityType type,
    String? description,
    DateTime? time,
    String? locationName,
    String? flightNumber,
    String? trainNumber,
    String? transportCompany,
    String? bookingReference,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dataSource.updateActivity(
        activityId: activityId,
        title: title,
        type: type,
        description: description,
        time: time,
        locationName: locationName,
        flightNumber: flightNumber,
        trainNumber: trainNumber,
        transportCompany: transportCompany,
        bookingReference: bookingReference,
      );
      state = ActivityState();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> toggleCompletion(String activityId, bool isCompleted) async {
    try {
      await _dataSource.toggleActivityCompletion(activityId, isCompleted);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteActivity(String activityId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dataSource.deleteActivity(activityId);
      state = ActivityState();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> reorderActivitiesInDay(
      String dayId,
      List<String> activityIds,
      ) async {
    try {
      await _dataSource.reorderActivitiesInDay(dayId, activityIds);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> moveActivityToDay(
      String activityId,
      String newDayId,
      int newOrderIndex,
      ) async {
    try {
      await _dataSource.moveActivityToDay(activityId, newDayId, newOrderIndex);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}