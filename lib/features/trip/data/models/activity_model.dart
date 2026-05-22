import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/activity_entity.dart';

class ActivityModel extends ActivityEntity {
  const ActivityModel({
    required super.id,
    required super.tripId,
    required super.dayId,
    required super.title,
    required super.type,
    super.description,
    super.time,
    super.locationName,
    super.latitude,
    super.longitude,
    super.mapsUrl,
    required super.isCompleted,
    required super.orderIndex,
    required super.createdBy,
    required super.createdAt,
  });

  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ActivityModel(
      id: doc.id,
      tripId: data['tripId'] as String,
      dayId: data['dayId'] as String,
      title: data['title'] as String,
      type: ActivityType.fromString(data['type'] as String),
      description: data['description'] as String?,
      time: data['time'] != null ? (data['time'] as Timestamp).toDate() : null,
      locationName: data['locationName'] as String?,
      latitude: data['latitude'] as double?,
      longitude: data['longitude'] as double?,
      mapsUrl: data['mapsUrl'] as String?,
      isCompleted: data['isCompleted'] as bool? ?? false,
      orderIndex: data['orderIndex'] as int,
      createdBy: data['createdBy'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'tripId': tripId,
      'dayId': dayId,
      'title': title,
      'type': type.value,
      'description': description,
      'time': time != null ? Timestamp.fromDate(time!) : null,
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'mapsUrl': mapsUrl,
      'isCompleted': isCompleted,
      'orderIndex': orderIndex,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ActivityModel copyWith({
    String? id,
    String? tripId,
    String? dayId,
    String? title,
    ActivityType? type,
    String? description,
    DateTime? time,
    String? locationName,
    double? latitude,
    double? longitude,
    String? mapsUrl,
    bool? isCompleted,
    int? orderIndex,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      dayId: dayId ?? this.dayId,
      title: title ?? this.title,
      type: type ?? this.type,
      description: description ?? this.description,
      time: time ?? this.time,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      mapsUrl: mapsUrl ?? this.mapsUrl,
      isCompleted: isCompleted ?? this.isCompleted,
      orderIndex: orderIndex ?? this.orderIndex,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}