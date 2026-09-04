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
    // ✅ Nuevos campos
    String? flightNumber,
    String? trainNumber,
    String? transportCompany,
    String? bookingReference,
  }) async {
    try {
      final activityId = _uuid.v4();

      final existingActivities = await _firestore
          .collection(FirebaseConstants.activitiesCollection)
          .where('dayId', isEqualTo: dayId)
          .get();

      final orderIndex = existingActivities.docs.length;

      String? mapsUrl;
      if (latitude != null && longitude != null) {
        mapsUrl =
            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      } else if (locationName != null && locationName.isNotEmpty) {
        mapsUrl =
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(locationName)}';
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
        flightNumber: flightNumber,
        trainNumber: trainNumber,
        transportCompany: transportCompany,
        bookingReference: bookingReference,
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
    // ✅ Nuevos campos
    String? flightNumber,
    String? trainNumber,
    String? transportCompany,
    String? bookingReference,
  }) async {
    try {
      String? mapsUrl;
      if (locationName != null && locationName.isNotEmpty) {
        mapsUrl =
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(locationName)}';
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
        'mapsUrl': mapsUrl,
        'flightNumber': flightNumber,
        'trainNumber': trainNumber,
        'transportCompany': transportCompany,
        'bookingReference': bookingReference,
      });
    } catch (e) {
      throw Exception('Failed to update activity: $e');
    }
  }

  // Toggle activity completion
  Future<void> toggleActivityCompletion(
      String activityId, bool isCompleted) async {
    try {
      await _firestore
          .collection(FirebaseConstants.activitiesCollection)
          .doc(activityId)
          .update({'isCompleted': isCompleted});
    } catch (e) {
      throw Exception('Failed to toggle activity: $e');
    }
  }

  Future<void> deleteActivity(String activityId) async {
    try {
      final activityRef = _firestore
          .collection(FirebaseConstants.activitiesCollection)
          .doc(activityId);

      final activityDoc = await activityRef.get();

      if (!activityDoc.exists) {
        throw Exception('Activity not found');
      }

      final activity = ActivityModel.fromFirestore(activityDoc);

      final remainingActivities = await _firestore
          .collection(FirebaseConstants.activitiesCollection)
          .where('dayId', isEqualTo: activity.dayId)
          .orderBy('orderIndex')
          .get();

      final remainingDocs = remainingActivities.docs
          .where((doc) => doc.id != activityId)
          .toList();

      final batch = _firestore.batch();

      batch.delete(activityRef);

      for (int i = 0; i < remainingDocs.length; i++) {
        batch.update(remainingDocs[i].reference, {'orderIndex': i});
      }

      await batch.commit();
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

  Future<void> moveActivityToDay(
    String activityId,
    String newDayId,
    int newOrderIndex,
  ) async {
    try {
      final activityRef = _firestore
          .collection(FirebaseConstants.activitiesCollection)
          .doc(activityId);

      final activityDoc = await activityRef.get();

      if (!activityDoc.exists) {
        throw Exception('Activity not found');
      }

      final activity = ActivityModel.fromFirestore(activityDoc);
      final oldDayId = activity.dayId;

      if (oldDayId == newDayId) return;

      final oldDayActivities = await _firestore
          .collection(FirebaseConstants.activitiesCollection)
          .where('dayId', isEqualTo: oldDayId)
          .orderBy('orderIndex')
          .get();

      final newDayActivities = await _firestore
          .collection(FirebaseConstants.activitiesCollection)
          .where('dayId', isEqualTo: newDayId)
          .orderBy('orderIndex')
          .get();

      final batch = _firestore.batch();

      final remainingOldActivities =
          oldDayActivities.docs.where((doc) => doc.id != activityId).toList();

      for (int i = 0; i < remainingOldActivities.length; i++) {
        batch.update(
          remainingOldActivities[i].reference,
          {'orderIndex': i},
        );
      }

      final targetActivities =
          List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
        newDayActivities.docs,
      );

      final insertIndex = newOrderIndex.clamp(0, targetActivities.length);

      for (int i = 0; i < targetActivities.length; i++) {
        final orderIndex = i >= insertIndex ? i + 1 : i;

        batch.update(
          targetActivities[i].reference,
          {'orderIndex': orderIndex},
        );
      }

      batch.update(activityRef, {
        'dayId': newDayId,
        'orderIndex': insertIndex,
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to move activity to day: $e');
    }
  }
}
