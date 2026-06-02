import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/offline_indicator.dart';
import '../providers/permissions_provider.dart';
import '../providers/trip_provider.dart';
import '../../domain/entities/trip_entity.dart';
import 'timeline_page.dart';
import 'expenses_page.dart';
import 'checklist_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';


class TripDashboardPage extends ConsumerWidget {
  final String tripId;

  const TripDashboardPage({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripStreamProvider(tripId));

    return tripAsync.when(
      data: (trip) => _TripDashboardContent(trip: trip),
      loading: () => Scaffold(
        ///backgroundColor: AppColors.backgroundDark,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        //backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Failed to load trip', style: AppTextStyles.h4),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripDashboardContent extends ConsumerStatefulWidget {
  final TripEntity trip;

  const _TripDashboardContent({required this.trip});

  @override
  ConsumerState<_TripDashboardContent> createState() =>
      _TripDashboardContentState();
}

class _TripDashboardContentState extends ConsumerState<_TripDashboardContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ✅ Añadir scroll controller
  late ScrollController _scrollController;
  bool _showTitle = false;

  void _onScroll() {
    // Mostrar título cuando el header se ha colapsado (~150px)
    final shouldShow = _scrollController.offset > 120;
    if (shouldShow != _showTitle) {
      setState(() => _showTitle = shouldShow);
    }
  }

  void _toggleCoHost(
      BuildContext rootContext,
      TripEntity trip,
      MemberEntity member,
      ) async {
    final newRole = member.isCoHost ? 'member' : 'cohost';
    final action = member.isCoHost ? 'removed as co-host' : 'made co-host';

    // 👉 feedback inmediato
    showTopSnackBar(rootContext, 'Updating role...');

    try {
      await ref.read(tripControllerProvider.notifier).updateMemberRole(
        tripId: trip.id,
        userId: member.userId,
        newRole: newRole,
      );

      // 👉 feedback final
      showTopSnackBar(rootContext, 'Member $action');
    } catch (e) {
      showTopSnackBar(rootContext, 'Error updating role');
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(tripStreamProvider(widget.trip.id)).value ?? widget.trip;
    final isOngoing = trip.startDate.isBefore(DateTime.now()) &&
        trip.endDate.isAfter(DateTime.now());
    final isUpcoming = trip.startDate.isAfter(DateTime.now());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: true,
                floating: false,
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: AppColors.background(context),

                title: AnimatedOpacity(
                  opacity: _showTitle ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.trip.destination,
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(width: 8),
                      const OfflineIndicator(), // ✅
                    ],
                  ),
                ),
                centerTitle: true,

                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary(context),
                  ),
                  onPressed: () => context.go('/home'),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.people_outline,
                      color: AppColors.textSecondary(context),
                    ),
                    onPressed: () => _showMembersSheet(context, widget.trip),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.ios_share_outlined,
                      color: AppColors.textSecondary(context),
                    ),
                    onPressed: () => _showInviteSheet(context, widget.trip.inviteCode),
                  ),
                  const SizedBox(width: 4),
                ],
              ),

              // Header content as sliver
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isOngoing
                              ? AppColors.primary.withOpacity(0.15)
                              : isUpcoming
                              ? AppColors.success.withOpacity(0.15)
                              : AppColors.surface(context),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isOngoing)
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            Text(
                              isOngoing
                                  ? 'Ongoing'
                                  : isUpcoming
                                  ? 'Upcoming'
                                  : 'Past trip',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isOngoing
                                    ? AppColors.primary
                                    : isUpcoming
                                    ? AppColors.success
                                    : AppColors.textTertiary(context),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Destination
                      Text(
                        trip.destination,
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 32,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Trip name
                      Text(
                        trip.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Info row
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: AppColors.textTertiary(context),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppDateUtils.formatDateRange(
                              trip.startDate,
                              trip.endDate,
                            ),
                            style: AppTextStyles.bodySmall,
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.card(context),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${trip.numberOfDays} days',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Members
                          Icon(
                            Icons.people_outline,
                            size: 14,
                            color: AppColors.textTertiary(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${trip.members.length} members',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Tabs — sin línea de separación
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    // Sin línea de separación
                    dividerColor: Colors.transparent,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 2,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: AppColors.textPrimary(context),
                    unselectedLabelColor: AppColors.textTertiary(context),
                    labelStyle: AppTextStyles.labelLarge,
                    unselectedLabelStyle: AppTextStyles.labelMedium,
                    tabs: const [
                      Tab(text: 'Timeline'),
                      Tab(text: 'Expenses'),
                      Tab(text: 'Checklist'),
                    ],
                  ),
                  backgroundColor: AppColors.background(context),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              // ✅ Consumer para obtener userId
              Consumer(
                builder: (context, ref, _) {
                  final authAsync = ref.watch(authStateProvider);
                  final userId = authAsync.maybeWhen(
                    data: (user) => user?.id ?? '',
                    orElse: () => '',
                  );
                  return TimelinePage(
                    tripId: trip.id,
                    userId: userId, // ✅ Pasamos userId
                  );
                },
              ),
              ExpensesPage(tripId: trip.id),
              ChecklistPage(tripId: trip.id),
            ],
          ),
        ),
      ),
    );
  }

  void _showMembersSheet(BuildContext context, TripEntity trip) {
    final rootContext = context;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final tripAsync = ref.watch(tripStreamProvider(trip.id));
          final tripData = tripAsync.value ?? trip;

          final currentMember = ref.watch(currentMemberProvider(trip.id));
          final isHost = currentMember?.isHost ?? false;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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

                Text(
                  'Members (${tripData.members.length})',
                  style: AppTextStyles.h3,
                ),

                const SizedBox(height: 16),

                ...tripData.members.map((member) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.card(context),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          color: AppColors.textSecondary(context),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Nombre/ID
                      Expanded(
                        child: Text(
                          member.userId,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),

                      // Badge rol
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: member.isHost
                              ? AppColors.primary.withOpacity(0.15)
                              : member.isCoHost
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.card(context),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          member.isHost
                              ? '👑 Host'
                              : member.isCoHost
                              ? '🤝 Co-host'
                              : 'Member',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: member.isHost || member.isCoHost
                                ? AppColors.primary
                                : AppColors.textSecondary(context),
                          ),
                        ),
                      ),

                      // Toggle co-host
                      if (isHost && !member.isHost) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            _toggleCoHost(rootContext, tripData, member);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: member.isCoHost
                                  ? AppColors.primary.withOpacity(0.15)
                                  : AppColors.card(context),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: member.isCoHost
                                    ? AppColors.primary
                                    : AppColors.borderColor(context),
                              ),
                            ),
                            child: Text(
                              member.isCoHost
                                  ? '✓ Co-host'
                                  : 'Make co-host',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: member.isCoHost
                                    ? AppColors.primary
                                    : AppColors.textTertiary(context),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                )),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showInviteSheet(context, tripData.inviteCode);
                    },
                    icon: const Icon(Icons.person_add_outlined),
                    label: const Text('Invite Someone'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void showTopSnackBar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 60,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                )
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  void _showInviteSheet(BuildContext context, String inviteCode) {
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

            Text('Invite Friends', style: AppTextStyles.h3),

            const SizedBox(height: 24),

            // QR
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: QrImageView(
                data: inviteCode,
                version: QrVersions.auto,
                size: 160,
              ),
            ),

            const SizedBox(height: 20),

            // Invite code
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  inviteCode,
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Share.share(
                  'Join my trip on Travl! 🌍\nUse code: $inviteCode',
                ),
                icon: const Icon(Icons.share),
                label: const Text('Share Invite Code'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Sticky tab bar sin línea separadora
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _StickyTabBarDelegate(this.tabBar, {required this.backgroundColor});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) =>
      oldDelegate.backgroundColor != backgroundColor;
}