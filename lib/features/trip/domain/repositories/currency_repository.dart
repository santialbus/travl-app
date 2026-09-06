abstract class CurrencyRepository {
  Future<double> getExchangeRate({
    required String baseCurrency,
    required String targetCurrency,
  });
}
