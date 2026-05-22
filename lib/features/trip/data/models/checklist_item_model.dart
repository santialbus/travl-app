import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/checklist_item_entity.dart';

class ChecklistItemModel extends ChecklistItemEntity {
  const ChecklistItemModel({
    required super.id,
    required super.tripId,
    required super.title,
    required super.isDone,
    required super.type,
    required super.createdAt,
  });

  factory ChecklistItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChecklistItemModel(
      id: doc.id,
      tripId: data['tripId'] as String,
      title: data['title'] as String,
      isDone: data['isDone'] as bool? ?? false,
      type: ChecklistType.fromString(data['type'] as String),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'tripId': tripId,
      'title': title,
      'isDone': isDone,
      'type': type.value,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ChecklistItemModel copyWith({
    String? id,
    String? tripId,
    String? title,
    bool? isDone,
    ChecklistType? type,
    DateTime? createdAt,
  }) {
    return ChecklistItemModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}