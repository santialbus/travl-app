import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/notification_entity.dart';
import '../../../trip/domain/entities/trip_entity.dart';
import '../../../trip/presentation/providers/trip_provider.dart';
import '../../../trip/presentation/providers/users_provider.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/services/local_notification_service.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/providers/locale_provider.dart';

final notificationDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
  return NotificationRemoteDataSource();
});

final notificationControllerProvider = StateNotifierProvider.autoDispose
    .family<NotificationController, List<NotificationEntity>, String>(
  (ref, userId) {
    final dataSource = ref.watch(notificationDataSourceProvider);

    final controller = NotificationController(
      dataSource: dataSource,
      userId: userId,
      getLanguageCode: () => ref.read(effectiveLanguageCodeProvider),
      getUserName: (actorId) => ref.read(userNameProvider(actorId).future),
    );

    ref.listen<AsyncValue<List<TripEntity>>>(
      userTripsProvider(userId),
      (previous, next) {
        next.whenData(controller.updateTrips);
      },
      fireImmediately: true,
    );

    return controller;
  },
);

class NotificationController extends StateNotifier<List<NotificationEntity>> {
  final NotificationRemoteDataSource _dataSource;
  final String _userId;

  final String Function() _getLanguageCode;
  final Future<String> Function(String actorId) _getUserName;

  final Map<String, List<StreamSubscription<dynamic>>> _subscriptions = {};
  final Set<String> _processedNotificationIds = {};

  bool _disposed = false;

  NotificationController({
    required NotificationRemoteDataSource dataSource,
    required String userId,
    required String Function() getLanguageCode,
    required Future<String> Function(String actorId) getUserName,
  })  : _dataSource = dataSource,
        _userId = userId,
        _getLanguageCode = getLanguageCode,
        _getUserName = getUserName,
        super(const []);

  /// Actualiza los viajes que deben tener listeners activos.
  void updateTrips(List<TripEntity> trips) {
    if (_disposed) return;

    final currentTripIds = trips.map((trip) => trip.id).toSet();
    final subscribedTripIds = _subscriptions.keys.toSet();

    for (final tripId in subscribedTripIds.difference(currentTripIds)) {
      _removeTripListeners(tripId);
    }

    for (final tripId in currentTripIds.difference(subscribedTripIds)) {
      _listenToTrip(tripId);
    }
  }

  void _listenToTrip(String tripId) {
    final tripSubscriptions = <StreamSubscription<dynamic>>[];

    // GASTOS
    final expenseSubscription = _dataSource.watchNewExpenses(tripId).listen(
      (document) {
        final data = document.data();

        if (data == null) return;
        if (data['isSettlement'] == true) return;

        final actorId = data['createdBy'] as String?;

        if (actorId == null || actorId == _userId) return;

        final expenseTitle = data['title'] as String? ?? 'un gasto';

        final createdAt = data['createdAt'] is Timestamp
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now();

        _addNotification(
          NotificationEntity(
            id: 'expense_${tripId}_${document.id}',
            type: NotificationType.expenseAdded,
            title: '',
            body: expenseTitle,
            tripId: tripId,
            actorId: actorId,
            createdAt: createdAt,
          ),
        );
      },
      onError: (error, stackTrace) {},
    );

    tripSubscriptions.add(expenseSubscription);

    // ACTIVIDADES
    final activitySubscription = _dataSource.watchNewActivities(tripId).listen(
      (document) {
        final data = document.data();

        if (data == null) return;

        final actorId = data['createdBy'] as String?;

        if (actorId == null || actorId == _userId) return;

        final activityTitle = data['title'] as String? ?? '';

        final createdAt = data['createdAt'] is Timestamp
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now();

        _addNotification(
          NotificationEntity(
            id: 'activity_${tripId}_${document.id}',
            type: NotificationType.activityAdded,
            title: '',
            body: activityTitle,
            tripId: tripId,
            actorId: actorId,
            createdAt: createdAt,
          ),
        );
      },
      onError: (error, stackTrace) {},
    );

    tripSubscriptions.add(activitySubscription);

    // INCORPORACIONES DE MIEMBROS
    final memberSubscription = _dataSource.watchNewMembers(tripId).listen(
      (members) {
        for (final member in members) {
          final actorId = member['userId'] as String?;

          if (actorId == null || actorId == _userId) continue;

          _addNotification(
            NotificationEntity(
              id: 'member_${tripId}_$actorId',
              type: NotificationType.memberJoined,
              title: '',
              body: '',
              tripId: tripId,
              actorId: actorId,
              createdAt: DateTime.now(),
            ),
          );
        }
      },
      onError: (error, stackTrace) {},
    );

    tripSubscriptions.add(memberSubscription);

    _subscriptions[tripId] = tripSubscriptions;
  }

  void _addNotification(NotificationEntity notification) {
    if (_disposed) return;

    if (!_processedNotificationIds.add(notification.id)) return;

    // Mantenemos intacto el sistema interno.
    state = [
      notification,
      ...state,
    ];

    // La notificación nativa se procesa en paralelo.
    unawaited(_showLocalNotification(notification));
  }

  Future<void> _showLocalNotification(
    NotificationEntity notification,
  ) async {
    try {
      final languageCode = _getLanguageCode();

      final actorName = await _getUserName(notification.actorId);

      if (_disposed) return;

      final displayName =
          actorName.trim().isEmpty || actorName.toLowerCase() == 'unknown'
              ? 'Travl'
              : actorName.trim();

      late final String titleKey;
      late final String bodyKey;
      final params = <String, String>{
        'name': displayName,
      };

      switch (notification.type) {
        case NotificationType.expenseAdded:
          titleKey = 'notification_expense_title';
          bodyKey = 'notification_expense_body';
          params['title'] = notification.body;
          break;

        case NotificationType.activityAdded:
          titleKey = 'notification_activity_title';
          bodyKey = 'notification_activity_body';
          params['title'] = notification.body;
          break;

        case NotificationType.memberJoined:
          titleKey = 'notification_member_title';
          bodyKey = 'notification_member_body';
          break;
      }

      final title = AppStrings.get(
        titleKey,
        languageCode,
      );

      final body = AppStrings.get(
        bodyKey,
        languageCode,
        params: params,
      );

      await LocalNotificationService.instance.showNotification(
        id: notification.id.hashCode & 0x7fffffff,
        title: title,
        body: body,
        payload: notification.tripId,
      );
    } catch (_) {
      // Un fallo de la notificación nativa no debe afectar
      // al funcionamiento de las notificaciones internas.
    }
  }

  void markAsRead(String notificationId) {
    state = [
      for (final notification in state)
        if (notification.id == notificationId)
          notification.copyWith(isRead: true)
        else
          notification,
    ];
  }

  void markAllAsRead() {
    state = [
      for (final notification in state) notification.copyWith(isRead: true),
    ];
  }

  void clearNotifications() {
    state = const [];
    _processedNotificationIds.clear();
  }

  int get unreadCount =>
      state.where((notification) => !notification.isRead).length;

  void _removeTripListeners(String tripId) {
    final subscriptions = _subscriptions.remove(tripId);

    if (subscriptions == null) return;

    for (final subscription in subscriptions) {
      subscription.cancel();
    }
  }

  @override
  void dispose() {
    _disposed = true;

    for (final tripId in _subscriptions.keys.toList()) {
      _removeTripListeners(tripId);
    }

    super.dispose();
  }
}
