import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:native_liquid_glass/native_liquid_glass.dart';

import '../../../../core/localization/app_strings.dart';
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
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      TripsTab(userId: widget.userId),
      MapTab(userId: widget.userId),
      const ProfileTab(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showCreateOrJoin(context),
              backgroundColor: AppColors.primary,
              elevation: 4,
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            )
          : null,
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: _handleTabTap,
      ),
    );
  }

  void _handleTabTap(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });
  }

  void _showCreateOrJoin(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.surface(context)
          : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => _CreateOrJoinSheet(
        userId: widget.userId,
      ),
    );
  }
}

// Bottom Navigation: Native Liquid Glass on iOS 26+
// Flutter glass fallback on older iOS, Android and Web.

class _BottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<_BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<_BottomNav> {
  late List<LiquidGlassTabItem> _nativeItems;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _nativeItems = [
      LiquidGlassTabItem(
        label: context.tr('trips_tab'),
        icon: NativeLiquidGlassIcon.iconData(Icons.luggage_outlined),
        selectedIcon: NativeLiquidGlassIcon.iconData(Icons.luggage),
      ),
      LiquidGlassTabItem(
        label: context.tr('map_tab'),
        icon: NativeLiquidGlassIcon.iconData(Icons.map_outlined),
        selectedIcon: NativeLiquidGlassIcon.iconData(Icons.map),
      ),
      LiquidGlassTabItem(
        label: context.tr('profile_tab'),
        icon: NativeLiquidGlassIcon.iconData(Icons.person_outline),
        selectedIcon: NativeLiquidGlassIcon.iconData(Icons.person),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (NativeLiquidGlassUtils.supportsLiquidGlass) {
      return LiquidGlassTabBar(
        items: _nativeItems,
        currentIndex: widget.currentIndex,
        onTabSelected: widget.onTap,
        height: 72,
        iconSize: 22,
        showLabels: true,
        selectedItemColor: AppColors.primary,
        labelTextStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    // Fallback Flutter para iOS anterior a 26,
    // Android y Web.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeColor = AppColors.primary;

    final inactiveColor =
        isDark ? AppColors.textTertiary(context) : AppColors.textTertiaryLight;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 22,
              sigmaY: 22,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.white.withValues(alpha: 0.13),
                          Colors.white.withValues(alpha: 0.05),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.72),
                          Colors.white.withValues(alpha: 0.48),
                        ],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: isDark ? 0.20 : 0.65,
                  ),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDark ? 0.20 : 0.08,
                    ),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: _NavItem(
                        icon: Icons.luggage_outlined,
                        activeIcon: Icons.luggage,
                        label: context.tr('trips_tab'),
                        isActive: widget.currentIndex == 0,
                        activeColor: activeColor,
                        inactiveColor: inactiveColor,
                        onTap: () => widget.onTap(0),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        icon: Icons.map_outlined,
                        activeIcon: Icons.map,
                        label: context.tr('map_tab'),
                        isActive: widget.currentIndex == 1,
                        activeColor: activeColor,
                        inactiveColor: inactiveColor,
                        onTap: () => widget.onTap(1),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        icon: Icons.person_outline,
                        activeIcon: Icons.person,
                        label: context.tr('profile_tab'),
                        isActive: widget.currentIndex == 2,
                        activeColor: activeColor,
                        inactiveColor: inactiveColor,
                        onTap: () => widget.onTap(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 8,
        ),
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
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
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

  const _CreateOrJoinSheet({
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.card(context) : AppColors.cardLight;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            context.tr('what_do_you_want_to_do'),
            style: AppTextStyles.h3,
          ),

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
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
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
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('create_trip'),
                          style: AppTextStyles.h4,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr('start_planning_adventure'),
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textTertiary(context),
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
                builder: (context) => JoinTripDialog(
                  userId: userId,
                ),
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
                  color: isDark
                      ? AppColors.borderColor(context)
                      : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surface(context)
                          : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderColor(context)
                            : AppColors.borderLight,
                      ),
                    ),
                    child: const Icon(
                      Icons.group_add_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('join_trip'),
                          style: AppTextStyles.h4,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr('enter_code_or_scan'),
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textTertiary(context),
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
