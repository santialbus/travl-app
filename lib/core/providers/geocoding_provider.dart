import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/geocoding_service.dart';

// ✅ Cache automático por Riverpod — solo llama una vez por destino
final geocodingProvider = FutureProvider.family<GeocodingResult?, String>(
      (ref, query) async {
    if (query.trim().isEmpty) return null;

    // Pequeño delay para respetar rate limit de Nominatim
    await Future.delayed(const Duration(milliseconds: 500));

    return GeocodingService.geocode(query);
  },
);