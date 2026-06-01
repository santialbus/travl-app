import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/widgets/offline_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../trip/presentation/providers/trip_provider.dart';
import '../../../trip/domain/entities/trip_entity.dart';
import '../../../trip/presentation/widgets/edit_trip_bottom_sheet.dart';
import '../../presentation/widgets/join_trip_dialog.dart';

class TripsTab extends ConsumerWidget {
  final String userId;

  const TripsTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(userTripsProvider(userId));
    final authAsync = ref.watch(authStateProvider);

    final userName = authAsync.maybeWhen(
      data: (user) => user?.name ?? '',
      orElse: () => '',
    );

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Travl ✈️',
                          style: AppTextStyles.h1.copyWith(fontSize: 36),
                        ),
                        const SizedBox(width: 12),
                        const OfflineIndicator(),
                        const Spacer(),
                        IconButton(
                          onPressed: () => _showJoinDialog(context, ref),
                          icon: const Icon(Icons.qr_code_scanner),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.card(context),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getGreeting(userName),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Trips Content
            tripsAsync.when(
              data: (trips) {
                if (trips.isEmpty) {
                  return SliverFillRemaining(
                    child: _EmptyTrips(
                      onCreateTrip: () => context.push(RouteConstants.createTrip),
                      onJoinTrip: () => _showJoinDialog(context, ref),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: _TripCard(
                          trip: trips[index],
                          userId: userId,
                          onTap: () => context.go('/trip/${trips[index].id}'),
                        ),
                      );
                    },
                    childCount: trips.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
      /*floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteConstants.createTrip),
        icon: const Icon(Icons.add),
        label: const Text('New Trip'),
      ),*/
    );
  }

  String _getGreeting(String name) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
        ? 'Good afternoon'
        : 'Good evening';
    return name.isNotEmpty ? '$greeting, $name 👋' : '$greeting 👋';
  }

  void _showJoinDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => JoinTripDialog(userId: userId),
    );
  }
}

class _TripCard extends ConsumerWidget {
  final TripEntity trip;
  final String userId;
  final VoidCallback onTap;

  const _TripCard({
    required this.trip,
    required this.userId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOwner = trip.ownerId == userId;
    final isOngoing = trip.startDate.isBefore(DateTime.now()) &&
        trip.endDate.isAfter(DateTime.now());
    final isUpcoming = trip.startDate.isAfter(DateTime.now());

    // Solo el host puede borrar — swipe solo si es owner
    if (!isOwner) {
      return _TripCardContent(
        trip: trip,
        isDark: isDark,
        isOngoing: isOngoing,
        isUpcoming: isUpcoming,
        onTap: onTap,
      );
    }

    return Dismissible(
    key: Key(trip.id),
    direction: DismissDirection.horizontal, // ✅ Ambas direcciones

    // ✅ Fondo azul — swipe derecha (editar)
    background: Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_outlined, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(
            'Edit',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    ),

    // ✅ Fondo rojo — swipe izquierda (borrar) — solo si es owner
    secondaryBackground: isOwner
        ? Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline, color: AppColors.error),
          const SizedBox(height: 4),
          Text(
            'Delete',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ),
    )
        : const SizedBox.shrink(),

    confirmDismiss: (direction) async {
      if (direction == DismissDirection.startToEnd) {
        // ✅ Swipe derecha — editar
        Future.delayed(Duration.zero, () {
          if (context.mounted) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: AppColors.surface(context),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => EditTripBottomSheet(trip: trip),
            );
          }
        });
        return false;
      }

      // ✅ Swipe izquierda — borrar (solo owner)
      if (!isOwner) return false;

      return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface(context),
          title: Text('Delete trip?', style: AppTextStyles.h4),
          content: Text(
            'This will permanently delete "${trip.name}" and all its data.',
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

    onDismissed: (direction) async {
      if (direction == DismissDirection.endToStart && isOwner) {
        await ref.read(tripControllerProvider.notifier).deleteTrip(trip.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${trip.name} deleted'),
              backgroundColor: AppColors.surface(context),
            ),
          );
        }
      }
    },

    child: _TripCardContent(
      trip: trip,
      isDark: isDark,
      isOngoing: isOngoing,
      isUpcoming: isUpcoming,
      onTap: onTap,
    ),
    );
  }
}

// Contenido visual de la card (separado para reusar)
class _TripCardContent extends StatelessWidget {
  final TripEntity trip;
  final bool isDark;
  final bool isOngoing;
  final bool isUpcoming;
  final VoidCallback onTap;

  const _TripCardContent({
    required this.trip,
    required this.isDark,
    required this.isOngoing,
    required this.isUpcoming,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.card(context) : AppColors.cardLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: isOngoing
              ? Border.all(
            color: AppColors.primary.withOpacity(0.4),
            width: 1.5,
          )
              : null,
          boxShadow: isDark
              ? null
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status + Members
              Row(
                children: [
                  _StatusBadge(
                    isOngoing: isOngoing,
                    isUpcoming: isUpcoming,
                  ),
                  const Spacer(),
                  _MemberAvatars(count: trip.members.length),
                ],
              ),

              const SizedBox(height: 16),

              // Destination
              Text(
                trip.destination,
                style: AppTextStyles.h3.copyWith(
                  fontSize: 22,
                  color: isDark
                      ? AppColors.textPrimary(context)
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                trip.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondary(context)
                      : AppColors.textSecondaryLight,
                ),
              ),

              const SizedBox(height: 16),

              // Dates
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: isDark
                        ? AppColors.textTertiary(context)
                        : AppColors.textTertiaryLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${DateFormat('MMM dd').format(trip.startDate)} → ${DateFormat('MMM dd, yyyy').format(trip.endDate)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondary(context)
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${trip.numberOfDays} days',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
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
}

class _StatusBadge extends StatelessWidget {
  final bool isOngoing;
  final bool isUpcoming;

  const _StatusBadge({required this.isOngoing, required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    if (isOngoing) {
      bgColor = AppColors.primary.withOpacity(0.15);
      textColor = AppColors.primary;
      label = 'Ongoing';
    } else if (isUpcoming) {
      bgColor = AppColors.success.withOpacity(0.15);
      textColor = AppColors.success;
      label = 'Upcoming';
    } else {
      bgColor = AppColors.textTertiary(context).withOpacity(0.15);
      textColor = AppColors.textTertiary(context);
      label = 'Past';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOngoing) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}

class _MemberAvatars extends StatelessWidget {
  final int count;

  const _MemberAvatars({required this.count});

  @override
  Widget build(BuildContext context) {
    final displayCount = count > 3 ? 3 : count;

    return Row(
      children: [
        ...List.generate(displayCount, (i) {
          return Transform.translate(
            offset: Offset(i * -8.0, 0),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3 + i * 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.card(context), width: 2),
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  size: 14,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        }),
        if (count > 3)
          Transform.translate(
            offset: const Offset(-24, 0),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.card(context), width: 2),
              ),
              child: Center(
                child: Text(
                  '+${count - 3}',
                  style: AppTextStyles.labelSmall.copyWith(fontSize: 9),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyTrips extends StatelessWidget {
  final VoidCallback onCreateTrip;
  final VoidCallback onJoinTrip;

  const _EmptyTrips({
    required this.onCreateTrip,
    required this.onJoinTrip,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✈️', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 24),
            Text('No trips yet', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'Create your first trip or join\nan existing one with a code',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: onCreateTrip,
                icon: const Icon(Icons.add),
                label: const Text('Create Trip'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onJoinTrip,
              icon: const Icon(Icons.group_add),
              label: const Text('Join with code'),
            ),
          ],
        ),
      ),
    );
  }
}