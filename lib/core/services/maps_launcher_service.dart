import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import '../localization/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'maps_preference_service.dart';

class MapsLauncherService {
  MapsLauncherService._();

  /// Abre el mapa con la preferencia guardada o pregunta la primera vez
  static Future<void> openMap({
    required BuildContext context,
    required String title,
    required String query,
    double? latitude,
    double? longitude,
  }) async {
    // Verificar preferencia guardada
    final preference = await MapsPreferenceService.getPreference();

    if (preference != null) {
      // Ya tiene preferencia — abrir directamente
      await _launchWithPreference(
        preference: preference,
        title: title,
        query: query,
        latitude: latitude,
        longitude: longitude,
      );
    } else {
      // Primera vez — mostrar picker
      if (context.mounted) {
        await _showMapPicker(
          context: context,
          title: title,
          query: query,
          latitude: latitude,
          longitude: longitude,
        );
      }
    }
  }

  static Future<void> _launchWithPreference({
    required MapApp preference,
    required String title,
    required String query,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final availableMaps = await MapLauncher.installedMaps;

      if (availableMaps.isEmpty) {
        await _launchUrl(query, latitude, longitude);
        return;
      }

      AvailableMap? selectedMap;

      switch (preference) {
        case MapApp.googleMaps:
          selectedMap = availableMaps.firstWhere(
                (m) => m.mapType == MapType.google,
            orElse: () => availableMaps.first,
          );
          break;
        case MapApp.appleMaps:
          selectedMap = availableMaps.firstWhere(
                (m) => m.mapType == MapType.apple,
            orElse: () => availableMaps.first,
          );
          break;
        case MapApp.waze:
          selectedMap = availableMaps.firstWhere(
                (m) => m.mapType == MapType.waze,
            orElse: () => availableMaps.first,
          );
          break;
        case MapApp.systemDefault:
          await _launchUrl(query, latitude, longitude);
          return;
      }

      if (latitude != null && longitude != null) {
        await selectedMap.showMarker(
          coords: Coords(latitude, longitude),
          title: title,
        );
      } else {
        await selectedMap.showDirections(
          destination: Coords(0, 0),
          destinationTitle: query,
        );
      }
    } catch (e) {
      await _launchUrl(query, latitude, longitude);
    }
  }

  static Future<void> _showMapPicker({
    required BuildContext context,
    required String title,
    required String query,
    double? latitude,
    double? longitude,
  }) async {
    final availableMaps = await MapLauncher.installedMaps;

    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _MapPickerSheet(
        availableMaps: availableMaps,
        title: title,
        query: query,
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }

  static Future<void> _launchUrl(
      String query,
      double? latitude,
      double? longitude,
      ) async {
    final url = latitude != null && longitude != null
        ? 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude'
        : 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}';

    // Usar url_launcher como fallback
    final uri = Uri.parse(url);
    // ignore: deprecated_member_use
    await launchUrl(uri);
  }
}

class _MapPickerSheet extends StatelessWidget {
  final List<AvailableMap> availableMaps;
  final String title;
  final String query;
  final double? latitude;
  final double? longitude;

  const _MapPickerSheet({
    required this.availableMaps,
    required this.title,
    required this.query,
    this.latitude,
    this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(context.tr('open_with'), style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(
            context.tr('choose_maps_app'),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),

          const SizedBox(height: 24),

          // Available maps
          ...availableMaps.map((map) => _MapOption(
            map: map,
            onTap: () async {
              // Guardar preferencia
              MapApp preference = MapApp.systemDefault;
              if (map.mapType == MapType.google) {
                preference = MapApp.googleMaps;
              } else if (map.mapType == MapType.apple) {
                preference = MapApp.appleMaps;
              } else if (map.mapType == MapType.waze) {
                preference = MapApp.waze;
              }

              await MapsPreferenceService.savePreference(preference);
              Navigator.pop(context);

              // Abrir el mapa
              if (latitude != null && longitude != null) {
                await map.showMarker(
                  coords: Coords(latitude!, longitude!),
                  title: title,
                );
              } else {
                await map.showMarker(
                  coords: Coords(0, 0),
                  title: query,
                );
              }
            },
          )),

          const SizedBox(height: 12),

          // Opción "siempre preguntar"
          TextButton(
            onPressed: () {
              MapsPreferenceService.savePreference(MapApp.systemDefault);
              Navigator.pop(context);
            },
            child: Text(
              context.tr('always_ask'),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapOption extends StatelessWidget {
  final AvailableMap map;
  final VoidCallback onTap;

  const _MapOption({
    required this.map,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            // Map icon
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.explore,
                  size: 22,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ),

            const SizedBox(width: 16),

            Text(
              map.mapName,
              style: AppTextStyles.bodyMedium,
            ),

            const Spacer(),

            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textTertiary(context),
            ),
          ],
        ),
      ),
    );
  }
}