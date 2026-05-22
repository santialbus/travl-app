import '../repositories/trip_repository.dart';
import '../entities/checklist_item_entity.dart';

class UpdateChecklist {
  final TripRepository repository;
  UpdateChecklist(this.repository);

  Future<void> call(String tripId, ChecklistItemEntity item) async {}
}
