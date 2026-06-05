import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/maps_launcher_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/activity_entity.dart';
import '../providers/activities_provider.dart';
import 'add_activity_bottom_sheet.dart';

class ActivityCard extends ConsumerWidget {
  final ActivityEntity activity;
  final String tripId;
  final String dayId;
  final String userId;
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.tripId,
    required this.dayId,
    required this.userId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = AppColors.getActivityColor(activity.type.value);

    return Dismissible(
      key: Key(activity.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error.withOpacity(0.15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: AppColors.error, size: 20),
            const SizedBox(height: 4),
            Text(
              'Delete',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.error,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface(context),
            title: Text('Delete activity?', style: AppTextStyles.h4),
            content: Text(
              activity.title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Delete',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        ref.read(activityControllerProvider.notifier).deleteActivity(activity.id);
      },
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showEditSheet(context, ref),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    activity.emoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: activity.isCompleted
                            ? AppColors.textTertiary(context)
                            : AppColors.textPrimary(context),
                        decoration: activity.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (_hasSecondaryInfo())
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Línea 1: time + location
                            if (activity.time != null || activity.locationName != null)
                              Row(
                                children: [
                                  if (activity.time != null) ...[
                                    Text(
                                      AppDateUtils.formatTime(activity.time!),
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.textTertiary(context),
                                      ),
                                    ),
                                    if (activity.locationName != null)
                                      Text(
                                        '  ·  ',
                                        style: AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.textTertiary(context),
                                        ),
                                      ),
                                  ],
                                  if (activity.locationName != null)
                                    Expanded(
                                      child: Text(
                                        activity.locationName!,
                                        style: AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.textTertiary(context),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),

                            // Línea 2: dato contextual por tipo
                            if (_getSecondaryLabel() != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  _getSecondaryLabel()!,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textTertiary(context),
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Right actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Maps
                  if (activity.mapsUrl != null)
                    GestureDetector(
                      onTap: () => _openMaps(context, activity.mapsUrl!),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.map_outlined,
                          size: 18,
                          color: AppColors.textTertiary(context),
                        ),
                      ),
                    ),

                  // Flight tracker
                  if (activity.type == ActivityType.flight &&
                      activity.flightNumber != null)
                    GestureDetector(
                      onTap: () => _showFlightTrackerOptions(context),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.radar,
                          size: 18,
                          color: AppColors.flightColor,
                        ),
                      ),
                    ),

                  // Train tracker
                  if (activity.type == ActivityType.transport &&
                      activity.trainNumber != null)
                    GestureDetector(
                      onTap: () => _openTrainTracker(context),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.train,
                          size: 18,
                          color: AppColors.transportColor,
                        ),
                      ),
                    ),

                  const SizedBox(width: 4),

                  // Edit
                  GestureDetector(
                    onTap: () => _showEditSheet(context, ref),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.textTertiary(context),
                      ),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // Complete toggle
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(activityControllerProvider.notifier)
                          .toggleCompletion(activity.id, !activity.isCompleted);
                    },
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: activity.isCompleted
                              ? color
                              : AppColors.textTertiary(context).withOpacity(0.4),
                          width: 1.5,
                        ),
                        color: activity.isCompleted
                            ? color.withOpacity(0.2)
                            : Colors.transparent,
                      ),
                      child: activity.isCompleted
                          ? Icon(Icons.check, size: 13, color: color)
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasSecondaryInfo() {
    return activity.time != null ||
        activity.locationName != null ||
        activity.flightNumber != null ||
        activity.trainNumber != null ||
        (activity.bookingReference != null) ||
        (activity.description != null && activity.description!.isNotEmpty);
  }

  String? _getSecondaryLabel() {
    if (activity.type == ActivityType.flight && activity.flightNumber != null) {
      return '✈️ ${activity.flightNumber}';
    }
    if (activity.type == ActivityType.transport && activity.trainNumber != null) {
      return '🚆 ${activity.trainNumber}';
    }
    if (activity.type == ActivityType.hotel && activity.bookingReference != null) {
      return '🏨 ${activity.bookingReference}';
    }
    if (activity.description != null && activity.description!.isNotEmpty) {
      return '📝 ${activity.description}';
    }
    return null;
  }

  void _showEditSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddActivityBottomSheet(
        tripId: tripId,
        dayId: dayId,
        userId: userId,
        activityToEdit: activity,
      ),
    );
  }

  Future<void> _openMaps(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final query = uri.queryParameters['query'] ?? '';
    await MapsLauncherService.openMap(
      context: context,
      title: activity.title,
      query: query,
      latitude: activity.latitude,
      longitude: activity.longitude,
    );
  }

  void _showFlightTrackerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            Text('Track Flight ${activity.flightNumber}', style: AppTextStyles.h3),
            const SizedBox(height: 20),
            _TrackerOption(
              emoji: '📡',
              name: 'FlightRadar24',
              description: 'Real-time flight tracking',
              onTap: () {
                Navigator.pop(context);
                _openUrl('https://www.flightradar24.com/${activity.flightNumber}');
              },
            ),
            const SizedBox(height: 12),
            _TrackerOption(
              emoji: '✈️',
              name: 'FlightAware',
              description: 'Flight status & tracking',
              onTap: () {
                Navigator.pop(context);
                _openUrl('https://www.flightaware.com/live/flight/${activity.flightNumber}');
              },
            ),
            const SizedBox(height: 12),
            _TrackerOption(
              emoji: '🔍',
              name: 'Google Flights',
              description: 'Check flight status',
              onTap: () {
                Navigator.pop(context);
                _openUrl('https://www.google.com/travel/flights?q=${activity.flightNumber}');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _openTrainTracker(BuildContext context) async {
    final company = activity.transportCompany?.toLowerCase() ?? '';
    String url;
    if (company.contains('renfe')) {
      url = 'https://www.renfe.com/es/es/viajar/informacion-al-viajero/estado-del-tren';
    } else if (company.contains('ouigo')) {
      url = 'https://www.ouigo.com/es/informacion-viaje';
    } else {
      url = 'https://www.thetrainline.com/train-times/${activity.trainNumber ?? ''}';
    }
    await _openUrl(url);
  }

  Future<void> _openUrl(String url) async {
    String finalUrl = url;
    if (!url.startsWith('http')) finalUrl = 'https://$url';
    final uri = Uri.parse(finalUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _TrackerOption extends StatelessWidget {
  final String emoji;
  final String name;
  final String description;
  final VoidCallback onTap;

  const _TrackerOption({
    required this.emoji,
    required this.name,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.bodyMedium),
                  Text(
                    description,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary(context),
                    ),
                  ),
                ],
              ),
            ),
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
