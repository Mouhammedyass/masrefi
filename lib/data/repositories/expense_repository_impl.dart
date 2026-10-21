import '../../domain/repositories/expense_repository.dart';
import '../data_sources/local_data_source.dart';
import '../data_sources/remote_data_source.dart';
import '../models/transaction_model.dart';
import '../models/currency_rates_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final LocalDataSource localDataSource;
  final RemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    await localDataSource.cacheTransactions(transactions);
  }

  @override
  List<TransactionModel> getTransactions() {
    return localDataSource.getTransactions();
  }

  @override
  Future<CurrencyRatesModel> getCurrencyRates() async {
    try {
      // 1. Try to fetch fresh rates from Remote API
      final remoteRates = await remoteDataSource.getLiveCurrencyRates();

      // 2. Cache the fresh rates locally
      await localDataSource.cacheCurrencyRates(remoteRates);

      // 3. Return live data
      return remoteRates;
    } catch (e) {
      // 4. Fallback: If offline or API fails, try reading cached rates
      final cachedRates = localDataSource.getCurrencyRates();

      if (cachedRates != null) {
        return cachedRates;
      }

      // 5. If no internet AND no cached data exist
      throw Exception('No internet connection and no cached data available.');
    }
  }

  @override
  Future<void> clearAllData() async {
    await localDataSource.clearAllData();
  }
}