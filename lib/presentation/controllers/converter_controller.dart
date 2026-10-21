import 'package:get/get.dart';
import '../../data/models/currency_rates_model.dart';
import '../../data/services/storage_service.dart';
import '../../domain/repositories/expense_repository.dart';

class ConverterController extends GetxController {
  final ExpenseRepository repository;
  final StorageService storageService = Get.find<StorageService>();
  ConverterController({required this.repository});
  RxDouble amount = 1.0.obs;
  RxString fromCurrency = 'USD'.obs;
  RxString toCurrency = 'EGP'.obs;
  Rxn currencyRates = Rxn<CurrencyRatesModel>();
  RxBool isLoading = false.obs;
  RxString baseCurrency = 'EGP'.obs;

  double get convertedAmount {
    if (currencyRates.value == null || currencyRates.value!.rates.isEmpty) {
      return 0.0;
    }
    final rates = currencyRates.value!.rates;
    final rateFrom = rates[fromCurrency.value] ?? 1.0;
    final rateTo = rates[toCurrency.value] ?? 1.0;
    return amount.value * (rateTo / rateFrom);
  }
  @override
  void onInit() {
    super.onInit();
    loadBaseCurrency();
    fetchRates();
  }
  @override
  void onReady() {
    super.onReady();
    loadBaseCurrency();
  }

  void loadBaseCurrency() {
    baseCurrency.value = storageService.readData<String>('default_currency') ?? 'EGP';
  }
  void fetchRates()async{
    isLoading.value = true;
    loadBaseCurrency();
    try {
      final rates = await repository.getCurrencyRates();
      currencyRates.value = rates;
    } catch (e) {
      Get.snackbar('notice'.tr, 'offline_notice'.tr);
    } finally {
      isLoading.value = false;
    }

  }

  void swapCurrencies() {
    final temp = fromCurrency.value;
    fromCurrency.value = toCurrency.value;
    toCurrency.value = temp;
  }
  String getCurrencyName(String code) {
    final translationKey = 'curr_$code';

    if (translationKey.tr != translationKey) {
      return translationKey.tr;
    } else {
      return '${'international_currency'.tr} ($code)';
    }
  }
  List<Map<String, dynamic>> getPopularRates() {
    if (currencyRates.value == null || currencyRates.value!.rates.isEmpty) {
      return [];
    }

    final rates = currencyRates.value!.rates;
    final base = baseCurrency.value;
    final baseRate = rates[base] ?? 1.0;

    // القائمة المستهدفة
    final List<String> popularList = ['USD', 'EUR', 'GBP', 'SAR', 'KWD', 'AED', 'EGP'];

    // استبعاد العملة الأساسية
    final filteredList = popularList.where((c) => c != base).toList();

    return filteredList.map((code) {
      final codeRate = rates[code] ?? 1.0;
      // السعر بالنسبة للـ Base Currency
      final calculatedRate = baseRate / codeRate;

      // حساب وهمي أو افتراضي لنسبة التغير طالما الـ API محلي (أو قراءته لو متوفر)
      final changePercent = ((code.hashCode % 30) - 10) / 100.0;

      return {
        'code': code,
        'pair': '$code / $base',
        'rate': calculatedRate,
        'change': changePercent,
      };
    }).toList();
  }
}