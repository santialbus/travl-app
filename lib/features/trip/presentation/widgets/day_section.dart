import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/day_entity.dart';
import '../providers/activities_provider.dart';
import 'activity_card.dart';
import 'add_activity_bottom_sheet.dart';

class DaySection extends ConsumerWidget {
  final DayEntity day;
  final String tripId;
  final String userId; // ✅ Añadido

  const DaySection({
    super.key,
    required this.day,
    required this.tripId,
    required this.userId, // ✅ Añadido
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(dayActivitiesProvider(day.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DaySeparator(day: day),

        activitiesAsync.when(
          data: (activities) {
            return Column(
              children: [
                ...activities.map((activity) => ActivityCard(
                  activity: activity,
                  tripId: tripId,       // ✅ Añadido
                  dayId: day.id,        // ✅ Añadido
                  userId: userId,       // ✅ Añadido
                  onTap: () {},
                )),

                _AddActivityRow(
                  onTap: () => _showAddActivitySheet(context, ref),
                ),
              ],
            );
          },
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
            child: Text('Error: $e', style: AppTextStyles.bodySmall),
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  void _showAddActivitySheet(BuildContext context, WidgetRef ref) async {
    // ✅ Ya tenemos userId, no necesitamos leerlo de currentUserProvider
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
        userId: userId, // ✅ Directo
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
            '${day.title.toUpperCase()} · $dateStr',
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
              'Add activity',
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