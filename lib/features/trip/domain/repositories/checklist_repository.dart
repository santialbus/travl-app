import '../entities/checklist_item_entity.dart';

abstract class ChecklistRepository {
  Stream<List<ChecklistItemEntity>> getTripChecklist(String tripId);

  Future<ChecklistItemEntity> createItem({
    required String tripId,
    required String title,
    required ChecklistType type,
    String? assignedTo,
  });

  Future<void> updateItem({
    required String itemId,
    required String title,
    required ChecklistType type,
    String? assignedTo,
  });

  Future<void> toggleItem(String itemId, bool isDone);

  Future<void> deleteItem(String itemId);
}
