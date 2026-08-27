import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);
    final currentLanguage = ref.watch(appLanguageProvider);

    final languageLabel = switch (currentLanguage) {
      AppLanguage.system => ref.tr('language_system'),
      AppLanguage.en => ref.tr('language_english'),
      AppLanguage.es => ref.tr('language_spanish'),
      AppLanguage.de => '🇩🇪  ${ref.tr('language_german')}',
      AppLanguage.fr => '🇫🇷  ${ref.tr('language_french')}',
      AppLanguage.ja => '🇯🇵  ${ref.tr('language_japanese')}',
    };

    return authAsync.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header avatar
                  _ProfileHeader(
                    name: user.name,
                    email: user.email,
                    photoUrl: user.photoUrl,
                  ),

                  // Account
                  _SectionTitle(title: ref.tr('account')),
                  _SettingsItem(
                    icon: Icons.person_outline,
                    title: ref.tr('name'),
                    value: user.name,
                    onTap: () => _showEditNameDialog(context, ref, user.name),
                  ),
                  _SettingsItem(
                    icon: Icons.email_outlined,
                    title: ref.tr('email'),
                    value: user.email,
                    onTap: null,
                  ),
                  _SettingsItem(
                    icon: Icons.lock_outline,
                    title: ref.tr('change_password'),
                    onTap: () => _showChangePasswordDialog(context, ref),
                  ),

                  const SizedBox(height: 8),

                  // Preferences
                  _SectionTitle(title: ref.tr('preferences')),
                  Consumer(
                    builder: (context, ref, _) {
                      final themeMode = ref.watch(themeModeProvider);
                      final isDark = themeMode == AppThemeMode.dark ||
                          (themeMode == AppThemeMode.system &&
                              MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark);

                      return _SettingsToggle(
                        icon: Icons.dark_mode_outlined,
                        title: ref.tr('dark_mode'),
                        value: isDark,
                        onChanged: (_) =>
                            ref.read(themeModeProvider.notifier).toggle(),
                      );
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.language_outlined,
                    title: ref.tr('language'),
                    value: languageLabel,
                    onTap: () => _showLanguageSheet(context, ref),
                  ),

                  const SizedBox(height: 32),

                  // Sign Out
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await ref
                              .read(authControllerProvider.notifier)
                              .signOut();
                          if (context.mounted) context.go('/auth');
                        },
                        icon: const Icon(Icons.logout, color: AppColors.error),
                        label: Text(
                          ref.tr('sign_out'),
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

  void _showLanguageSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final current = ref.watch(appLanguageProvider);

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
                  Text(ref.tr('language'), style: AppTextStyles.h3),
                  const SizedBox(height: 20),

                  ...AppLanguage.values.map((lang) {
                    final isSelected = current == lang;
                    final label = switch (lang) {
                      AppLanguage.system => '${ref.tr('language_system')} (${_deviceLocaleName()})',
                      AppLanguage.en => '🇬🇧  ${ref.tr('language_english')}',
                      AppLanguage.es => '🇪🇸  ${ref.tr('language_spanish')}',
                      AppLanguage.de => '🇩🇪  ${ref.tr('language_german')}',
                      AppLanguage.fr => '🇫🇷  ${ref.tr('language_french')}',
                      AppLanguage.ja => '🇯🇵  ${ref.tr('language_japanese')}',
                    };

                    return InkWell(
                      onTap: () {
                        ref.read(appLanguageProvider.notifier).setLanguage(lang);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(label, style: AppTextStyles.bodyMedium),
                            ),
                            if (isSelected)
                              Icon(Icons.check, color: AppColors.primary, size: 20),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _deviceLocaleName() {
    final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return code == 'es' ? 'Español' : 'English';
  }

  void _showEditNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final authState = ref.watch(authControllerProvider);

          return AlertDialog(
            backgroundColor: AppColors.surface(context),
            title: Text(ref.tr('edit_name'), style: AppTextStyles.h4),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(labelText: ref.tr('name')),
                textCapitalization: TextCapitalization.words,
                autofocus: true,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? ref.tr('name_required') : null,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(ref.tr('cancel')),
              ),
              ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        final success = await ref
                            .read(authControllerProvider.notifier)
                            .updateDisplayName(controller.text.trim());
                        if (!context.mounted) return;
                        if (success) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(ref.tr('name_updated')),
                            backgroundColor: AppColors.success,
                          ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(authState.error ?? ref.tr('failed_update_name')),
                            backgroundColor: AppColors.error,
                          ));
                        }
                      },
                child: authState.isLoading
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(ref.tr('save')),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final authState = ref.watch(authControllerProvider);

          return AlertDialog(
            backgroundColor: AppColors.surface(context),
            title: Text(ref.tr('change_password'), style: AppTextStyles.h4),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: newPasswordController,
                    decoration: InputDecoration(labelText: ref.tr('new_password')),
                    obscureText: true,
                    autofocus: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return ref.tr('required');
                      if (v.length < 6) return ref.tr('min_6_chars');
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(labelText: ref.tr('confirm_password')),
                    obscureText: true,
                    validator: (v) {
                      if (v != newPasswordController.text) return ref.tr('passwords_no_match');
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(ref.tr('cancel')),
              ),
              ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        final success = await ref
                            .read(authControllerProvider.notifier)
                            .updatePassword(newPasswordController.text);
                        if (!context.mounted) return;
                        if (success) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(ref.tr('password_updated')),
                            backgroundColor: AppColors.success,
                          ));
                        } else {
                          final error = authState.error ?? '';
                          final needsRelogin = error.contains('requires-recent-login');
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(needsRelogin
                                ? ref.tr('relogin_required')
                                : ref.tr('failed_update_password')),
                            backgroundColor: AppColors.error,
                          ));
                        }
                      },
                child: authState.isLoading
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(ref.tr('save')),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;

  const _ProfileHeader({required this.name, required this.email, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: photoUrl != null
                    ? ClipOval(child: Image.network(photoUrl!, fit: BoxFit.cover))
                    : Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: AppTextStyles.h1.copyWith(color: Colors.white),
                        ),
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background(context), width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(name, style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text(email, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context))),
        ],
      ),
    );
  }
}

// ─── Section Title ────────────────────────────────────────────────────────────

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
            color: AppColors.textTertiary(context),
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

// ─── Settings Item ────────────────────────────────────────────────────────────

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;

  const _SettingsItem({required this.icon, required this.title, this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.dividerColor(context), width: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.textSecondary(context)),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: AppTextStyles.bodyMedium)),
            if (value != null)
              Text(value!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context))),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textTertiary(context)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Settings Toggle ──────────────────────────────────────────────────────────

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({required this.icon, required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.dividerColor(context), width: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.textSecondary(context)),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: AppTextStyles.bodyMedium)),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
        ],
      ),
    );
  }
}
