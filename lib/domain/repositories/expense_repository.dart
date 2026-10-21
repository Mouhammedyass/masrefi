import '../../data/models/transaction_model.dart';
import '../../data/models/currency_rates_model.dart';

abstract class ExpenseRepository {
  Future<void> saveTransactions(List<TransactionModel> transactions);
  List<TransactionModel> getTransactions();
  Future<CurrencyRatesModel> getCurrencyRates();
  Future<void> clearAllData();
}