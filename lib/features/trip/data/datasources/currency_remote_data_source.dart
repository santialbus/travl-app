import 'dart:convert';

import 'package:http/http.dart' as http;

class CurrencyRemoteDataSource {
  final http.Client _client;

  CurrencyRemoteDataSource({
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<double> getExchangeRate({
    required String baseCurrency,
    required String targetCurrency,
  }) async {
    try {
      if (baseCurrency == targetCurrency) {
        return 1;
      }

      final uri = Uri.parse(
        'https://api.frankfurter.dev/v2/rate/$baseCurrency/$targetCurrency',
      );

      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to get exchange rate');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return (data['rate'] as num).toDouble();
    } catch (e) {
      throw Exception('Failed to get exchange rate: $e');
    }
  }
}
