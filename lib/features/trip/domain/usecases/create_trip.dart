import '../repositories/trip_repository.dart';
import '../entities/trip_entity.dart';

class CreateTrip {
  final TripRepository repository;
  CreateTrip(this.repository);

  //Future<void> call(TripEntity trip) => repository.createTrip(trip);
}
