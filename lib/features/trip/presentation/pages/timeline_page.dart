import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/trip_provider.dart';
import '../providers/activities_provider.dart';
import '../widgets/day_section.dart';

class TimelinePage extends ConsumerWidget {
  final String tripId;
  final String userId;
  final bool isReadOnly;

  const TimelinePage({
    super.key,
    required this.tripId,
    required this.userId,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysAsync = ref.watch(tripDaysProvider(tripId));
    final activitiesAsync = ref.watch(tripActivitiesProvider(tripId));

    return daysAsync.when(
      data: (days) {
        if (days.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🗺️', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text('No days yet', style: AppTextStyles.h4),
                  const SizedBox(height: 8),
                  Text(
                    'This trip has no days configured yet',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ColoredBox(
          color: AppColors.background(context),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Progress bar global
                activitiesAsync.when(
                  data: (activities) {
                    if (activities.isEmpty) const SizedBox.shrink();
                    return _TimelineProgressBar(activities: activities);
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // Days
                ...days.map((day) => DaySection(
                  day: day,
                  tripId: tripId,
                  userId: userId,
                  allDays: days,
                  isReadOnly: isReadOnly,
                )),

                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Error: $e', style: AppTextStyles.bodySmall),
      ),
    );
  }
}

// ✅ Progress bar global del timeline
class _TimelineProgressBar extends StatelessWidget {
  final List<dynamic> activities;

  const _TimelineProgressBar({required this.activities});

  @override
  Widget build(BuildContext context) {
    final total = activities.length;
    final done = activities.where((a) => a.isCompleted).length;
    final progress = total == 0 ? 0.0 : done / total;
    final allDone = done == total && total > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                allDone ? 'All done! 🎉' : '$done of $total done',
                style: AppTextStyles.labelSmall.copyWith(
                  color: allDone
                      ? AppColors.success
                      : AppColors.textTertiary(context),
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.card(context),
              valueColor: AlwaysStoppedAnimation(
                allDone ? AppColors.success : AppColors.primary,
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

final tripDaysProvider = StreamProvider.family<List<dynamic>, String>(
      (ref, tripId) {
    final repository = ref.watch(tripRepositoryProvider);
    return repository.getTripDays(tripId);
  },
);