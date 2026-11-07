import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final Set<String> _dismissedNotificationIds = {};

  SharedPreferences? _preferences;

  bool _disposed = false;
  bool _initialized = false;
  bool _initializing = false;

  DateTime? _lastReviewedAt;

  List<TripEntity> _latestTrips = [];

  String get _lastReviewedKey => 'travl_notifications_last_reviewed_$_userId';

  String get _dismissedKey => 'travl_notifications_dismissed_$_userId';

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

  // ---------------------------------------------------------------------------
  // INICIALIZACIÓN Y RECUPERACIÓN
  // ---------------------------------------------------------------------------

  void updateTrips(List<TripEntity> trips) {
    if (_disposed) return;

    _latestTrips = trips;

    if (_initialized) {
      _syncTrips(
        trips,
        liveSince: DateTime.now(),
      );
      return;
    }

    if (!_initializing) {
      unawaited(_initialize());
    }
  }

  Future<void> _initialize() async {
    if (_initializing || _initialized || _disposed) return;

    _initializing = true;

    final now = DateTime.now();
    DateTime? recoverySince;

    try {
      try {
        _preferences = await SharedPreferences.getInstance();

        final savedTimestamp = _preferences!.getInt(_lastReviewedKey);

        if (savedTimestamp == null) {
          // Primera ejecución: no recuperamos actividad anterior
          // a la instalación de este sistema de notificaciones.
          _lastReviewedAt = now;

          await _preferences!.setInt(
            _lastReviewedKey,
            now.microsecondsSinceEpoch,
          );
        } else {
          recoverySince = DateTime.fromMicrosecondsSinceEpoch(savedTimestamp);

          _lastReviewedAt = recoverySince;
        }

        _dismissedNotificationIds.addAll(
          _preferences!.getStringList(_dismissedKey) ?? [],
        );

        _processedNotificationIds.addAll(
          _dismissedNotificationIds,
        );
      } catch (_) {
        // Si falla el almacenamiento local, las notificaciones
        // en tiempo real seguirán funcionando durante esta sesión.
        _preferences = null;
        _lastReviewedAt = now;
        recoverySince = null;
      }

      if (_disposed) return;

      _initialized = true;

      _syncTrips(
        _latestTrips,
        liveSince: now,
        recoverSince: recoverySince,
        recoverUntil: now,
      );
    } finally {
      _initializing = false;
    }
  }

  void _syncTrips(
    List<TripEntity> trips, {
    required DateTime liveSince,
    DateTime? recoverSince,
    DateTime? recoverUntil,
  }) {
    if (_disposed) return;

    final currentTripIds = trips.map((trip) => trip.id).toSet();
    final subscribedTripIds = _subscriptions.keys.toSet();

    for (final tripId in subscribedTripIds.difference(currentTripIds)) {
      _removeTripListeners(tripId);
    }

    for (final tripId in currentTripIds.difference(subscribedTripIds)) {
      _listenToTrip(
        tripId,
        after: liveSince,
      );

      if (recoverSince != null && recoverUntil != null) {
        unawaited(
          _recoverTrip(
            tripId,
            since: recoverSince,
            until: recoverUntil,
          ),
        );
      }
    }
  }

  Future<void> _recoverTrip(
    String tripId, {
    required DateTime since,
    required DateTime until,
  }) async {
    if (_disposed || !until.isAfter(since)) return;

    // GASTOS
    try {
      final expenses = await _dataSource.getExpensesSince(
        tripId,
        since,
        until,
      );

      for (final document in expenses) {
        final data = document.data();

        final actorId = data['createdBy'] as String?;

        if (actorId == null || actorId == _userId) continue;
        if (data['isSettlement'] == true) continue;

        final createdAt = _readDate(data['createdAt']);
        if (createdAt == null) continue;

        _addNotification(
          NotificationEntity(
            id: 'expense_${tripId}_${document.id}',
            type: NotificationType.expenseAdded,
            title: '',
            body: data['title'] as String? ?? 'un gasto',
            tripId: tripId,
            actorId: actorId,
            createdAt: createdAt,
          ),
          showNative: false,
        );
      }
    } catch (_) {
      // Se volverá a intentar recuperar en la siguiente apertura.
    }

    if (_disposed) return;
    // ACTIVIDADES
    try {
      final activities = await _dataSource.getActivitiesSince(
        tripId,
        since,
        until,
      );

      for (final document in activities) {
        final data = document.data();

        final actorId = data['createdBy'] as String?;

        if (actorId == null || actorId == _userId) continue;

        final createdAt = _readDate(data['createdAt']);
        if (createdAt == null) continue;

        _addNotification(
          NotificationEntity(
            id: 'activity_${tripId}_${document.id}',
            type: NotificationType.activityAdded,
            title: '',
            body: data['title'] as String? ?? '',
            tripId: tripId,
            actorId: actorId,
            createdAt: createdAt,
          ),
          showNative: false,
        );
      }
    } catch (_) {
      // Se volverá a intentar recuperar en la siguiente apertura.
    }

    if (_disposed) return;

    // INCORPORACIONES DE MIEMBROS
    try {
      final members = await _dataSource.getMembersSince(
        tripId,
        since,
        until,
      );

      for (final member in members) {
        final actorId = member['userId'] as String?;

        if (actorId == null || actorId == _userId) continue;

        final joinedAt = _readDate(member['joinedAt']);
        if (joinedAt == null) continue;

        _addNotification(
          NotificationEntity(
            id: _memberNotificationId(
              tripId,
              actorId,
              joinedAt,
            ),
            type: NotificationType.memberJoined,
            title: '',
            body: '',
            tripId: tripId,
            actorId: actorId,
            createdAt: joinedAt,
          ),
          showNative: false,
        );
      }
    } catch (_) {
      // Se volverá a intentar recuperar en la siguiente apertura.
    }
  }

  DateTime? _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  String _memberNotificationId(
    String tripId,
    String actorId,
    DateTime joinedAt,
  ) {
    return 'member_${tripId}_${actorId}_${joinedAt.microsecondsSinceEpoch}';
  }

  // ---------------------------------------------------------------------------
  // LISTENERS EN TIEMPO REAL
  // ---------------------------------------------------------------------------

  void _listenToTrip(
    String tripId, {
    required DateTime after,
  }) {
    final tripSubscriptions = <StreamSubscription<dynamic>>[];

    // GASTOS
    final expenseSubscription = _dataSource
        .watchNewExpenses(
      tripId,
      after: after,
    )
        .listen(
      (document) {
        final data = document.data();

        if (data == null) return;
        if (data['isSettlement'] == true) return;

        final actorId = data['createdBy'] as String?;

        if (actorId == null || actorId == _userId) return;

        final createdAt = _readDate(data['createdAt']) ?? DateTime.now();

        _addNotification(
          NotificationEntity(
            id: 'expense_${tripId}_${document.id}',
            type: NotificationType.expenseAdded,
            title: '',
            body: data['title'] as String? ?? 'un gasto',
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
    final activitySubscription = _dataSource
        .watchNewActivities(
      tripId,
      after: after,
    )
        .listen(
      (document) {
        final data = document.data();

        if (data == null) return;

        final actorId = data['createdBy'] as String?;

        if (actorId == null || actorId == _userId) return;

        final createdAt = _readDate(data['createdAt']) ?? DateTime.now();

        _addNotification(
          NotificationEntity(
            id: 'activity_${tripId}_${document.id}',
            type: NotificationType.activityAdded,
            title: '',
            body: data['title'] as String? ?? '',
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
    final memberSubscription = _dataSource
        .watchNewMembers(
      tripId,
      after: after,
    )
        .listen(
      (members) {
        for (final member in members) {
          final actorId = member['userId'] as String?;

          if (actorId == null || actorId == _userId) continue;

          final joinedAt = _readDate(member['joinedAt']) ?? DateTime.now();

          _addNotification(
            NotificationEntity(
              id: _memberNotificationId(
                tripId,
                actorId,
                joinedAt,
              ),
              type: NotificationType.memberJoined,
              title: '',
              body: '',
              tripId: tripId,
              actorId: actorId,
              createdAt: joinedAt,
            ),
          );
        }
      },
      onError: (error, stackTrace) {},
    );

    tripSubscriptions.add(memberSubscription);

    _subscriptions[tripId] = tripSubscriptions;
  }

  // ---------------------------------------------------------------------------
  // CREACIÓN Y NOTIFICACIÓN NATIVA
  // ---------------------------------------------------------------------------

  void _addNotification(
    NotificationEntity notification, {
    bool showNative = true,
  }) {
    if (_disposed) return;

    final lastReviewed = _lastReviewedAt;

    if (lastReviewed != null && !notification.createdAt.isAfter(lastReviewed)) {
      return;
    }

    if (_dismissedNotificationIds.contains(notification.id)) return;

    if (!_processedNotificationIds.add(notification.id)) return;

    state = [
      notification,
      ...state,
    ];

    // Solo los eventos recibidos en tiempo real generan un aviso nativo.
    if (showNative) {
      unawaited(_showLocalNotification(notification));
    }
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
      // Un fallo nativo no debe afectar a las notificaciones internas.
    }
  }

  // ---------------------------------------------------------------------------
  // LECTURA Y DESCARTE
  // ---------------------------------------------------------------------------

  void markAsRead(String notificationId) {
    final exists = state.any(
      (notification) => notification.id == notificationId,
    );

    if (!exists) return;

    state = state
        .where((notification) => notification.id != notificationId)
        .toList();

    _dismissedNotificationIds.add(notificationId);

    _persistDismissedIds();
  }

  void markAllAsRead() {
    state = const [];

    _dismissedNotificationIds.clear();

    final now = DateTime.now();
    _lastReviewedAt = now;

    _preferences?.setInt(
      _lastReviewedKey,
      now.microsecondsSinceEpoch,
    );

    _preferences?.remove(_dismissedKey);
  }

  void clearNotifications() {
    markAllAsRead();
  }

  void _persistDismissedIds() {
    final preferences = _preferences;
    if (preferences == null) return;

    unawaited(
      preferences.setStringList(
        _dismissedKey,
        _dismissedNotificationIds.toList(),
      ),
    );
  }

  int get unreadCount =>
      state.where((notification) => !notification.isRead).length;

  // ---------------------------------------------------------------------------
  // LIMPIEZA
  // ---------------------------------------------------------------------------

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
