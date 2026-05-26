import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/place_entity.dart';

class PlaceModel extends PlaceEntity {
  const PlaceModel({
    required super.id,
    required super.tripId,
    required super.name,
    required super.category,
    required super.status,
    super.address,
    super.mapsUrl,
    super.notes,
    required super.createdAt,
  });

  factory PlaceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlaceModel(
      id: doc.id,
      tripId: data['tripId'] as String,
      name: data['name'] as String,
      category: PlaceCategory.fromString(data['category'] as String),
      status: PlaceStatus.fromString(data['status'] as String),
      address: data['address'] as String?,
      mapsUrl: data['mapsUrl'] as String?,
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'tripId': tripId,
      'name': name,
      'category': category.value,
      'status': status.value,
      'address': address,
      'mapsUrl': mapsUrl,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}