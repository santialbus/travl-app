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
    super.flightNumber,
    super.trainNumber,
    super.transportCompany,
    super.bookingReference,
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
      // ✅ Nuevos campos
      flightNumber: data['flightNumber'] as String?,
      trainNumber: data['trainNumber'] as String?,
      transportCompany: data['transportCompany'] as String?,
      bookingReference: data['bookingReference'] as String?,
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
      // ✅ Nuevos campos
      'flightNumber': flightNumber,
      'trainNumber': trainNumber,
      'transportCompany': transportCompany,
      'bookingReference': bookingReference,
    };
  }

  ActivityModel copyWith({
    // ... campos existentes ...
    String? flightNumber,
    String? trainNumber,
    String? transportCompany,
    String? bookingReference,
  }) {
    return ActivityModel(
      id: id ?? id,
      tripId: tripId ?? tripId,
      dayId: dayId ?? dayId,
      title: title ?? title,
      type: type ?? type,
      description: description ?? description,
      time: time ?? time,
      locationName: locationName ?? locationName,
      latitude: latitude ?? latitude,
      longitude: longitude ?? longitude,
      mapsUrl: mapsUrl ?? mapsUrl,
      isCompleted: isCompleted ?? isCompleted,
      orderIndex: orderIndex ?? orderIndex,
      createdBy: createdBy ?? createdBy,
      createdAt: createdAt ?? createdAt,
      flightNumber: flightNumber ?? this.flightNumber,
      trainNumber: trainNumber ?? this.trainNumber,
      transportCompany: transportCompany ?? this.transportCompany,
      bookingReference: bookingReference ?? this.bookingReference,
    );
  }
}
