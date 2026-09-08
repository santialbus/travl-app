import '../../domain/entities/checklist_item_entity.dart';
import '../../domain/repositories/checklist_repository.dart';
import '../datasources/checklist_remote_datasource.dart';

class ChecklistRepositoryImpl implements ChecklistRepository {
  final ChecklistRemoteDataSource _dataSource;

  ChecklistRepositoryImpl(this._dataSource);

  @override
  Stream<List<ChecklistItemEntity>> getTripChecklist(String tripId) {
    return _dataSource.getTripChecklist(tripId);
  }

  @override
  Future<ChecklistItemEntity> createItem({
    required String tripId,
    required String title,
    required ChecklistType type,
    String? assignedTo,
  }) {
    return _dataSource.createItem(
      tripId: tripId,
      title: title,
      type: type,
      assignedTo: assignedTo,
    );
  }

  @override
  Future<void> updateItem({
    required String itemId,
    required String title,
    required ChecklistType type,
    String? assignedTo,
  }) {
    return _dataSource.updateItem(
      itemId: itemId,
      title: title,
      type: type,
      assignedTo: assignedTo,
    );
  }

  @override
  Future<void> toggleItem(String itemId, bool isDone) {
    return _dataSource.toggleItem(itemId, isDone);
  }

  @override
  Future<void> deleteItem(String itemId) {
    return _dataSource.deleteItem(itemId);
  }
}
