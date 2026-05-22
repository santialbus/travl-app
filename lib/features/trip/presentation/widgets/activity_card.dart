import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/activity_entity.dart';
import '../providers/activities_provider.dart';

class ActivityCard extends ConsumerWidget {
  final ActivityEntity activity;
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = AppColors.getActivityColor(activity.type.value);

    return Dismissible(
      key: Key(activity.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            title: Text('Delete activity?', style: AppTextStyles.h4),
            content: Text(
              activity.title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
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
        ref
            .read(activityControllerProvider.notifier)
            .deleteActivity(activity.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error.withOpacity(0.15),
        child: Icon(Icons.delete_outline, color: AppColors.error),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji icon con fondo sutil
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
                    // Title + completed
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            activity.title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: activity.isCompleted
                                  ? AppColors.textTertiary
                                  : AppColors.textPrimary,
                              decoration: activity.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Time + location
                    if (activity.time != null || activity.locationName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            if (activity.time != null) ...[
                              Text(
                                AppDateUtils.formatTime(activity.time!),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              if (activity.locationName != null)
                                Text(
                                  '  ·  ',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                            ],
                            if (activity.locationName != null)
                              Expanded(
                                child: Text(
                                  activity.locationName!,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textTertiary,
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

              // Right side actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Maps icon
                  if (activity.mapsUrl != null)
                    GestureDetector(
                      onTap: () => _openMaps(activity.mapsUrl!),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.map_outlined,
                          size: 18,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),

                  const SizedBox(width: 4),

                  // Complete toggle
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(activityControllerProvider.notifier)
                          .toggleCompletion(
                        activity.id,
                        !activity.isCompleted,
                      );
                    },
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: activity.isCompleted
                              ? color
                              : AppColors.textTertiary.withOpacity(0.4),
                          width: 1.5,
                        ),
                        color: activity.isCompleted
                            ? color.withOpacity(0.2)
                            : Colors.transparent,
                      ),
                      child: activity.isCompleted
                          ? Icon(
                        Icons.check,
                        size: 13,
                        color: color,
                      )
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

  Future<void> _openMaps(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}