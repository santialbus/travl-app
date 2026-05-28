import 'package:shared_preferences/shared_preferences.dart';

enum MapApp {
  googleMaps,
  appleMaps,
  waze,
  systemDefault,
}

class MapsPreferenceService {
  MapsPreferenceService._();

  static const String _key = 'preferred_map_app';

  static Future<MapApp?> getPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == null) return null;

    return MapApp.values.firstWhere(
          (e) => e.name == value,
      orElse: () => MapApp.systemDefault,
    );
  }

  static Future<void> savePreference(MapApp app) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, app.name);
  }

  static Future<void> clearPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}