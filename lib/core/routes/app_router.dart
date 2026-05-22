import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/trip/presentation/pages/create_trip_page.dart';
import '../../features/trip/presentation/pages/trip_dashboard_page.dart';
import '../constants/route_constants.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteConstants.auth,
    routes: [
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
          return MaterialPage(
            child: TripDashboardPage(tripId: tripId),
          );
        },
      ),
    ],
  );
});