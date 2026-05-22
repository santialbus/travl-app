import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/trips_tab.dart';
import '../widgets/map_tab.dart';
import '../widgets/profile_tab.dart';
import '../widgets/join_trip_dialog.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateProvider);

    return authStateAsync.when(
      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/auth');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _HomeContent(userId: user.id);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _HomeContent extends ConsumerStatefulWidget {
  final String userId;

  const _HomeContent({required this.userId});

  @override
  ConsumerState<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<_HomeContent> {
  // ✅ Empezar en Trips (índice 0)
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      TripsTab(userId: widget.userId),
      MapTab(userId: widget.userId),
      const ProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      // ✅ FAB esquina inferior derecha
      floatingActionButton: _currentIndex != 2
          ? FloatingActionButton(
        onPressed: () => _showCreateOrJoin(context),
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      )
          : null,
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  void _showCreateOrJoin(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.surfaceDark
          : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CreateOrJoinSheet(userId: widget.userId),
    );
  }
}

// Bottom Nav normal con 3 tabs
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final activeColor = AppColors.primary;
    final inactiveColor = isDark
        ? AppColors.textTertiary
        : AppColors.textTertiaryLight;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.divider : AppColors.dividerLight,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.luggage_outlined,
                activeIcon: Icons.luggage,
                label: 'Trips',
                isActive: currentIndex == 0,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.map_outlined,
                activeIcon: Icons.map,
                label: 'Map',
                isActive: currentIndex == 1,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                isActive: currentIndex == 2,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? activeColor : inactiveColor,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Create or Join sheet
class _CreateOrJoinSheet extends ConsumerWidget {
  final String userId;

  const _CreateOrJoinSheet({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 24),

          Text('What do you want to do?', style: AppTextStyles.h3),

          const SizedBox(height: 24),

          // Create trip
          InkWell(
            onTap: () {
              Navigator.pop(context);
              context.push('/create-trip');
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Create Trip', style: AppTextStyles.h4),
                        const SizedBox(height: 4),
                        Text(
                          'Start planning a new adventure',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Join trip
          InkWell(
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => JoinTripDialog(userId: userId),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.border : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.border
                            : AppColors.borderLight,
                      ),
                    ),
                    child: const Icon(Icons.group_add_outlined),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Join Trip', style: AppTextStyles.h4),
                        const SizedBox(height: 4),
                        Text(
                          'Enter an invite code or scan QR',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}