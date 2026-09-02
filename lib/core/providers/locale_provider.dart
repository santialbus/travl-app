import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported app languages. 'system' follows the device locale,
/// falling back to English if the device language isn't supported.
enum AppLanguage { system, en, es, de, fr, ja }

final appLanguageProvider =
    StateNotifierProvider<AppLanguageNotifier, AppLanguage>((ref) {
  return AppLanguageNotifier();
});

class AppLanguageNotifier extends StateNotifier<AppLanguage> {
  AppLanguageNotifier() : super(AppLanguage.system) {
    _loadLanguage();
  }

  static const _key = 'app_language';

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value != null) {
      state = AppLanguage.values.firstWhere(
        (e) => e.name == value,
        orElse: () => AppLanguage.system,
      );
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, language.name);
  }
}

/// Resolves the effective language code ('en' or 'es') based on
/// the user's preference and, if 'system', the device locale.
final effectiveLanguageCodeProvider = Provider<String>((ref) {
  final language = ref.watch(appLanguageProvider);

  if (language != AppLanguage.system) {
    return language.name;
  }

  final deviceLocale = PlatformDispatcher.instance.locale.languageCode;

  // Lista de códigos de idioma soportados por la app derivados del enum
  final isSupported = AppLanguage.values
      .where((lang) => lang != AppLanguage.system)
      .any((lang) => lang.name == deviceLocale);

  return isSupported ? deviceLocale : 'en';
});

extension AppLanguageX on AppLanguage {
  String get label {
    switch (this) {
      case AppLanguage.system:
        return 'System';
      case AppLanguage.en:
        return 'English';
      case AppLanguage.es:
        return 'Español';
      case AppLanguage.de:
        return 'Deutsch';
      case AppLanguage.fr:
        return 'Français';
      case AppLanguage.ja:
        return '日本語';
    }
  }
}
