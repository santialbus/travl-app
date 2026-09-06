import '../repositories/currency_repository.dart';

class GetExchangeRateUseCase {
  final CurrencyRepository _repository;

  GetExchangeRateUseCase(this._repository);

  Future<double> call({
    required String baseCurrency,
    required String targetCurrency,
  }) async {
    return await _repository.getExchangeRate(
      baseCurrency: baseCurrency,
      targetCurrency: targetCurrency,
    );
  }
}
