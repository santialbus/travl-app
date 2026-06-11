import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../../features/trip/presentation/pages/create_trip_page.dart';
import '../../features/trip/presentation/pages/qr_scanner_page.dart';
import '../../features/trip/presentation/pages/trip_dashboard_page.dart';
import '../constants/route_constants.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteConstants.splash, // ✅ Empieza en splash
    routes: [
      GoRoute(
        path: RouteConstants.splash,
        pageBuilder: (context, state) => const MaterialPage(
          child: SplashPage(),
        ),
      ),
      GoRoute(
        path: RouteConstants.auth,
        pageBuilder: (context, state) => const MaterialPage(
          child: AuthPage(),
        ),
      ),
      GoRoute(
        path: RouteConstants.home,
        pageBuilder: (context, state) => const MaterialPage(
          child: HomePage(),
        ),
      ),
      GoRoute(
        path: RouteConstants.createTrip,
        pageBuilder: (context, state) => MaterialPage(
          child: const CreateTripPage(),
          fullscreenDialog: true,
        ),
      ),
      GoRoute(
        path: RouteConstants.tripDashboard,
        pageBuilder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          final isReadOnly = state.uri.queryParameters['readOnly'] == 'true';
          return MaterialPage(
            child: TripDashboardPage(tripId: tripId, isReadOnly: isReadOnly),
          );
        },
      ),
      GoRoute(
        path: RouteConstants.qrScanner,
        pageBuilder: (context, state) {
          final userId = state.extra as String;

          return MaterialPage(
            fullscreenDialog: true,
            child: QrScannerPage(
              userId: userId,
            ),
          );
        },
      ),
    ],
  );
});