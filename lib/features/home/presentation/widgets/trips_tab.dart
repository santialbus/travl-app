import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:travl/features/notifications/presentation/pages/notifications_page.dart';
import 'package:travl/features/notifications/presentation/providers/notification_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/widgets/offline_indicator.dart';
import '../../../../core/widgets/pulsing_dot.dart';
import '../../../../core/localization/app_strings.dart';
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
    final notifications = ref.watch(notificationControllerProvider(userId));

    final unreadCount =
        notifications.where((notification) => !notification.isRead).length;

    final userName = authAsync.maybeWhen(
      data: (user) => user?.name ?? '',
      orElse: () => '',
    );

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
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
                        // NOTIFICACIONES
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        NotificationsPage(userId: userId),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.notifications_outlined),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.card(context),
                                padding: const EdgeInsets.all(12),
                              ),
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                right: 5,
                                top: 5,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      unreadCount > 99 ? '99+' : '$unreadCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(width: 8),
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
                      _getGreeting(userName, ref),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            tripsAsync.when(
              data: (trips) {
                if (trips.isEmpty) {
                  return SliverFillRemaining(
                    child: _EmptyTrips(
                      onCreateTrip: () =>
                          context.push(RouteConstants.createTrip),
                      onJoinTrip: () => _showJoinDialog(context, ref),
                    ),
                  );
                }
                return SliverToBoxAdapter(
                  child: _TripsList(trips: trips, userId: userId),
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
    );
  }

  String _getGreeting(String name, WidgetRef ref) {
    final hour = DateTime.now().hour;
    final key = hour < 12
        ? 'good_morning'
        : hour < 18
            ? 'good_afternoon'
            : 'good_evening';
    final greeting = ref.tr(key);
    return name.isNotEmpty ? '$greeting, $name 👋' : '$greeting 👋';
  }

  void _showJoinDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => JoinTripDialog(userId: userId),
    );
  }
}

// ─── TRIPS LIST ───────────────────────────────────────────────────────────────

class _TripsList extends StatefulWidget {
  final List<TripEntity> trips;
  final String userId;

  const _TripsList({required this.trips, required this.userId});

  @override
  State<_TripsList> createState() => _TripsListState();
}

class _TripsListState extends State<_TripsList> {
  late List<TripEntity> _trips;

  @override
  void initState() {
    super.initState();
    _trips = List.from(widget.trips);
  }

  @override
  void didUpdateWidget(covariant _TripsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trips != widget.trips) {
      _trips = List.from(widget.trips);
    }
  }

  void _removeTrip(String id) {
    setState(() {
      _trips.removeWhere((t) => t.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final archiveThreshold = now.subtract(const Duration(days: 5));

    final ongoing = _trips
        .where((t) => t.startDate.isBefore(now) && t.endDate.isAfter(now))
        .toList();

    final upcoming = _trips.where((t) => t.startDate.isAfter(now)).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final recent = _trips
        .where((t) =>
            t.endDate.isBefore(now) && t.endDate.isAfter(archiveThreshold))
        .toList()
      ..sort((a, b) => b.endDate.compareTo(a.endDate));

    final archived = _trips
        .where((t) => t.endDate.isBefore(archiveThreshold))
        .toList()
      ..sort((a, b) => b.endDate.compareTo(a.endDate));

    final activeTrips = [...ongoing, ...upcoming, ...recent];

    return Column(
      children: [
        ...activeTrips.map((trip) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _TripCard(
                trip: trip,
                userId: widget.userId,
                onTap: () => context.go('/trip/${trip.id}'),
                onDeleted: () => _removeTrip(trip.id),
              ),
            )),
        if (archived.isNotEmpty) ...[
          const SizedBox(height: 8),
          _ArchivedSection(
            trips: archived,
            userId: widget.userId,
            onDeleted: _removeTrip, // ✅ fix
          ),
        ],
        const SizedBox(height: 100),
      ],
    );
  }
}

// ─── ARCHIVED SECTION ─────────────────────────────────────────────────────────

class _ArchivedSection extends ConsumerStatefulWidget {
  final List<TripEntity> trips;
  final String userId;
  final void Function(String tripId) onDeleted; // ✅ añadido

  const _ArchivedSection({
    required this.trips,
    required this.userId,
    required this.onDeleted,
  });

  @override
  ConsumerState<_ArchivedSection> createState() => _ArchivedSectionState();
}

class _ArchivedSectionState extends ConsumerState<_ArchivedSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.archive_outlined,
                    size: 16,
                    color: AppColors.textTertiary(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ref.tr('archived'),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary(context),
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary(context)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${widget.trips.length}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiary(context),
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppColors.textTertiary(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _expanded
                ? Column(
                    children: widget.trips
                        .map((trip) => Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: _TripCard(
                                trip: trip,
                                userId: widget.userId,
                                onTap: () => context
                                    .go('/trip/${trip.id}?readOnly=true'),
                                isArchived: true,
                                onDeleted: () => widget.onDeleted(trip.id),
                              ),
                            ))
                        .toList(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─── TRIP CARD ────────────────────────────────────────────────────────────────

class _TripCard extends ConsumerWidget {
  final TripEntity trip;
  final String userId;
  final VoidCallback onTap;
  final bool isArchived;
  final VoidCallback? onDeleted;

  const _TripCard({
    required this.trip,
    required this.userId,
    required this.onTap,
    this.isArchived = false,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOwner = trip.ownerId == userId;
    final now = DateTime.now();
    final isOngoing = trip.startDate.isBefore(now) && trip.endDate.isAfter(now);
    final isUpcoming = trip.startDate.isAfter(now);

    return Dismissible(
      key: ValueKey(trip.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_outlined, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(ref.tr('edit'),
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.primary)),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isOwner ? Icons.delete_outline : Icons.exit_to_app,
                color: AppColors.error),
            const SizedBox(height: 4),
            Text(isOwner ? ref.tr('delete') : ref.tr('leave'),
                style:
                    AppTextStyles.labelSmall.copyWith(color: AppColors.error)),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (!isOwner) return false;
          HapticFeedback.selectionClick();
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

        if (isOwner) {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.surface(context),
              title: Text(ref.tr('delete_trip_q'), style: AppTextStyles.h4),
              content: Text(
                ref.tr('delete_trip_desc', params: {'name': trip.name}),
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary(context)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(ref.tr('cancel')),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(ref.tr('delete'),
                      style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          );
        } else {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.surface(context),
              title: Text(ref.tr('leave_trip_q'), style: AppTextStyles.h4),
              content: Text(
                ref.tr('leave_trip_desc', params: {'name': trip.name}),
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary(context)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(ref.tr('cancel')),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(ref.tr('leave'),
                      style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          );
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          HapticFeedback.mediumImpact();
          onDeleted?.call();
          if (isOwner) {
            ref.read(tripControllerProvider.notifier).deleteTrip(trip.id);
            if (context.mounted)
              showBottomSnackBar(
                  context, ref.tr('trip_deleted', params: {'name': trip.name}));
          } else {
            ref
                .read(tripControllerProvider.notifier)
                .leaveTrip(trip.id, userId);
            if (context.mounted)
              showBottomSnackBar(
                  context, ref.tr('left_trip', params: {'name': trip.name}));
          }
        }
      },
      child: _TripCardContent(
        trip: trip,
        isDark: isDark,
        isOngoing: isOngoing,
        isUpcoming: isUpcoming,
        isArchived: isArchived,
        onTap: onTap,
      ),
    );
  }
}

// ─── TRIP CARD CONTENT ────────────────────────────────────────────────────────

class _TripCardContent extends StatefulWidget {
  final TripEntity trip;
  final bool isDark;
  final bool isOngoing;
  final bool isUpcoming;
  final bool isArchived;
  final VoidCallback onTap;

  const _TripCardContent({
    required this.trip,
    required this.isDark,
    required this.isOngoing,
    required this.isUpcoming,
    required this.isArchived,
    required this.onTap,
  });

  @override
  State<_TripCardContent> createState() => _TripCardContentState();
}

class _TripCardContentState extends State<_TripCardContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.isOngoing) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardColor =
        widget.isDark ? AppColors.card(context) : AppColors.cardLight;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          final glowOpacity =
              widget.isOngoing ? 0.2 + (_pulseAnim.value * 0.35) : 0.0;
          final glowSpread =
              widget.isOngoing ? 0.0 + (_pulseAnim.value * 4.0) : 0.0;
          final glowBlur =
              widget.isOngoing ? 8.0 + (_pulseAnim.value * 12.0) : 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: widget.isArchived
                  ? cardColor.withValues(alpha: 0.5)
                  : cardColor,
              borderRadius: BorderRadius.circular(20),
              border: widget.isOngoing
                  ? Border.all(
                      color: AppColors.primary
                          .withValues(alpha: 0.5 + _pulseAnim.value * 0.3),
                      width: 1.5,
                    )
                  : widget.isArchived
                      ? Border.all(
                          color: AppColors.borderColor(context)
                              .withValues(alpha: 0.4),
                          width: 1,
                        )
                      : null,
              boxShadow: [
                if (!widget.isDark && !widget.isArchived)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                if (widget.isOngoing)
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: glowOpacity),
                    blurRadius: glowBlur,
                    spreadRadius: glowSpread,
                  ),
              ],
            ),
            child: child,
          );
        },
        child: Opacity(
          opacity: widget.isArchived ? 0.65 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _StatusBadge(
                      isOngoing: widget.isOngoing,
                      isUpcoming: widget.isUpcoming,
                      isArchived: widget.isArchived,
                    ),
                    const Spacer(),
                    _MemberAvatars(count: widget.trip.members.length),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.trip.destination,
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 22,
                    color: widget.isDark
                        ? AppColors.textPrimary(context)
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.trip.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: widget.isDark
                        ? AppColors.textSecondary(context)
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: widget.isDark
                          ? AppColors.textTertiary(context)
                          : AppColors.textTertiaryLight,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${DateFormat('MMM dd').format(widget.trip.startDate)} → ${DateFormat('MMM dd, yyyy').format(widget.trip.endDate)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: widget.isDark
                            ? AppColors.textSecondary(context)
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${widget.trip.numberOfDays} days',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: widget.isArchived
                            ? AppColors.textTertiary(context)
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── STATUS BADGE ─────────────────────────────────────────────────────────────

class _StatusBadge extends ConsumerWidget {
  final bool isOngoing;
  final bool isUpcoming;
  final bool isArchived;

  const _StatusBadge({
    required this.isOngoing,
    required this.isUpcoming,
    this.isArchived = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color bgColor;
    Color textColor;
    String label;

    if (isArchived) {
      bgColor = AppColors.textTertiary(context).withValues(alpha: 0.1);
      textColor = AppColors.textTertiary(context);
      label = ref.tr('archived');
    } else if (isOngoing) {
      bgColor = AppColors.primary.withValues(alpha: 0.15);
      textColor = AppColors.primary;
      label = ref.tr('ongoing');
    } else if (isUpcoming) {
      bgColor = AppColors.success.withValues(alpha: 0.15);
      textColor = AppColors.success;
      label = ref.tr('upcoming');
    } else {
      bgColor = AppColors.textTertiary(context).withValues(alpha: 0.15);
      textColor = AppColors.textTertiary(context);
      label = ref.tr('past');
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
            PulsingDot(color: textColor),
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

// ─── MEMBER AVATARS ───────────────────────────────────────────────────────────

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
                color: AppColors.primary.withValues(alpha: 0.3 + i * 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.card(context), width: 2),
              ),
              child: Center(
                child: Icon(Icons.person, size: 14, color: AppColors.primary),
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

// ─── EMPTY STATE ──────────────────────────────────────────────────────────────

class _EmptyTrips extends ConsumerWidget {
  final VoidCallback onCreateTrip;
  final VoidCallback onJoinTrip;

  const _EmptyTrips({required this.onCreateTrip, required this.onJoinTrip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✈️', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 24),
            Text(ref.tr('no_trips_yet'), style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              ref.tr('create_trip_or_join'),
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
                label: Text(ref.tr('create_trip')),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onJoinTrip,
              icon: const Icon(Icons.group_add),
              label: Text(ref.tr('join_with_code')),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SNACKBAR CUSTOM ─────────────────────────────────────────────────────────

void showBottomSnackBar(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => _BottomSnackBar(message: message),
  );
  overlay.insert(overlayEntry);
  Future.delayed(const Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}

class _BottomSnackBar extends StatefulWidget {
  final String message;

  const _BottomSnackBar({required this.message});

  @override
  State<_BottomSnackBar> createState() => _BottomSnackBarState();
}

class _BottomSnackBarState extends State<_BottomSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fade = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _fade,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.delete_outline, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
