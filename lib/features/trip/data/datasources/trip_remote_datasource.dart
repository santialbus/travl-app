import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/trip_model.dart';
import '../models/day_model.dart';
import '../models/member_model.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/utils/invite_code_generator.dart';
import '../../../../core/utils/date_utils.dart';

class TripRemoteDataSource {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  TripRemoteDataSource({
    FirebaseFirestore? firestore,
    Uuid? uuid,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = uuid ?? const Uuid();

  // Create trip
  Future<TripModel> createTrip({
    required String name,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required String ownerId,
  }) async {
    try {
      final tripId = _uuid.v4();
      final inviteCode = InviteCodeGenerator.generate();

      final trip = TripModel(
        id: tripId,
        name: name,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        ownerId: ownerId,
        members: [MemberModel.host(ownerId)],
        inviteCode: inviteCode,
        createdAt: DateTime.now(),
      );

      // Save trip to Firestore
      await _firestore
          .collection(FirebaseConstants.tripsCollection)
          .doc(tripId)
          .set(trip.toFirestore());

      // Generate days
      await _generateDaysForTrip(trip);

      // Update user's tripsOwned
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(ownerId)
          .update({
        FirebaseConstants.userTripsOwnedField: FieldValue.arrayUnion([tripId]),
      });

      return trip;
    } catch (e) {
      throw Exception('Failed to create trip: $e');
    }
  }

  // Generate days for trip
  Future<void> _generateDaysForTrip(TripModel trip) async {
    final days = AppDateUtils.generateTripDays(trip.startDate, trip.endDate);

    final batch = _firestore.batch();

    for (int i = 0; i < days.length; i++) {
      final dayId = _uuid.v4();
      final day = DayModel(
        id: dayId,
        tripId: trip.id,
        date: days[i],
        title: AppDateUtils.getDayTitle(i + 1),
        dayNumber: i + 1,
      );

      final dayRef = _firestore
          .collection(FirebaseConstants.daysCollection)
          .doc(dayId);

      batch.set(dayRef, day.toFirestore());
    }

    await batch.commit();
  }

  // Get user trips
  Stream<List<TripModel>> getUserTrips(String userId) {
    // Primero obtenemos los IDs de trips del usuario
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .asyncMap((userDoc) async {
      if (!userDoc.exists) return <TripModel>[];

      final userData = userDoc.data()!;
      final tripsOwned = List<String>.from(
        userData[FirebaseConstants.userTripsOwnedField] ?? [],
      );
      final tripsJoined = List<String>.from(
        userData[FirebaseConstants.userTripsJoinedField] ?? [],
      );

      // Combinar ambas listas y eliminar duplicados
      final allTripIds = {...tripsOwned, ...tripsJoined}.toList();

      if (allTripIds.isEmpty) return <TripModel>[];

      // Obtener todos los trips
      // Firestore tiene límite de 10 items en 'whereIn', así que dividimos si es necesario
      final trips = <TripModel>[];

      // Procesar en chunks de 10
      for (int i = 0; i < allTripIds.length; i += 10) {
        final chunk = allTripIds.skip(i).take(10).toList();

        final snapshot = await _firestore
            .collection(FirebaseConstants.tripsCollection)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        trips.addAll(
          snapshot.docs.map((doc) => TripModel.fromFirestore(doc)),
        );
      }

      // Ordenar por fecha de creación (más recientes primero)
      trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return trips;
    });
  }

  // Get single trip
  Future<TripModel> getTrip(String tripId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.tripsCollection)
          .doc(tripId)
          .get();

      if (!doc.exists) {
        throw Exception('Trip not found');
      }

      return TripModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get trip: $e');
    }
  }

  // Get trip stream
  Stream<TripModel> getTripStream(String tripId) {
    return _firestore
        .collection(FirebaseConstants.tripsCollection)
        .doc(tripId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        throw Exception('Trip not found');
      }
      return TripModel.fromFirestore(doc);
    });
  }

  // Join trip by invite code
  Future<TripModel> joinTripByCode(String inviteCode, String userId) async {
    try {
      // Find trip with invite code
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.tripsCollection)
          .where(FirebaseConstants.tripInviteCodeField, isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Invalid invite code');
      }

      final tripDoc = querySnapshot.docs.first;
      final trip = TripModel.fromFirestore(tripDoc);

      // Check if already a member
      if (trip.isMember(userId)) {
        return trip;
      }

      // Add user as member
      final newMember = MemberModel.member(userId);

      await _firestore
          .collection(FirebaseConstants.tripsCollection)
          .doc(trip.id)
          .update({
        FirebaseConstants.tripMembersField: FieldValue.arrayUnion([
          newMember.toMap(),
        ]),
      });

      // Update user's tripsJoined
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .update({
        FirebaseConstants.userTripsJoinedField: FieldValue.arrayUnion([trip.id]),
      });

      return trip.copyWith(
        members: [...trip.members, newMember],
      );
    } catch (e) {
      throw Exception('Failed to join trip: $e');
    }
  }

  // Get trip days
  Stream<List<DayModel>> getTripDays(String tripId) {
    return _firestore
        .collection(FirebaseConstants.daysCollection)
        .where('tripId', isEqualTo: tripId)
        .orderBy('dayNumber')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DayModel.fromFirestore(doc))
          .toList();
    });
  }

  // Update trip
  Future<void> updateTrip(TripModel trip) async {
    try {
      await _firestore
          .collection(FirebaseConstants.tripsCollection)
          .doc(trip.id)
          .update(trip.toFirestore());
    } catch (e) {
      throw Exception('Failed to update trip: $e');
    }
  }

  // Delete trip
  Future<void> deleteTrip(String tripId) async {
    try {
      final batch = _firestore.batch();

      // Delete trip
      batch.delete(_firestore
          .collection(FirebaseConstants.tripsCollection)
          .doc(tripId));

      // Delete days
      final daysSnapshot = await _firestore
          .collection(FirebaseConstants.daysCollection)
          .where('tripId', isEqualTo: tripId)
          .get();

      for (var doc in daysSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete trip: $e');
    }
  }
}