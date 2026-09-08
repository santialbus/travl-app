import 'dart:ui' as dart;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/entities/user_avatar.dart';
import 'package:dicebear_core/dicebear_core.dart';
import 'package:dicebear_styles/avataaars.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);
    final currentLanguage = ref.watch(appLanguageProvider);
    final currentCurrency = authAsync.valueOrNull?.preferredCurrency ?? 'EUR';

    final languageLabel = switch (currentLanguage) {
      AppLanguage.system => ref.tr('language_system'),
      AppLanguage.en => '🇬🇧  ${ref.tr('language_english')}',
      AppLanguage.es => '🇪🇸  ${ref.tr('language_spanish')}',
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
                    avatar: user.avatar,
                    onAvatarTap: () =>
                        _showAvatarSheet(context, ref, user.avatar),
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

                  _SettingsItem(
                    icon: Icons.language_outlined,
                    title: ref.tr('language'),
                    value: languageLabel,
                    onTap: () => _showLanguageSheet(context, ref),
                  ),
                  _SettingsItem(
                    icon: Icons.currency_exchange_outlined,
                    title: ref.tr('currency'),
                    value: currentCurrency,
                    onTap: () =>
                        _showCurrencySheet(context, ref, currentCurrency),
                  ),
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
                  _SectionTitle(title: ref.tr('sign_out')),
                  const SizedBox(height: 8),
                  _SignOutItem(
                    title: ref.tr('sign_out'),
                    onTap: () => _showSignOutDialog(context, ref),
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

  void _showAvatarSheet(
    BuildContext context,
    WidgetRef ref,
    UserAvatar? currentAvatar,
  ) {
    final seeds = List.generate(
      8,
      (index) => '${DateTime.now().microsecondsSinceEpoch}-$index',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) => _AvatarSelectionSheet(
        currentAvatar: currentAvatar,
        seeds: seeds,
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface(dialogContext),
        title: Text(
          ref.tr('sign_out'),
          style: AppTextStyles.h4,
        ),
        content: Text(ref.tr('confirm_sign_out')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(ref.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/auth');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(ref.tr('sign_out')),
          ),
        ],
      ),
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
                      AppLanguage.system =>
                        '${ref.tr('language_system')} (${_deviceLocaleName()})',
                      AppLanguage.en => '🇬🇧  ${ref.tr('language_english')}',
                      AppLanguage.es => '🇪🇸  ${ref.tr('language_spanish')}',
                      AppLanguage.de => '🇩🇪  ${ref.tr('language_german')}',
                      AppLanguage.fr => '🇫🇷  ${ref.tr('language_french')}',
                      AppLanguage.ja => '🇯🇵  ${ref.tr('language_japanese')}',
                    };

                    return InkWell(
                      onTap: () {
                        ref
                            .read(appLanguageProvider.notifier)
                            .setLanguage(lang);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child:
                                  Text(label, style: AppTextStyles.bodyMedium),
                            ),
                            if (isSelected)
                              Icon(Icons.check,
                                  color: AppColors.primary, size: 20),
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

  static const _currencies = {
    'EUR': '€',
    'USD': '\$',
    'GBP': '£',
    'JPY': '¥',
    'CNY': '¥',
  };

  void _showCurrencySheet(
    BuildContext context,
    WidgetRef ref,
    String currentCurrency,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Text(ref.tr('currency'), style: AppTextStyles.h3),
              const SizedBox(height: 20),
              ..._currencies.entries.map((entry) {
                final isSelected = currentCurrency == entry.key;

                return InkWell(
                  onTap: () async {
                    final success = await ref
                        .read(authControllerProvider.notifier)
                        .updatePreferredCurrency(entry.key);

                    if (!context.mounted) return;

                    if (success) {
                      Navigator.pop(context);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 32,
                          child: Text(
                            entry.value,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check,
                            color: AppColors.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  String _deviceLocaleName() {
    return switch (
        WidgetsBinding.instance.platformDispatcher.locale.languageCode) {
      'es' => 'Español',
      'de' => 'Deutsch',
      'fr' => 'Français',
      'ja' => '日本語',
      _ => 'English',
    };
  }

  void _showEditNameDialog(
      BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => Consumer(
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
                validator: (v) => v == null || v.trim().isEmpty
                    ? ref.tr('name_required')
                    : null,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
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

                        if (!dialogContext.mounted) return;

                        Navigator.pop(dialogContext);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? ref.tr('name_updated')
                                : ref.tr('failed_update_name')),
                            backgroundColor:
                                success ? AppColors.success : AppColors.error,
                          ),
                        );
                      },
                child: authState.isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
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
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => Consumer(
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
                    controller: currentPasswordController,
                    decoration:
                        InputDecoration(labelText: ref.tr('current_password')),
                    obscureText: true,
                    autofocus: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return ref.tr('required');
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: newPasswordController,
                    decoration:
                        InputDecoration(labelText: ref.tr('new_password')),
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return ref.tr('required');
                      if (v.length < 6) return ref.tr('min_6_chars');
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration:
                        InputDecoration(labelText: ref.tr('confirm_password')),
                    obscureText: true,
                    validator: (v) {
                      if (v != newPasswordController.text)
                        return ref.tr('passwords_no_match');
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(ref.tr('cancel')),
              ),
              ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;

                        final success = await ref
                            .read(authControllerProvider.notifier)
                            .updatePassword(
                              currentPasswordController.text,
                              newPasswordController.text,
                            );

                        if (!dialogContext.mounted) return;

                        final updatedState = ref.read(authControllerProvider);

                        Navigator.pop(dialogContext);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? ref.tr('password_updated')
                                : ref.tr('failed_update_password')),
                            backgroundColor:
                                success ? AppColors.success : AppColors.error,
                          ),
                        );
                      },
                child: authState.isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(ref.tr('save')),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AvatarSelectionSheet extends ConsumerStatefulWidget {
  final UserAvatar? currentAvatar;
  final List<String> seeds;

  const _AvatarSelectionSheet({
    required this.currentAvatar,
    required this.seeds,
  });

  @override
  ConsumerState<_AvatarSelectionSheet> createState() =>
      _AvatarSelectionSheetState();
}

class _AvatarSelectionSheetState extends ConsumerState<_AvatarSelectionSheet> {
  late List<String> _seeds;
  String? _selectedSeed;
  late String _selectedBackground;

  final List<String> _backgroundColors = [
    'b6e3f4',
    'c0aede',
    'ffd5dc',
    'ffdfbf',
    'd1f4c4',
    'ffe8a3',
    'd9d9d9',
    'bde0fe',
  ];

  @override
  void initState() {
    super.initState();

    _seeds = [
      if (widget.currentAvatar != null) widget.currentAvatar!.seed,
      ...widget.seeds.where(
        (seed) => seed != widget.currentAvatar?.seed,
      ),
    ];

    _selectedSeed = widget.currentAvatar?.seed;
    _selectedBackground =
        widget.currentAvatar?.backgroundColor ?? _backgroundColors.first;
  }

  void _generateNewAvatars() {
    setState(() {
      _seeds = List.generate(
        8,
        (index) => '${DateTime.now().microsecondsSinceEpoch}-$index',
      );
      _selectedSeed = null;
    });
  }

  void _selectAvatar(String seed) {
    setState(() {
      _selectedSeed = seed;
    });
  }

  void _selectBackground(String color) {
    setState(() {
      _selectedBackground = color;
    });
  }

  Future<void> _saveAvatar() async {
    if (_selectedSeed == null) return;

    final success =
        await ref.read(authControllerProvider.notifier).updateAvatar(
              UserAvatar(
                style: UserAvatarStyle.avataaars,
                seed: _selectedSeed!,
                backgroundColor: _selectedBackground,
              ),
            );

    if (!mounted) return;

    if (success) {
      ref.invalidate(authStateProvider);
      Navigator.pop(context);
    }
  }

  Future<void> _removeAvatar() async {
    final success =
        await ref.read(authControllerProvider.notifier).updateAvatar(null);

    if (!mounted) return;

    if (success) {
      ref.invalidate(authStateProvider);
      Navigator.pop(context);
    }
  }

  dart.Color _avatarBackgroundColor(String hex) {
    return dart.Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    final previewSeed = _selectedSeed ?? _seeds.first;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
              ref.tr('choose_avatar'),
              style: AppTextStyles.h3,
            ),

            const SizedBox(height: 20),

            // Preview
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Container(
                key: ValueKey('$previewSeed-$_selectedBackground'),
                width: 120,
                height: 120,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 3,
                  ),
                ),
                child: _DiceBearAvatar(
                  seed: previewSeed,
                  backgroundColor: _selectedBackground,
                  size: 112,
                ),
              ),
            ),

            const SizedBox(height: 24),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _seeds.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final seed = _seeds[index];
                final isSelected = seed == _selectedSeed;

                return InkWell(
                  onTap: authState.isLoading ? null : () => _selectAvatar(seed),
                  borderRadius: BorderRadius.circular(50),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: _DiceBearAvatar(
                      seed: seed,
                      backgroundColor: _selectedBackground,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ref.tr('generate_new_avatar'),
                style: AppTextStyles.bodyMedium,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _backgroundColors.map((color) {
                final isSelected = color == _selectedBackground;

                return GestureDetector(
                  onTap: authState.isLoading
                      ? null
                      : () => _selectBackground(color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _avatarBackgroundColor(color),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 18,
                            color: Colors.black54,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            OutlinedButton.icon(
              onPressed: authState.isLoading ? null : _generateNewAvatars,
              icon: const Icon(Icons.refresh),
              label: Text(ref.tr('avatar_background')),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _selectedSeed == null || authState.isLoading
                    ? null
                    : _saveAvatar,
                child: authState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(ref.tr('save')),
              ),
            ),

            if (widget.currentAvatar != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: authState.isLoading ? null : _removeAvatar,
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
                label: Text(
                  ref.tr('remove_avatar'),
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _buildAvatarSvg(UserAvatar avatar) {
  final style = Style.parse(avataaars);
  final dicebearAvatar = Avatar(
    style,
    {
      'seed': avatar.seed,
      'backgroundColor': [avatar.backgroundColor],
    },
  );

  return dicebearAvatar.svg;
}

class _DiceBearAvatar extends StatelessWidget {
  final String seed;
  final String backgroundColor;
  final double size;

  const _DiceBearAvatar({
    required this.seed,
    required this.backgroundColor,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = UserAvatar(
      style: UserAvatarStyle.avataaars,
      seed: seed,
      backgroundColor: backgroundColor,
    );

    return ClipOval(
      child: SvgPicture.string(
        _buildAvatarSvg(avatar),
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;
  final UserAvatar? avatar;
  final VoidCallback onAvatarTap;

  const _ProfileHeader({
    required this.name,
    required this.email,
    this.photoUrl,
    this.avatar,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 108,
                  height: 108,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface(context),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: _AvatarContent(
                        name: name,
                        photoUrl: photoUrl,
                        avatar: avatar,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: 2,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.background(context),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            name.isNotEmpty ? name : 'User',
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            email,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onAvatarTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.face_retouching_natural,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  avatar == null ? 'Create avatar' : 'Change avatar',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarContent extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final UserAvatar? avatar;

  String _buildAvatarSvg(UserAvatar avatar) {
    final style = Style.parse(avataaars);
    final dicebearAvatar = Avatar(
      style,
      {
        'seed': avatar.seed,
        'backgroundColor': [avatar.backgroundColor],
      },
    );

    return dicebearAvatar.svg;
  }

  const _AvatarContent({
    required this.name,
    this.photoUrl,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    if (avatar != null) {
      return ClipOval(
        child: SvgPicture.string(
          _buildAvatarSvg(avatar!),
          fit: BoxFit.cover,
        ),
      );
    }

    if (photoUrl != null) {
      return ClipOval(
        child: Image.network(
          photoUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initial,
        ),
      );
    }

    return _initial;
  }

  Widget get _initial => Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: AppTextStyles.h1.copyWith(color: Colors.white),
        ),
      );
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

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (value != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textTertiary(context),
                ),
              ],
            ],
          ),
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

  const _SettingsToggle({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.dividerColor(context),
              width: 0.5,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignOutItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SignOutItem({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.dividerColor(context),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.logout_outlined,
                  size: 20,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.error.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
