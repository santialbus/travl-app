import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/activity_entity.dart';
import '../../domain/entities/day_entity.dart';
import '../providers/activities_provider.dart';
import '../providers/permissions_provider.dart';
import 'activity_card.dart';
import 'add_activity_bottom_sheet.dart';

class DaySection extends ConsumerWidget {
  final DayEntity day;
  final String tripId;
  final String userId;
  final List<dynamic> allDays;
  final bool isReadOnly;

  const DaySection({
    super.key,
    required this.day,
    required this.tripId,
    required this.userId,
    required this.allDays,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(dayActivitiesProvider(day.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DaySeparator(day: day),
        activitiesAsync.when(
          data: (activities) => _DayActivities(
            day: day,
            activities: activities,
            tripId: tripId,
            userId: userId,
            allDays: allDays,
            isReadOnly: isReadOnly,
          ),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('${context.tr('error_generic')}: ${e.toString()}',
                style: AppTextStyles.bodySmall),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _DayActivities extends ConsumerWidget {
  final DayEntity day;
  final List<ActivityEntity> activities;
  final String tripId;
  final String userId;
  final List<dynamic> allDays;
  final bool isReadOnly;

  const _DayActivities({
    required this.day,
    required this.activities,
    required this.tripId,
    required this.userId,
    required this.allDays,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(currentMemberProvider(tripId));
    final canAdd = (member?.canAddActivities ?? false) && !isReadOnly;
    return Column(
      children: [
        // ✅ ReorderableListView para drag & drop
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          // ✅ Handle visible a la izquierda
          buildDefaultDragHandles: false,
          onReorder: (oldIndex, newIndex) async {
            if (!canAdd) return;

            if (oldIndex < newIndex) newIndex--;

            final reordered = List<ActivityEntity>.from(activities);
            final item = reordered.removeAt(oldIndex);
            reordered.insert(newIndex, item);

            await ref
                .read(activityControllerProvider.notifier)
                .reorderActivitiesInDay(
                  day.id,
                  reordered.map((a) => a.id).toList(),
                );
          },
          itemBuilder: (context, index) {
            final activity = activities[index];
            return _DraggableActivityRow(
              key: Key(activity.id),
              activity: activity,
              index: index,
              tripId: tripId,
              dayId: day.id,
              userId: userId,
              allDays: [], // Se pasa desde TimelinePage
            );
          },
        ),

        // Add activity button
        if (canAdd)
          _AddActivityRow(
            onTap: () => _showAddActivitySheet(context, ref),
          ),
      ],
    );
  }

  void _showAddActivitySheet(BuildContext context, WidgetRef ref) async {
    final isOnline = ref.read(isOnlineProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddActivityBottomSheet(
        tripId: tripId,
        dayId: day.id,
        userId: userId,
        isOffline: !isOnline, // ✅ Pasar estado offline
      ),
    );
  }
}

// ✅ Row con handle de arrastre + ActivityCard
class _DraggableActivityRow extends ConsumerWidget {
  final ActivityEntity activity;
  final int index;
  final String tripId;
  final String dayId;
  final String userId;
  final List<dynamic> allDays;

  const _DraggableActivityRow({
    super.key,
    required this.activity,
    required this.index,
    required this.tripId,
    required this.dayId,
    required this.userId,
    required this.allDays,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(currentMemberProvider(tripId));
    final canEdit = member?.canEditActivities ?? false;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ✅ Handle — tap para mover entre días, drag para reordenar
        GestureDetector(
          onLongPress: allDays.isNotEmpty
              ? () => _showMoveToDaySheet(context, ref)
              : null,
          child: canEdit
              ? ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 4),
                    child: Tooltip(
                      message: context.tr('drag_reorder_move'),
                      child: Icon(
                        Icons.drag_handle,
                        size: 20,
                        color: AppColors.textTertiary(context)
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                )
              : const SizedBox(width: 32),
        ),

        // Activity card
        Expanded(
          child: ActivityCard(
            activity: activity,
            tripId: tripId,
            dayId: dayId,
            userId: userId,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  void _showMoveToDaySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _MoveToDaySheet(
        activity: activity,
        currentDayId: dayId,
        allDays: allDays,
        onMove: (targetDayId) async {
          Navigator.pop(context);

          // Obtener el número de actividades en el día destino
          final targetActivities = await ref
              .read(activityDataSourceProvider)
              .getDayActivities(targetDayId)
              .first;

          await ref.read(activityControllerProvider.notifier).moveActivityToDay(
                activity.id,
                targetDayId,
                targetActivities.length,
              );
        },
      ),
    );
  }
}

class _MoveToDaySheet extends StatelessWidget {
  final ActivityEntity activity;
  final String currentDayId;
  final List<dynamic> allDays;
  final Function(String dayId) onMove;

  const _MoveToDaySheet({
    required this.activity,
    required this.currentDayId,
    required this.allDays,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    // Filtrar el día actual
    final otherDays = allDays.where((d) => d.id != currentDayId).toList();

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

          Text(context.tr('move_to_day'), style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text(
            activity.title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),

          const SizedBox(height: 20),

          if (otherDays.isEmpty)
            Center(
              child: Text(
                context.tr('no_other_days'),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            )
          else
            ...otherDays.map((day) {
              final dateStr =
                  DateFormat('MMM dd').format(day.date).toUpperCase();

              return InkWell(
                onTap: () => onMove(day.id),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 4,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${day.dayNumber}',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              day.title,
                              style: AppTextStyles.bodyMedium,
                            ),
                            Text(
                              dateStr,
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
            }),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Day separator
class _DaySeparator extends StatelessWidget {
  final DayEntity day;

  const _DaySeparator({required this.day});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM dd').format(day.date).toUpperCase();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        children: [
          Text(
            context.tr(
              'day_header',
              params: {
                'title': day.title.toUpperCase(),
                'date': dateStr,
              },
            ),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textTertiary(context),
              letterSpacing: 1.2,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// Add activity row
class _AddActivityRow extends StatelessWidget {
  final VoidCallback onTap;

  const _AddActivityRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            const SizedBox(width: 36),
            Icon(
              Icons.add,
              size: 16,
              color: AppColors.textTertiary(context),
            ),
            const SizedBox(width: 12),
            Text(
              context.tr('add_activity'),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
