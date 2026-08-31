import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/geocoding_service.dart';
import '../../../../core/providers/geocoding_provider.dart';
import '../../../trip/presentation/providers/trip_provider.dart';
import '../../../trip/domain/entities/trip_entity.dart';

class MapTab extends ConsumerWidget {
  final String userId;

  const MapTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(userTripsProvider(userId));

    return Scaffold(
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
                  Text(context.tr('map_title'), style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('map_subtitle'),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),

            // Map
            Expanded(
              child: tripsAsync.when(
                data: (trips) => _GeocodedMap(trips: trips),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('${context.tr('error_prefix')} $e')),
              ),
            ),

            // Chips de destinos
            tripsAsync.when(
              data: (trips) {
                if (trips.isEmpty) return const SizedBox.shrink();
                return Container(
                  height: 88,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: trips.length,
                    itemBuilder: (context, index) =>
                        _TripChip(trip: trips[index]),
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

class _GeocodedMap extends ConsumerWidget {
  final List<TripEntity> trips;

  const _GeocodedMap({required this.trips});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (trips.isEmpty) return _EmptyMap();

    // ✅ Geocodificar cada destino individualmente
    final markers = <Marker>[];
    double totalLat = 0;
    double totalLng = 0;
    int validCount = 0;

    for (final trip in trips) {
      if (trip.destination.isEmpty) continue;

      final geocodingAsync = ref.watch(geocodingProvider(trip.destination));

      geocodingAsync.whenData((result) {
        if (result != null) {
          totalLat += result.latitude;
          totalLng += result.longitude;
          validCount++;
        }
      });
    }

    // Construir marcadores
    final tripMarkers = trips
        .map((trip) {
          if (trip.destination.isEmpty) return null;

          final geocodingAsync = ref.watch(geocodingProvider(trip.destination));

          return geocodingAsync.when(
            data: (result) {
              if (result == null) return null;

              return Marker(
                point: LatLng(result.latitude, result.longitude),
                width: 160,
                height: 60,
                child: _TripMarker(trip: trip),
              );
            },
            loading: () => null,
            error: (_, __) => null,
          );
        })
        .whereType<Marker>()
        .toList();

    // Si ninguno ha cargado aún
    if (tripMarkers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(context.tr('loading_destinations')),
          ],
        ),
      );
    }

    // Calcular centro
    final center = tripMarkers.isNotEmpty
        ? LatLng(
            tripMarkers.map((m) => m.point.latitude).reduce((a, b) => a + b) /
                tripMarkers.length,
            tripMarkers.map((m) => m.point.longitude).reduce((a, b) => a + b) /
                tripMarkers.length,
          )
        : const LatLng(20, 0);

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: tripMarkers.length == 1 ? 8.0 : 3.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.travl.app',
            ),
            MarkerLayer(markers: tripMarkers),
          ],
        ),
      ),
    );
  }
}

class _TripMarker extends StatelessWidget {
  final TripEntity trip;

  const _TripMarker({required this.trip});

  @override
  Widget build(BuildContext context) {
    final isOngoing = trip.startDate.isBefore(DateTime.now()) &&
        trip.endDate.isAfter(DateTime.now());

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isOngoing ? AppColors.primary : AppColors.cardDark,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            trip.destination,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ),

        // Pin
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isOngoing ? AppColors.primary : AppColors.cardDark,
            shape: BoxShape.circle,
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor(context)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ✅ Añadir esto
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            trip.destination,
            style: AppTextStyles.labelLarge,
            maxLines: 1, // ✅ Añadir
            overflow: TextOverflow.ellipsis, // ✅ Añadir
          ),
          Text(
            trip.name,
            style: AppTextStyles.bodySmall,
            maxLines: 1, // ✅ Añadir
            overflow: TextOverflow.ellipsis, // ✅ Añadir
          ),
        ],
      ),
    );
  }
}

class _EmptyMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🗺️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              context.tr('no_destinations'),
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('no_destinations_description'),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
