import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/currency_remote_data_source.dart';
import '../../data/repositories/currency_repository_impl.dart';
import '../../domain/repositories/currency_repository.dart';
import '../../domain/usecases/get_exchange_rate_usecase.dart';

final currencyDataSourceProvider = Provider<CurrencyRemoteDataSource>((ref) {
  return CurrencyRemoteDataSource();
});

final currencyRepositoryProvider = Provider<CurrencyRepository>((ref) {
  final dataSource = ref.watch(currencyDataSourceProvider);
  return CurrencyRepositoryImpl(dataSource);
});

final getExchangeRateUseCaseProvider = Provider<GetExchangeRateUseCase>((ref) {
  final repository = ref.watch(currencyRepositoryProvider);
  return GetExchangeRateUseCase(repository);
});

final currencyRatesProvider =
    FutureProvider.family<Map<String, double>, CurrencyRatesParams>(
  (ref, params) async {
    final useCase = ref.watch(getExchangeRateUseCaseProvider);

    print(
      'CurrencyRatesProvider: ${params.sourceCurrencies} -> ${params.targetCurrency}',
    );

    final rates = <String, double>{};

    for (final currency in params.sourceCurrencies) {
      final rate = await useCase(
        baseCurrency: currency,
        targetCurrency: params.targetCurrency,
      );

      print(
        'CurrencyRatesProvider rate: $currency -> ${params.targetCurrency} = $rate',
      );

      rates[currency] = rate;
    }

    print('CurrencyRatesProvider final rates: $rates');

    return rates;
  },
);

class CurrencyRatesParams {
  final List<String> sourceCurrencies;
  final String targetCurrency;

  CurrencyRatesParams({
    required List<String> sourceCurrencies,
    required this.targetCurrency,
  }) : sourceCurrencies = List.unmodifiable(
          [...sourceCurrencies]..sort(),
        );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CurrencyRatesParams &&
        other.targetCurrency == targetCurrency &&
        _listEquals(other.sourceCurrencies, sourceCurrencies);
  }

  @override
  int get hashCode => Object.hash(
        targetCurrency,
        Object.hashAll(sourceCurrencies),
      );

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }
}

final selectedCurrencyProvider = StateProvider<String?>((ref) => null);
