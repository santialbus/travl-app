import '../repositories/trip_repository.dart';
import '../entities/trip_entity.dart';

class GetTrip {
  final TripRepository repository;
  GetTrip(this.repository);

  Future<TripEntity> call(String id) => repository.getTrip(id);
}
