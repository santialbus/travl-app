import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/trip_provider.dart';
import '../widgets/day_section.dart';

class TimelinePage extends ConsumerWidget {
  final String tripId;

  const TimelinePage({
    super.key,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysAsync = ref.watch(tripDaysProvider(tripId));

    return daysAsync.when(
      data: (days) {
        if (days.isEmpty) {
          return Center(
            child: Text(
              'No days yet',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          );
        }

        // ✅ Añadir color de fondo adaptativo
        return ColoredBox(
          color: AppColors.background(context),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...days.map((day) => DaySection(
                  day: day,
                  tripId: tripId,
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

final tripDaysProvider = StreamProvider.family<List<dynamic>, String>(
      (ref, tripId) {
    final repository = ref.watch(tripRepositoryProvider);
    return repository.getTripDays(tripId);
  },
);
