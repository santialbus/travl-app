import '../repositories/trip_repository.dart';
import '../entities/activity_entity.dart';

class AddActivity {
  final TripRepository repository;
  AddActivity(this.repository);

  Future<void> call(String tripId, ActivityEntity activity) async {}
}
