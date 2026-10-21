import 'package:get/get.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/currency_rates_model.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../data/services/storage_service.dart';

class HomeController extends GetxController {
  final ExpenseRepository repository;
  final StorageService storageService = Get.find<StorageService>();

  HomeController({required this.repository});

  // 1. Reactive State Variables
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final Rxn<CurrencyRatesModel> currencyRates = Rxn<CurrencyRatesModel>();
  final RxBool isLoading = false.obs;
  final RxString selectedCurrency = 'EGP'.obs;

  @override
  void onInit() {
    super.onInit();
    loadDefaultCurrency();
    loadInitialData();
  }
  @override
  void onReady() {
    super.onReady();
    loadDefaultCurrency();
  }


  void loadDefaultCurrency() {
    selectedCurrency.value = storageService.readData<String>('default_currency') ?? 'EGP';
  }

  // 2. Getters for Calculated Statistics
  double get totalIncome => transactions
      .where((transaction) => !transaction.isExpense)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpenses => transactions
      .where((transaction) => transaction.isExpense)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get netBalance => totalIncome - totalExpenses;

  // 3. Load Data from Repository
  Future<void> loadInitialData() async {
    isLoading.value = true;
    loadDefaultCurrency();

    // Fetch local transactions
    final localData = repository.getTransactions();
    transactions.assignAll(localData);

    // Fetch live or cached currency rates
    try {
      final rates = await repository.getCurrencyRates();
      currencyRates.value = rates;
    } catch (e) {
      Get.snackbar('notice'.tr, 'offline_notice'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  // 4. Add Transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    transactions.add(transaction);
    await repository.saveTransactions(transactions);
  }

  // 5. Delete Transaction
  Future<void> deleteTransaction(String id) async {
    transactions.removeWhere((transaction) => transaction.id == id);
    await repository.saveTransactions(transactions);
  }

  // 6. Update Transaction
  Future<void> updateTransaction(TransactionModel updatedTransaction) async {
    final index = transactions.indexWhere((t) => t.id == updatedTransaction.id);
    if (index != -1) {
      transactions[index] = updatedTransaction;
      await repository.saveTransactions(transactions);
    }
  }
}