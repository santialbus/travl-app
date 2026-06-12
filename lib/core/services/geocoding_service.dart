import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingResult {
  final double latitude;
  final double longitude;
  final String displayName;

  const GeocodingResult({
    required this.latitude,
    required this.longitude,
    required this.displayName,
  });
}

class GeocodingService {
  GeocodingService._();

  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  /// Geocodifica una ciudad o destino
  static Future<GeocodingResult?> geocode(String query) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/search?q=${Uri.encodeComponent(query)}&format=json&limit=1',
      );

      final response = await http.get(
        uri,
        headers: {
          // Nominatim requiere un User-Agent
          'User-Agent': 'Travl App (travl@app.com)',
        },
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as List;
      if (data.isEmpty) return null;

      final result = data.first as Map<String, dynamic>;

      return GeocodingResult(
        latitude: double.parse(result['lat'] as String),
        longitude: double.parse(result['lon'] as String),
        displayName: result['display_name'] as String,
      );
    } catch (e) {
      return null;
    }
  }

  /// Geocodifica múltiples ciudades
  static Future<Map<String, GeocodingResult>> geocodeMultiple(
      List<String> queries,
      ) async {
    final results = <String, GeocodingResult>{};

    for (final query in queries) {
      final result = await geocode(query);
      if (result != null) {
        results[query] = result;
      }
      // Nominatim tiene rate limit — esperar 1 segundo entre requests
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    return results;
  }
}