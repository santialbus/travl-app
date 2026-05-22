import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../trip/presentation/providers/trip_provider.dart';
import '../../../trip/domain/entities/trip_entity.dart';

class MapTab extends ConsumerWidget {
  final String userId;

  const MapTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(userTripsProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Map 🗺️', style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Text(
                    'All your destinations',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Map
            Expanded(
              child: tripsAsync.when(
                data: (trips) => _TripMap(trips: trips),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),

            // Trips list below map
            tripsAsync.when(
              data: (trips) {
                if (trips.isEmpty) return const SizedBox.shrink();
                return Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: trips.length,
                    itemBuilder: (context, index) {
                      return _TripChip(trip: trips[index]);
                    },
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripMap extends StatelessWidget {
  final List<TripEntity> trips;

  const _TripMap({required this.trips});

  @override
  Widget build(BuildContext context) {
    // Default center (world view)
    const defaultCenter = LatLng(20, 0);

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: defaultCenter,
            initialZoom: 1.5,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.travl.app',
            ),
            MarkerLayer(
              markers: trips
                  .where((t) => t.destination.isNotEmpty)
                  .map(
                    (trip) => Marker(
                  point: _getCoordinates(trip.destination),
                  width: 40,
                  height: 40,
                  child: _TripMarker(trip: trip),
                ),
              )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Simple coordinates mapping
  // In V2 we'll use geocoding API
  LatLng _getCoordinates(String destination) {
    // Fallback to random-ish coordinates based on destination string
    // This will be replaced with real geocoding in V2
    final hash = destination.hashCode;
    final lat = (hash % 140) - 70.0;
    final lng = ((hash ~/ 140) % 360) - 180.0;
    return LatLng(lat.clamp(-85, 85), lng.clamp(-180, 180));
  }
}

class _TripMarker extends StatelessWidget {
  final TripEntity trip;

  const _TripMarker({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.flight_takeoff,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}

class _TripChip extends StatelessWidget {
  final TripEntity trip;

  const _TripChip({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            trip.destination,
            style: AppTextStyles.labelLarge,
          ),
          const SizedBox(height: 2),
          Text(
            trip.name,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}