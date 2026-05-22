import '../repositories/trip_repository.dart';

class JoinTrip {
  final TripRepository repository;
  JoinTrip(this.repository);

  Future<void> call(String inviteCode) async {}
}
