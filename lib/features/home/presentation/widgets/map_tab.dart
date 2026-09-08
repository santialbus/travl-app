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
import 'dart:ui' as ui;

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

        final selectedTrip = _selectedTripId == null
            ? null
            : trips.cast<TripEntity?>().firstWhere(
                  (trip) => trip?.id == _selectedTripId,
                  orElse: () => null,
                );

        return SafeArea(
          child: _GeocodedMap(
            trips: trips,
            mapController: _mapController,
            selectedTripId: _selectedTripId,
            selectedTrip: selectedTrip,
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
            },
            onAllSelected: () {
              setState(() => _selectedTripId = null);
              _fitAllTrips(trips);
            },
            onClosePreview: () {
              setState(() => _selectedTripId = null);
            },
            onViewTrip: (trip) {
              context.push('/trip/${trip.id}');
            },
          ),
        );
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          _MapBackground(mapController: _mapController),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _FloatingHeader(
              title: context.tr('map_title'),
              subtitle: context.tr('map_subtitle'),
            ),
          ),
          Center(
            child: _GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return SafeArea(
      child: Stack(
        children: [
          _MapBackground(mapController: _mapController),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _FloatingHeader(
              title: context.tr('map_title'),
              subtitle: context.tr('map_subtitle'),
            ),
          ),
          Center(
            child: _GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(20),
              child: Text(
                '${context.tr('error_prefix')} $error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _fitAllTrips(List<TripEntity> trips) {
    final points = <LatLng>[];

    for (final trip in trips) {
      final point = ref.read(geocodingProvider(trip.destination)).valueOrNull;

      if (point != null) {
        points.add(
          LatLng(point.latitude, point.longitude),
        );
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
          padding: const EdgeInsets.fromLTRB(70, 140, 70, 150),
        ),
      );
    });
  }
}

class _GeocodedMap extends ConsumerWidget {
  final List<TripEntity> trips;
  final MapController mapController;
  final String? selectedTripId;
  final TripEntity? selectedTrip;
  final bool hasInitialFit;
  final VoidCallback onInitialFitDone;
  final void Function(TripEntity trip, LatLng point) onTripSelected;
  final void Function(TripEntity trip) onMarkerTap;
  final VoidCallback onAllSelected;
  final VoidCallback onClosePreview;
  final void Function(TripEntity trip) onViewTrip;

  const _GeocodedMap({
    required this.trips,
    required this.mapController,
    required this.selectedTripId,
    required this.selectedTrip,
    required this.hasInitialFit,
    required this.onInitialFitDone,
    required this.onTripSelected,
    required this.onMarkerTap,
    required this.onAllSelected,
    required this.onClosePreview,
    required this.onViewTrip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = <String, LatLng>{};
    var loadingCount = 0;

    for (final trip in trips) {
      final result = ref.watch(
        geocodingProvider(trip.destination),
      );

      result.when(
        data: (geo) {
          if (geo != null) {
            points[trip.id] = LatLng(
              geo.latitude,
              geo.longitude,
            );
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
          mapController.move(
            points.values.first,
            8.0,
          );
        } else {
          mapController.fitCamera(
            CameraFit.bounds(
              bounds: LatLngBounds.fromPoints(
                points.values.toList(),
              ),
              padding: const EdgeInsets.fromLTRB(
                70,
                140,
                70,
                150,
              ),
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
          width: trip.id == selectedTripId ? 190 : 52,
          height: trip.id == selectedTripId ? 92 : 52,
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
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
          borderRadius: BorderRadius.circular(28),
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: const LatLng(
                40.4168,
                -3.7038,
              ),
              initialZoom: 3.0,
              minZoom: 2.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.travl.app',
              ),
              MarkerLayer(
                markers: markers,
              ),
            ],
          ),
        ),

        // Header
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: _FloatingHeader(
            title: context.tr('map_title'),
            subtitle: trips.length == 1
                ? '1 ${context.tr('destination')}'
                : '${trips.length} ${context.tr('destinations')}',
          ),
        ),

        // Geocoding loading
        if (loadingCount > 0)
          Positioned(
            top: 90,
            left: 16,
            child: _LoadingPill(
              text: context.tr('loading_destinations'),
            ),
          ),

        // Center / fit button
        Positioned(
          right: 16,
          bottom: selectedTrip != null ? 215 : 92,
          child: _FloatingMapButton(
            icon: Icons.my_location_rounded,
            onPressed: () {
              if (points.isEmpty) return;

              if (points.length == 1) {
                mapController.move(
                  points.values.first,
                  8.0,
                );
              } else {
                mapController.fitCamera(
                  CameraFit.bounds(
                    bounds: LatLngBounds.fromPoints(
                      points.values.toList(),
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      70,
                      140,
                      70,
                      150,
                    ),
                  ),
                );
              }
            },
          ),
        ),

        // Selected trip preview
        if (selectedTrip != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 78,
            child: _TripPreviewCard(
              trip: selectedTrip!,
              onClose: onClosePreview,
              onViewTrip: () => onViewTrip(selectedTrip!),
            ),
          ),

        // Trip selector
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
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

  const _MapBackground({
    required this.mapController,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: FlutterMap(
        mapController: mapController,
        options: const MapOptions(
          initialCenter: LatLng(
            40.4168,
            -3.7038,
          ),
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

class _FloatingHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _FloatingHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GlassContainer(
            borderRadius: 20,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 13,
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.explore_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.62),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TripSelector extends StatelessWidget {
  final List<TripEntity> trips;
  final Map<String, LatLng> points;
  final String? selectedTripId;
  final VoidCallback onAllSelected;
  final void Function(
    TripEntity trip,
    LatLng point,
  ) onTripSelected;

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
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _TripChip(
            label: context.tr('map_all'),
            icon: Icons.public_rounded,
            selected: selectedTripId == null,
            onTap: onAllSelected,
          ),
          const SizedBox(width: 8),
          ...trips.map(
            (trip) {
              final point = points[trip.id];

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _TripChip(
                  label: trip.destination,
                  icon: Icons.flight_takeoff_rounded,
                  selected: selectedTripId == trip.id,
                  enabled: point != null,
                  onTap: point == null
                      ? null
                      : () => onTripSelected(
                            trip,
                            point,
                          ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TripChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  const _TripChip({
    required this.label,
    required this.icon,
    required this.selected,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(25),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : colorScheme.surface.withValues(
                    alpha: enabled ? 0.92 : 0.62,
                  ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : colorScheme.onSurface.withValues(
                      alpha: 0.08,
                    ),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: selected ? 16 : 12,
                offset: const Offset(0, 4),
                color: Colors.black.withValues(
                  alpha: selected ? 0.18 : 0.10,
                ),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected
                    ? Colors.white
                    : colorScheme.onSurface.withValues(
                        alpha: enabled ? 0.72 : 0.35,
                      ),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: selected
                      ? Colors.white
                      : colorScheme.onSurface.withValues(
                          alpha: enabled ? 0.9 : 0.4,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingMapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _FloatingMapButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(17),
        child: _GlassContainer(
          borderRadius: 17,
          padding: EdgeInsets.zero,
          child: SizedBox(
            width: 50,
            height: 50,
            child: Icon(
              icon,
              size: 22,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingPill extends StatelessWidget {
  final String text;

  const _LoadingPill({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 9,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
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

  Color _markerColor() {
    final now = DateTime.now();

    if (trip.startDate.isBefore(now) && trip.endDate.isAfter(now)) {
      return AppColors.primary;
    }

    if (trip.startDate.isAfter(now)) {
      return AppColors.success;
    }

    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final markerColor = _markerColor();

    if (!isSelected) {
      return Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: markerColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: Colors.black.withValues(alpha: 0.22),
              ),
            ],
          ),
          child: const Icon(
            Icons.flight_rounded,
            size: 10,
            color: Colors.white,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: markerColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                blurRadius: 14,
                offset: const Offset(0, 5),
                color: Colors.black.withValues(alpha: 0.20),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.flight_rounded,
                size: 15,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  trip.destination,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        CustomPaint(
          size: const Size(16, 8),
          painter: _MarkerPointerPainter(
            color: markerColor,
          ),
        ),
        Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(
            color: markerColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
        ),
      ],
    );
  }
}

class _MarkerPointerPainter extends CustomPainter {
  final Color color;

  _MarkerPointerPainter({
    required this.color,
  });

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(
      path,
      ui.Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(
    covariant _MarkerPointerPainter oldDelegate,
  ) {
    return oldDelegate.color != color;
  }
}

class _TripPreviewCard extends StatelessWidget {
  final TripEntity trip;
  final VoidCallback onClose;
  final VoidCallback onViewTrip;

  const _TripPreviewCard({
    required this.trip,
    required this.onClose,
    required this.onViewTrip,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM');

    return Material(
      color: Colors.transparent,
      child: _GlassContainer(
        borderRadius: 22,
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            _TripCover(
              imageUrl: trip.coverImage,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 15,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          trip.destination,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.55),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.60),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.55),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 34,
                  child: FilledButton(
                    onPressed: onViewTrip,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TripCover extends StatelessWidget {
  final String? imageUrl;

  const _TripCover({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.flight_takeoff_rounded,
          color: AppColors.primary,
          size: 28,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        imageUrl!,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: 72,
            height: 72,
            color: AppColors.primary.withValues(alpha: 0.10),
            child: Icon(
              Icons.flight_takeoff_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          );
        },
      ),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;

  const _GlassContainer({
    required this.child,
    required this.borderRadius,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.91),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            offset: const Offset(0, 7),
            color: Colors.black.withValues(alpha: 0.15),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _EmptyMap extends ConsumerWidget {
  const _EmptyMap();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Stack(
        children: [
          _MapBackground(
            mapController: MapController(),
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _FloatingHeader(
              title: context.tr('map_title'),
              subtitle: context.tr('map_subtitle'),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: _GlassContainer(
                borderRadius: 24,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 30,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.map_rounded,
                        size: 34,
                        color: AppColors.primary,
                      ),
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.65),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
