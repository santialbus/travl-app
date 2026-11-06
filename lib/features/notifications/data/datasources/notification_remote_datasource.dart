import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travl/core/constants/firebase_constants.dart';

class NotificationRemoteDataSource {
  final FirebaseFirestore _firestore;

  NotificationRemoteDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Escucha los nuevos gastos de un viaje.
  ///
  /// Devuelve únicamente documentos añadidos después de recibir
  /// la primera fotografía del servidor.
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchNewExpenses(
    String tripId,
  ) {
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
              processedIds.addAll(
                snapshot.docs.map((doc) => doc.id),
              );
              initialized = true;
              return;
            }

            for (final change in snapshot.docChanges) {
              if (change.type != DocumentChangeType.added) {
                continue;
              }

              final document = change.doc;

              if (document.metadata.hasPendingWrites) continue;
              if (!processedIds.add(document.id)) continue;

              final data = document.data();

              if (data?['isSettlement'] == true) continue;

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

  /// Escucha las nuevas actividades de un viaje.
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchNewActivities(
    String tripId,
  ) {
    late final StreamController<DocumentSnapshot<Map<String, dynamic>>>
        controller;

    StreamSubscription? subscription;
    final processedIds = <String>{};
    bool initialized = false;

    controller = StreamController<DocumentSnapshot<Map<String, dynamic>>>(
      onListen: () {
        subscription = _firestore
            .collection('activities')
            .where('tripId', isEqualTo: tripId)
            .snapshots(includeMetadataChanges: true)
            .listen(
          (snapshot) {
            if (snapshot.metadata.isFromCache) return;

            if (!initialized) {
              processedIds.addAll(
                snapshot.docs.map((doc) => doc.id),
              );
              initialized = true;
              return;
            }

            for (final change in snapshot.docChanges) {
              if (change.type != DocumentChangeType.added) {
                continue;
              }

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

  /// Escucha cambios en los miembros de un viaje.
  ///
  /// La primera fotografía establece el estado inicial.
  /// Después detecta únicamente incorporaciones.
  Stream<List<Map<String, dynamic>>> watchNewMembers(
    String tripId,
  ) {
    late final StreamController<List<Map<String, dynamic>>> controller;

    StreamSubscription? subscription;
    Set<String>? previousMemberIds;

    controller = StreamController<List<Map<String, dynamic>>>(
      onListen: () {
        subscription = _firestore
            .collection('trips')
            .doc(tripId)
            .snapshots(includeMetadataChanges: true)
            .listen(
          (snapshot) {
            if (snapshot.metadata.isFromCache) return;
            if (!snapshot.exists) return;
            if (snapshot.metadata.hasPendingWrites) return;

            final data = snapshot.data();
            if (data == null) return;

            final members = List<Map<String, dynamic>>.from(
              (data['members'] as List<dynamic>? ?? []).map(
                (member) => Map<String, dynamic>.from(member as Map),
              ),
            );

            final currentMemberIds = members
                .map((member) => member['userId'] as String?)
                .whereType<String>()
                .toSet();

            if (previousMemberIds == null) {
              previousMemberIds = currentMemberIds;
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
