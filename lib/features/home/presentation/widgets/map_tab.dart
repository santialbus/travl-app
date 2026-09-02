import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:travl/core/providers/geocoding_provider.dart';
import 'package:travl/core/theme/app_colors.dart';
import 'package:travl/features/trip/domain/entities/trip_entity.dart';
import 'package:travl/features/trip/presentation/providers/trip_provider.dart';
import '../../../../core/localization/app_strings.dart';

class MapTab extends ConsumerStatefulWidget {
  final String userId;

  const MapTab({super.key, required this.userId});

  @override
  ConsumerState<MapTab> createState() => _MapTabState();
}

class _MapTabState extends ConsumerState<MapTab> {
  final MapController _mapController = MapController();
  String? _selectedTripId;
  bool _hasInitialFit = false;

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(userTripsProvider(widget.userId));

    return tripsAsync.when(
      loading: () => _buildLoading(context),
      error: (error, _) => _buildError(context, error),
      data: (trips) {
        if (trips.isEmpty) {
          return const _EmptyMap();
        }

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MapHeader(),
              const SizedBox(height: 12),
              Expanded(
                child: _GeocodedMap(
                  trips: trips,
                  mapController: _mapController,
                  selectedTripId: _selectedTripId,
                  hasInitialFit: _hasInitialFit,
                  onInitialFitDone: () {
                    if (mounted) {
                      setState(() => _hasInitialFit = true);
                    }
                  },
                  onTripSelected: (trip, point) {
                    setState(() => _selectedTripId = trip.id);
                    _mapController.move(point, 8.0);
                  },
                  onMarkerTap: (trip) {
                    setState(() => _selectedTripId = trip.id);
                    _showTripBottomSheet(context, trip);
                  },
                  onAllSelected: () {
                    setState(() => _selectedTripId = null);
                    _fitAllTrips(trips);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    return SafeArea(
        child: Column(
      children: [
        const _MapHeader(),
        const SizedBox(height: 12),
        Expanded(
          child: Stack(
            children: [
              _MapBackground(mapController: _mapController),
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20,
                        color: Colors.black.withValues(alpha: 0.12),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        context.tr('loading_destinations'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  Widget _buildError(BuildContext context, Object error) {
    return SafeArea(
        child: Column(
      children: [
        const _MapHeader(),
        const SizedBox(height: 12),
        Expanded(
          child: Center(
            child: Text(
              '${context.tr('error_prefix')} $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    ));
  }

  void _fitAllTrips(List<TripEntity> trips) {
    final points = <LatLng>[];

    for (final trip in trips) {
      final point = ref.read(geocodingProvider(trip.destination)).valueOrNull;

      if (point != null) {
        points.add(LatLng(point.latitude, point.longitude));
      }
    }

    if (points.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (points.length == 1) {
        _mapController.move(points.first, 8.0);
        return;
      }

      final bounds = LatLngBounds.fromPoints(points);

      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(70),
        ),
      );
    });
  }

  void _showTripBottomSheet(BuildContext context, TripEntity trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _TripBottomSheet(
          trip: trip,
          onViewTrip: () {
            Navigator.of(context).pop();
            context.push('/trip/${trip.id}');
          },
        );
      },
    );
  }
}

class _GeocodedMap extends ConsumerWidget {
  final List<TripEntity> trips;
  final MapController mapController;
  final String? selectedTripId;
  final bool hasInitialFit;
  final VoidCallback onInitialFitDone;
  final void Function(TripEntity trip, LatLng point) onTripSelected;
  final void Function(TripEntity trip) onMarkerTap;
  final VoidCallback onAllSelected;

  const _GeocodedMap({
    required this.trips,
    required this.mapController,
    required this.selectedTripId,
    required this.hasInitialFit,
    required this.onInitialFitDone,
    required this.onTripSelected,
    required this.onMarkerTap,
    required this.onAllSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = <String, LatLng>{};
    var loadingCount = 0;

    for (final trip in trips) {
      final result = ref.watch(geocodingProvider(trip.destination));

      result.when(
        data: (geo) {
          if (geo != null) {
            points[trip.id] = LatLng(geo.latitude, geo.longitude);
          }
        },
        loading: () => loadingCount++,
        error: (_, __) {},
      );
    }

    if (!hasInitialFit && points.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;

        if (points.length == 1) {
          mapController.move(points.values.first, 8.0);
        } else {
          mapController.fitCamera(
            CameraFit.bounds(
              bounds: LatLngBounds.fromPoints(points.values.toList()),
              padding: const EdgeInsets.all(70),
            ),
          );
        }

        onInitialFitDone();
      });
    }

    final markers = <Marker>[];

    for (final trip in trips) {
      final point = points[trip.id];

      if (point == null) continue;

      markers.add(
        Marker(
          point: point,
          width: 170,
          height: 80,
          child: GestureDetector(
            onTap: () => onMarkerTap(trip),
            child: _TripMarker(
              trip: trip,
              isSelected: selectedTripId == trip.id,
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: const LatLng(40.4168, -3.7038),
              initialZoom: 3.0,
              minZoom: 2.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.travl.app',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
        ),
        if (loadingCount > 0)
          Positioned(
            top: 14,
            left: 14,
            right: 14,
            child: _LoadingPill(
              text: context.tr('loading_destinations'),
            ),
          ),
        Positioned(
          right: 16,
          bottom: 16,
          child: _MapControlButton(
            icon: Icons.my_location_rounded,
            onPressed: () {
              if (points.isEmpty) return;

              if (points.length == 1) {
                mapController.move(points.values.first, 8.0);
              } else {
                mapController.fitCamera(
                  CameraFit.bounds(
                    bounds: LatLngBounds.fromPoints(points.values.toList()),
                    padding: const EdgeInsets.all(70),
                  ),
                );
              }
            },
          ),
        ),
        Positioned(
          left: 14,
          right: 14,
          bottom: 14,
          child: _TripSelector(
            trips: trips,
            points: points,
            selectedTripId: selectedTripId,
            onAllSelected: onAllSelected,
            onTripSelected: onTripSelected,
          ),
        ),
      ],
    );
  }
}

class _MapBackground extends StatelessWidget {
  final MapController mapController;

  const _MapBackground({required this.mapController});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: FlutterMap(
        mapController: mapController,
        options: const MapOptions(
          initialCenter: LatLng(40.4168, -3.7038),
          initialZoom: 3.0,
          minZoom: 2.0,
          maxZoom: 18.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.travl.app',
          ),
        ],
      ),
    );
  }
}

class _TripSelector extends StatelessWidget {
  final List<TripEntity> trips;
  final Map<String, LatLng> points;
  final String? selectedTripId;
  final VoidCallback onAllSelected;
  final void Function(TripEntity trip, LatLng point) onTripSelected;

  const _TripSelector({
    required this.trips,
    required this.points,
    required this.selectedTripId,
    required this.onAllSelected,
    required this.onTripSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _TripChip(
            label: context.tr('map_all'),
            selected: selectedTripId == null,
            onTap: onAllSelected,
          ),
          const SizedBox(width: 8),
          ...trips.map((trip) {
            final point = points[trip.id];

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _TripChip(
                label: trip.destination,
                selected: selectedTripId == trip.id,
                enabled: point != null,
                onTap: point == null ? null : () => onTripSelected(trip, point),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TripChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  const _TripChip({
    required this.label,
    required this.selected,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;
    final background = Theme.of(context).colorScheme.surface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected
                ? primary
                : background.withValues(alpha: enabled ? 0.94 : 0.65),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected
                  ? primary
                  : Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: Colors.black.withValues(alpha: 0.10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _MapControlButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 5,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(Icons.my_location_rounded),
        ),
      ),
    );
  }
}

class _LoadingPill extends StatelessWidget {
  final String text;

  const _LoadingPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 15,
            color: Colors.black.withValues(alpha: 0.10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 9),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripMarker extends StatelessWidget {
  final TripEntity trip;
  final bool isSelected;

  const _TripMarker({
    required this.trip,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? primary : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black.withValues(alpha: 0.18),
              ),
            ],
          ),
          child: Text(
            trip.destination,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                color: Colors.black.withValues(alpha: 0.20),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TripBottomSheet extends StatelessWidget {
  final TripEntity trip;
  final VoidCallback onViewTrip;

  const _TripBottomSheet({
    required this.trip,
    required this.onViewTrip,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (trip.coverImage != null && trip.coverImage!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  trip.coverImage!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            if (trip.coverImage != null && trip.coverImage!.isNotEmpty)
              const SizedBox(height: 16),
            Text(
              trip.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    trip.destination,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _TripInfo(
                    icon: Icons.calendar_today_outlined,
                    text:
                        '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)}',
                  ),
                ),
                const SizedBox(width: 12),
                _TripInfo(
                  icon: Icons.timelapse_rounded,
                  text: '${trip.numberOfDays} ${context.tr('days')}',
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onViewTrip,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(context.tr('view_trip')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TripInfo({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 17,
          color: AppColors.primary,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _MapHeader extends ConsumerWidget {
  const _MapHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.tr('map_title'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            ref.tr('map_subtitle'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.65),
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMap extends ConsumerWidget {
  const _EmptyMap();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const _MapHeader(),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 64,
                    color: AppColors.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    ref.tr('no_destinations'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ref.tr('no_destinations_description'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
