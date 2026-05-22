import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/providers/theme_provider.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authStateProvider);

    return authAsync.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();

        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header with avatar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                    child: Column(
                      children: [
                        // Avatar
                        Stack(
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.primaryGradient,
                              ),
                              child: user.photoUrl != null
                                  ? ClipOval(
                                child: Image.network(
                                  user.photoUrl!,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : Center(
                                child: Text(
                                  user.name.isNotEmpty
                                      ? user.name[0].toUpperCase()
                                      : '?',
                                  style: AppTextStyles.h1.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  // TODO: Image picker
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.backgroundDark,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Text(user.name, style: AppTextStyles.h3),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  // Account Section
                  _SectionTitle(title: 'ACCOUNT'),

                  _SettingsItem(
                    icon: Icons.person_outline,
                    title: 'Name',
                    value: user.name,
                    onTap: () => _showEditNameDialog(context, user.name),
                  ),
                  _SettingsItem(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    value: user.email,
                    onTap: null, // Read only
                  ),
                  _SettingsItem(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () => _showChangePasswordDialog(context),
                  ),

                  const SizedBox(height: 8),

                  // Preferences Section
                  _SectionTitle(title: 'PREFERENCES'),

                  _SettingsToggle(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    value: _notificationsEnabled,
                    onChanged: (val) =>
                        setState(() => _notificationsEnabled = val),
                  ),
                  // Reemplaza el _SettingsToggle de Dark Mode por este:
                  Consumer(
                    builder: (context, ref, _) {
                      final themeMode = ref.watch(themeModeProvider);
                      final isDarkEnabled = themeMode == AppThemeMode.dark ||
                          (themeMode == AppThemeMode.system &&
                              MediaQuery.of(context).platformBrightness == Brightness.dark);

                      return _SettingsToggle(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark Mode',
                        value: isDarkEnabled,
                        onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
                      );
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.language_outlined,
                    title: 'Language',
                    value: 'English',
                    onTap: null,
                  ),

                  const SizedBox(height: 32),

                  // Sign Out
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () => _signOut(context),
                        icon: const Icon(Icons.logout, color: AppColors.error),
                        label: Text(
                          'Sign Out',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text('Edit Name', style: AppTextStyles.h4),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Name',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Update name in Firebase
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text('Change Password', style: AppTextStyles.h4),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New Password',
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Update password in Firebase
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await ref.read(authControllerProvider.notifier).signOut();
    if (context.mounted) context.go('/auth');
  }
}

// Section Title
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textTertiary,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

// Settings Item with value
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.textSecondary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: AppTextStyles.bodyMedium),
            ),
            if (value != null)
              Text(
                value!,
                style: AppTextStyles.bodySmall,
              ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.textTertiary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Settings Toggle
class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.textSecondary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: AppTextStyles.bodyMedium),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}