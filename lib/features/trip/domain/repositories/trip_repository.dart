import '../entities/trip_entity.dart';
import '../entities/day_entity.dart';

abstract class TripRepository {
  // Create trip
  Future<TripEntity> createTrip({
    required String name,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required String ownerId,
  });

  // Get trips for user
  Stream<List<TripEntity>> getUserTrips(String userId);

  // Get single trip
  Future<TripEntity> getTrip(String tripId);

  // Get trip stream
  Stream<TripEntity> getTripStream(String tripId);

  // Join trip by invite code
  Future<TripEntity> joinTripByCode(String inviteCode, String userId);

  // Get days for trip
  Stream<List<DayEntity>> getTripDays(String tripId);

  Future<void> updateTrip({
    required String tripId,
    required String name,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
  });

  // Delete trip
  Future<void> deleteTrip(String tripId);
  Future<void> leaveTrip(String tripId, String userId);

  Future<void> updateMemberRole({
    required String tripId,
    required String userId,
    required String newRole,
  });
}