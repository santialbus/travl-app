import '../../domain/entities/trip_entity.dart';
import '../../domain/entities/day_entity.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_datasource.dart';

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource _remoteDataSource;

  TripRepositoryImpl(this._remoteDataSource);

  @override
  Future<TripEntity> createTrip({
    required String name,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required String ownerId,
  }) async {
    return await _remoteDataSource.createTrip(
      name: name,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      ownerId: ownerId,
    );
  }

  @override
  Stream<List<TripEntity>> getUserTrips(String userId) {
    return _remoteDataSource.getUserTrips(userId);
  }

  @override
  Future<TripEntity> getTrip(String tripId) async {
    return await _remoteDataSource.getTrip(tripId);
  }

  @override
  Stream<TripEntity> getTripStream(String tripId) {
    return _remoteDataSource.getTripStream(tripId);
  }

  @override
  Future<TripEntity> joinTripByCode(String inviteCode, String userId) async {
    return await _remoteDataSource.joinTripByCode(inviteCode, userId);
  }

  @override
  Stream<List<DayEntity>> getTripDays(String tripId) {
    return _remoteDataSource.getTripDays(tripId);
  }

  @override
  Future<void> updateTrip({
    required String tripId,
    required String name,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await _remoteDataSource.updateTrip(
      tripId: tripId,
      name: name,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    await _remoteDataSource.deleteTrip(tripId);
  }

  Future<void> leaveTrip(String tripId, String userId) async {
    await _remoteDataSource.leaveTrip(tripId, userId);
  }

  @override
  Future<void> updateMemberRole({
    required String tripId,
    required String userId,
    required String newRole,
  }) async {
    await _remoteDataSource.updateMemberRole(
      tripId: tripId,
      userId: userId,
      newRole: newRole,
    );
  }
}