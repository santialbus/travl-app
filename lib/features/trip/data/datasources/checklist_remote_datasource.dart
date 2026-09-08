import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/checklist_item_model.dart';
import '../../domain/entities/checklist_item_entity.dart';
import '../../../../core/constants/firebase_constants.dart';

class ChecklistRemoteDataSource {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  ChecklistRemoteDataSource({
    FirebaseFirestore? firestore,
    Uuid? uuid,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = uuid ?? const Uuid();

  Stream<List<ChecklistItemModel>> getTripChecklist(String tripId) {
    return _firestore
        .collection(FirebaseConstants.checklistCollection)
        .where('tripId', isEqualTo: tripId)
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ChecklistItemModel.fromFirestore(doc))
            .toList());
  }

  Future<ChecklistItemModel> createItem({
    required String tripId,
    required String title,
    required ChecklistType type,
    String? assignedTo,
  }) async {
    try {
      final id = _uuid.v4();

      final item = ChecklistItemModel(
        id: id,
        tripId: tripId,
        title: title,
        isDone: false,
        type: type,
        createdAt: DateTime.now(),
        assignedTo: assignedTo,
      );

      await _firestore
          .collection(FirebaseConstants.checklistCollection)
          .doc(id)
          .set(item.toFirestore());

      return item;
    } catch (e) {
      throw Exception('Failed to create checklist item: $e');
    }
  }

  Future<void> updateItem({
    required String itemId,
    required String title,
    required ChecklistType type,
    String? assignedTo,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConstants.checklistCollection)
          .doc(itemId)
          .update({
        'title': title,
        'type': type.value,
        'assignedTo': assignedTo,
      });
    } catch (e) {
      throw Exception('Failed to update checklist item: $e');
    }
  }

  Future<void> toggleItem(String itemId, bool isDone) async {
    try {
      await _firestore
          .collection(FirebaseConstants.checklistCollection)
          .doc(itemId)
          .update({'isDone': isDone});
    } catch (e) {
      throw Exception('Failed to toggle checklist item: $e');
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.checklistCollection)
          .doc(itemId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete checklist item: $e');
    }
  }
}
