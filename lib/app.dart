import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/constants/route_constants.dart';
import 'core/providers/theme_provider.dart';
import 'features/notifications/data/services/local_notification_service.dart';

class TravlApp extends ConsumerStatefulWidget {
  const TravlApp({super.key});

  @override
  ConsumerState<TravlApp> createState() => _TravlAppState();
}

class _TravlAppState extends ConsumerState<TravlApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
  }

  Future<void> _initializeNotifications() async {
    final router = ref.read(routerProvider);

    await LocalNotificationService.instance.initialize(
      onNotificationTap: (payload) {
        if (payload == null || payload.isEmpty) return;

        final location = RouteConstants.tripDashboard.replaceFirst(
          ':tripId',
          payload,
        );

        router.go(location);
      },
    );

    await LocalNotificationService.instance.requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Travl',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode.flutterThemeMode,
      routerConfig: router,
    );
  }
}
