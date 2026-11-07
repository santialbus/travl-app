import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travl/core/constants/firebase_constants.dart';

class NotificationRemoteDataSource {
  final FirebaseFirestore _firestore;

  NotificationRemoteDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  DateTime? _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  bool _isAfter(dynamic value, DateTime date) {
    final parsedDate = _readDate(value);
    return parsedDate != null && parsedDate.isAfter(date);
  }

  // ---------------------------------------------------------------------------
  // CONSULTAS HISTÓRICAS
  // ---------------------------------------------------------------------------

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getExpensesSince(
    String tripId,
    DateTime since,
    DateTime until,
  ) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.expensesCollection)
        .where('tripId', isEqualTo: tripId)
        .where(
          'createdAt',
          isGreaterThan: Timestamp.fromDate(since),
        )
        .where(
          'createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(until),
        )
        .get(const GetOptions(source: Source.server));

    return snapshot.docs
        .where((document) => document.data()['isSettlement'] != true)
        .toList();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getActivitiesSince(
    String tripId,
    DateTime since,
    DateTime until,
  ) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.activitiesCollection)
        .where('tripId', isEqualTo: tripId)
        .where(
          'createdAt',
          isGreaterThan: Timestamp.fromDate(since),
        )
        .where(
          'createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(until),
        )
        .get(const GetOptions(source: Source.server));

    return snapshot.docs;
  }

  Future<List<Map<String, dynamic>>> getMembersSince(
    String tripId,
    DateTime since,
    DateTime until,
  ) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.tripsCollection)
        .doc(tripId)
        .get(const GetOptions(source: Source.server));

    if (!snapshot.exists) return [];

    final data = snapshot.data();
    if (data == null) return [];

    final rawMembers = data['members'] as List<dynamic>? ?? [];

    return rawMembers
        .whereType<Map>()
        .map((member) => Map<String, dynamic>.from(member))
        .where((member) {
      final joinedAt = _readDate(member['joinedAt']);

      return joinedAt != null &&
          joinedAt.isAfter(since) &&
          !joinedAt.isAfter(until);
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // LISTENERS EN TIEMPO REAL
  // ---------------------------------------------------------------------------

  /// Escucha nuevos gastos.
  ///
  /// En la primera fotografía solo emite documentos posteriores a [after].
  /// Así no perdemos eventos que se produzcan durante el arranque.
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchNewExpenses(
    String tripId, {
    DateTime? after,
  }) {
    late final StreamController<DocumentSnapshot<Map<String, dynamic>>>
        controller;

    StreamSubscription? subscription;
    final processedIds = <String>{};
    bool initialized = false;

    controller = StreamController<DocumentSnapshot<Map<String, dynamic>>>(
      onListen: () {
        subscription = _firestore
            .collection(FirebaseConstants.expensesCollection)
            .where('tripId', isEqualTo: tripId)
            .snapshots(includeMetadataChanges: true)
            .listen(
          (snapshot) {
            if (snapshot.metadata.isFromCache) return;

            if (!initialized) {
              for (final document in snapshot.docs) {
                processedIds.add(document.id);

                if (document.metadata.hasPendingWrites) continue;

                final data = document.data();

                if (data['isSettlement'] == true) continue;

                if (after != null && _isAfter(data['createdAt'], after)) {
                  controller.add(document);
                }
              }

              initialized = true;
              return;
            }

            for (final change in snapshot.docChanges) {
              if (change.type != DocumentChangeType.added) continue;

              final document = change.doc;

              if (document.metadata.hasPendingWrites) continue;
              if (!processedIds.add(document.id)) continue;

              if (document.data()?['isSettlement'] == true) continue;

              controller.add(document);
            }
          },
          onError: (error, stackTrace) {
            controller.addError(error, stackTrace);
          },
        );
      },
      onCancel: () async {
        await subscription?.cancel();
      },
    );

    return controller.stream;
  }

  /// Escucha nuevas actividades.
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchNewActivities(
    String tripId, {
    DateTime? after,
  }) {
    late final StreamController<DocumentSnapshot<Map<String, dynamic>>>
        controller;

    StreamSubscription? subscription;
    final processedIds = <String>{};
    bool initialized = false;

    controller = StreamController<DocumentSnapshot<Map<String, dynamic>>>(
      onListen: () {
        subscription = _firestore
            .collection(FirebaseConstants.activitiesCollection)
            .where('tripId', isEqualTo: tripId)
            .snapshots(includeMetadataChanges: true)
            .listen(
          (snapshot) {
            if (snapshot.metadata.isFromCache) return;

            if (!initialized) {
              for (final document in snapshot.docs) {
                processedIds.add(document.id);

                if (document.metadata.hasPendingWrites) continue;

                final data = document.data();

                if (after != null && _isAfter(data['createdAt'], after)) {
                  controller.add(document);
                }
              }

              initialized = true;
              return;
            }

            for (final change in snapshot.docChanges) {
              if (change.type != DocumentChangeType.added) continue;

              final document = change.doc;

              if (document.metadata.hasPendingWrites) continue;
              if (!processedIds.add(document.id)) continue;

              controller.add(document);
            }
          },
          onError: controller.addError,
        );
      },
      onCancel: () async {
        await subscription?.cancel();
      },
    );

    return controller.stream;
  }

  /// Escucha incorporaciones de miembros.
  ///
  /// En la primera fotografía detecta miembros cuyo joinedAt sea posterior
  /// a [after]. Después compara las incorporaciones nuevas.
  Stream<List<Map<String, dynamic>>> watchNewMembers(
    String tripId, {
    DateTime? after,
  }) {
    late final StreamController<List<Map<String, dynamic>>> controller;

    StreamSubscription? subscription;
    Set<String>? previousMemberIds;

    controller = StreamController<List<Map<String, dynamic>>>(
      onListen: () {
        subscription = _firestore
            .collection(FirebaseConstants.tripsCollection)
            .doc(tripId)
            .snapshots(includeMetadataChanges: true)
            .listen(
          (snapshot) {
            if (snapshot.metadata.isFromCache) return;
            if (!snapshot.exists) return;
            if (snapshot.metadata.hasPendingWrites) return;

            final data = snapshot.data();
            if (data == null) return;

            final rawMembers = data['members'] as List<dynamic>? ?? [];

            final members = rawMembers
                .whereType<Map>()
                .map((member) => Map<String, dynamic>.from(member))
                .toList();

            final currentMemberIds = members
                .map((member) => member['userId'] as String?)
                .whereType<String>()
                .toSet();

            if (previousMemberIds == null) {
              previousMemberIds = currentMemberIds;

              if (after != null) {
                final recentlyJoined = members.where((member) {
                  return _isAfter(member['joinedAt'], after);
                }).toList();

                if (recentlyJoined.isNotEmpty) {
                  controller.add(recentlyJoined);
                }
              }

              return;
            }

            final addedMemberIds =
                currentMemberIds.difference(previousMemberIds!);

            previousMemberIds = currentMemberIds;

            if (addedMemberIds.isEmpty) return;

            controller.add(
              members.where((member) {
                return addedMemberIds.contains(member['userId']);
              }).toList(),
            );
          },
          onError: controller.addError,
        );
      },
      onCancel: () async {
        await subscription?.cancel();
      },
    );

    return controller.stream;
  }
}
