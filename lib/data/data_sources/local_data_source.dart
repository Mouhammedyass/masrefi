import '../models/transaction_model.dart';
import '../models/currency_rates_model.dart';
import '../services/storage_service.dart';

abstract class LocalDataSource {
  Future<void> cacheTransactions(List<TransactionModel> transactions);
  List<TransactionModel> getTransactions();
  Future<void> cacheCurrencyRates(CurrencyRatesModel rates);
  CurrencyRatesModel? getCurrencyRates();
  Future<void> clearAllData();
}

class LocalDataSourceImpl implements LocalDataSource {
  final StorageService _storageService;

  // Keys ثابتة لتجنب الأخطاء الإملائية في الـ Storage
  static const String _transactionsKey = 'CACHED_TRANSACTIONS';
  static const String _currencyRatesKey = 'CACHED_CURRENCY_RATES';

  // استقبال الـ StorageService عبر الـ Constructor
  LocalDataSourceImpl(this._storageService);

  @override
  Future<void> cacheTransactions(List<TransactionModel> transactions) async {
    // تحويل قائمة الـ Models إلى قائمة من الـ Maps/JSON
    final List<Map<String, dynamic>> jsonList =
    transactions.map((transaction) => transaction.toJson()).toList();

    await _storageService.writeData(_transactionsKey, jsonList);
  }

  @override
  List<TransactionModel> getTransactions() {
    final rawData = _storageService.readData<List>(_transactionsKey);

    if (rawData == null) return [];

    // تحويل القائمة الخام القادمة من الـ Storage إلى قائمة من TransactionModel
    return rawData
        .map((item) => TransactionModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<void> cacheCurrencyRates(CurrencyRatesModel rates) async {
    await _storageService.writeData(_currencyRatesKey, rates.toJson());
  }

  @override
  CurrencyRatesModel? getCurrencyRates() {
    final rawData = _storageService.readData<Map>(_currencyRatesKey);

    if (rawData == null) return null;

    return CurrencyRatesModel.fromJson(Map<String, dynamic>.from(rawData));
  }

  @override
  Future<void> clearAllData() async {
    await _storageService.clearAll();
  }
}