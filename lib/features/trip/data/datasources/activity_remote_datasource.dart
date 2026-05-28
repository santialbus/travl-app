import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/activity_model.dart';
import '../../domain/entities/activity_entity.dart';
import '../../../../core/constants/firebase_constants.dart';

class ActivityRemoteDataSource {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  ActivityRemoteDataSource({
    FirebaseFirestore? firestore,
    Uuid? uuid,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = uuid ?? const Uuid();

  // Get activities for a day
  Stream<List<ActivityModel>> getDayActivities(String dayId) {
    return _firestore
        .collection(FirebaseConstants.activitiesCollection)
        .where('dayId', isEqualTo: dayId)
        .orderBy('orderIndex')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ActivityModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get all activities for a trip
  Stream<List<ActivityModel>> getTripActivities(String tripId) {
    return _firestore
        .collection(FirebaseConstants.activitiesCollection)
        .where('tripId', isEqualTo: tripId)
        .orderBy('orderIndex')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ActivityModel.fromFirestore(doc))
          .toList();
    });
  }

  // Create activity
  Future<ActivityModel> createActivity({
    required String tripId,
    required String dayId,
    required String title,
    required ActivityType type,
    String? description,
    DateTime? time,
    String? locationName,
    double? latitude,
    double? longitude,
    required String createdBy,
  }) async {
    try {
      final activityId = _uuid.v4();

      // Get current count of activities for this day to set orderIndex
      final existingActivities = await _firestore
          .collection(FirebaseConstants.activitiesCollection)
          .where('dayId', isEqualTo: dayId)
          .get();

      final orderIndex = existingActivities.docs.length;

      // Generate maps URL if location is provided
      String? mapsUrl;
      if (latitude != null && longitude != null) {
        mapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      } else if (locationName != null && locationName.isNotEmpty) {
        // ✅ Usar el nombre de la ubicación directamente
        mapsUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(locationName)}';
      }

      final activity = ActivityModel(
        id: activityId,
        tripId: tripId,
        dayId: dayId,
        title: title,
        type: type,
        description: description,
        time: time,
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
        mapsUrl: mapsUrl,
        isCompleted: false,
        orderIndex: orderIndex,
        createdBy: createdBy,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(FirebaseConstants.activitiesCollection)
          .doc(activityId)
          .set(activity.toFirestore());

      return activity;
    } catch (e) {
      throw Exception('Failed to create activity: $e');
    }
  }

  Future<void> updateActivity({
    required String activityId,
    required String title,
    required ActivityType type,
    String? description,
    DateTime? time,
    String? locationName,
  }) async {
    try {
      String? mapsUrl;
      if (locationName != null && locationName.isNotEmpty) {
        mapsUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(locationName)}';
      }

      await _firestore
          .collection(FirebaseConstants.activitiesCollection)
          .doc(activityId)
          .update({
        'title': title,
        'type': type.value,
        'description': description,
        'time': time != null ? Timestamp.fromDate(time) : null,
        'locationName': locationName,
        'mapsUrl': mapsUrl, // ✅ Actualiza también el mapsUrl
      });
    } catch (e) {
      throw Exception('Failed to update activity: $e');
    }
  }

  // Toggle activity completion
  Future<void> toggleActivityCompletion(String activityId, bool isCompleted) async {
    try {
      await _firestore
          .collection(FirebaseConstants.activitiesCollection)
          .doc(activityId)
          .update({'isCompleted': isCompleted});
    } catch (e) {
      throw Exception('Failed to toggle activity: $e');
    }
  }

  // Delete activity
  Future<void> deleteActivity(String activityId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.activitiesCollection)
          .doc(activityId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete activity: $e');
    }
  }

  // Reorder activities
  Future<void> reorderActivities(List<ActivityModel> activities) async {
    try {
      final batch = _firestore.batch();

      for (int i = 0; i < activities.length; i++) {
        final activityRef = _firestore
            .collection(FirebaseConstants.activitiesCollection)
            .doc(activities[i].id);

        batch.update(activityRef, {'orderIndex': i});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to reorder activities: $e');
    }
  }

  // Reordenar actividades dentro de un día
  Future<void> reorderActivitiesInDay(
      String dayId,
      List<String> activityIds,
      ) async {
    try {
      final batch = _firestore.batch();

      for (int i = 0; i < activityIds.length; i++) {
        final ref = _firestore
            .collection(FirebaseConstants.activitiesCollection)
            .doc(activityIds[i]);
        batch.update(ref, {'orderIndex': i});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to reorder activities: $e');
    }
  }

// Mover actividad a otro día
  Future<void> moveActivityToDay(
      String activityId,
      String newDayId,
      int newOrderIndex,
      ) async {
    try {
      await _firestore
          .collection(FirebaseConstants.activitiesCollection)
          .doc(activityId)
          .update({
        'dayId': newDayId,
        'orderIndex': newOrderIndex,
      });
    } catch (e) {
      throw Exception('Failed to move activity: $e');
    }
  }
}