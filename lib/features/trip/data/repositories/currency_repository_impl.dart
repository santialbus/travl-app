import '../../domain/repositories/currency_repository.dart';
import '../datasources/currency_remote_data_source.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyRemoteDataSource _remoteDataSource;

  CurrencyRepositoryImpl(this._remoteDataSource);

  @override
  Future<double> getExchangeRate({
    required String baseCurrency,
    required String targetCurrency,
  }) async {
    return await _remoteDataSource.getExchangeRate(
      baseCurrency: baseCurrency,
      targetCurrency: targetCurrency,
    );
  }
}
