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
    super.bookingUrl
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
      bookingUrl: data['bookingUrl'] as String?,
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
      'bookingUrl': bookingUrl,
    };
  }

  ActivityModel copyWith({
    // ... campos existentes ...
    String? flightNumber,
    String? trainNumber,
    String? transportCompany,
    String? bookingReference,
    String? bookingUrl,
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
      flightNumber: flightNumber ?? this.flightNumber,
      trainNumber: trainNumber ?? this.trainNumber,
      transportCompany: transportCompany ?? this.transportCompany,
      bookingReference: bookingReference ?? this.bookingReference,
      bookingUrl: bookingUrl ?? this.bookingUrl,
    );
  }
}