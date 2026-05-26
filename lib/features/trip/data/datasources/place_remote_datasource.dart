import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/place_model.dart';
import '../../domain/entities/place_entity.dart';
import '../../../../core/constants/firebase_constants.dart';

class PlaceRemoteDataSource {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  PlaceRemoteDataSource({
    FirebaseFirestore? firestore,
    Uuid? uuid,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = uuid ?? const Uuid();

  Stream<List<PlaceModel>> getTripPlaces(String tripId) {
    return _firestore
        .collection(FirebaseConstants.placesCollection)
        .where('tripId', isEqualTo: tripId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) =>
        snap.docs.map((doc) => PlaceModel.fromFirestore(doc)).toList());
  }

  Future<PlaceModel> createPlace({
    required String tripId,
    required String name,
    required PlaceCategory category,
    String? address,
    String? notes,
  }) async {
    try {
      final id = _uuid.v4();

      // Generar maps URL si hay dirección
      String? mapsUrl;
      if (address != null && address.isNotEmpty) {
        mapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
      } else {
        mapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(name)}';
      }

      final place = PlaceModel(
        id: id,
        tripId: tripId,
        name: name,
        category: category,
        status: PlaceStatus.pending,
        address: address,
        mapsUrl: mapsUrl,
        notes: notes,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(FirebaseConstants.placesCollection)
          .doc(id)
          .set(place.toFirestore());

      return place;
    } catch (e) {
      throw Exception('Failed to create place: $e');
    }
  }

  Future<void> toggleStatus(String placeId, PlaceStatus status) async {
    try {
      await _firestore
          .collection(FirebaseConstants.placesCollection)
          .doc(placeId)
          .update({'status': status.value});
    } catch (e) {
      throw Exception('Failed to toggle place status: $e');
    }
  }

  Future<void> deletePlace(String placeId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.placesCollection)
          .doc(placeId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete place: $e');
    }
  }
}