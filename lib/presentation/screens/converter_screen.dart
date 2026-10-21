import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/converter_controller.dart';

class ConverterScreen extends GetView<ConverterController> {
  const ConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('currency_converter'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final ratesModel = controller.currencyRates.value;
        final List<String> allRatesKeys = (ratesModel != null && ratesModel.rates.isNotEmpty)
            ? ratesModel.rates.keys.toList()
            : ['EGP', 'USD', 'EUR', 'GBP', 'SAR', 'AED', 'KWD'];

        final popularCurrencies = ['EGP', 'USD', 'EUR', 'GBP', 'SAR', 'AED', 'KWD', 'QAR', 'JOD', 'BHD', 'OMR'];

        final currencies = [
          ...popularCurrencies.where((c) => allRatesKeys.contains(c)),
          ...allRatesKeys.where((c) => !popularCurrencies.contains(c)),
        ];

        if (!currencies.contains(controller.fromCurrency.value)) {
          controller.fromCurrency.value = currencies.first;
        }
        if (!currencies.contains(controller.toCurrency.value)) {
          controller.toCurrency.value = currencies.length > 1 ? currencies[1] : currencies.first;
        }

        final unitRate = (ratesModel != null && ratesModel.rates.isNotEmpty)
            ? ((ratesModel.rates[controller.toCurrency.value] ?? 1.0) /
            (ratesModel.rates[controller.fromCurrency.value] ?? 1.0))
            : 0.0;

        return RefreshIndicator(
          onRefresh: () async => controller.fetchRates(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            children: [
              // ==================== Card 1: Input Card ====================
              Card(
                elevation: 0,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'amount'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // حقل أدخل المبلغ
                      TextField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          suffixText: controller.fromCurrency.value,
                          suffixStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          filled: true,
                          fillColor: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade800
                              : Colors.teal.shade50.withOpacity(0.3),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Colors.teal, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Colors.teal, width: 2),
                          ),
                        ),
                        onChanged: (val) {
                          controller.amount.value = double.tryParse(val) ?? 0.0;
                        },
                      ),

                      const SizedBox(height: 20),

                      // اختيار العملات (From & To) مع زر التبديل
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // من (From)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'from'.tr,
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 6),
                                _buildCurrencySelectorButton(
                                  context: context,
                                  selectedCode: controller.fromCurrency.value,
                                  currencies: currencies,
                                  onSelected: (val) => controller.fromCurrency.value = val,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // زر التبديل الدائري (Swap Button)
                          Padding(
                            padding: const EdgeInsets.only(top: 18.0),
                            child: InkWell(
                              onTap: () => controller.swapCurrencies(),
                              borderRadius: BorderRadius.circular(25),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.teal,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.swap_horiz, color: Colors.white, size: 22),
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // إلى (To)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'to'.tr,
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 6),
                                _buildCurrencySelectorButton(
                                  context: context,
                                  selectedCode: controller.toCurrency.value,
                                  currencies: currencies,
                                  onSelected: (val) => controller.toCurrency.value = val,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ==================== Card 2: Result Card ====================
              Container(
                decoration: BoxDecoration(
                  color: Colors.teal.shade800,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'you_receive'.tr,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${controller.convertedAmount.toStringAsFixed(2)} ${controller.toCurrency.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '1 ${controller.fromCurrency.value} = ${unitRate.toStringAsFixed(2)} ${controller.toCurrency.value}',
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.trending_up, color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ==================== Popular Rates Section ====================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'popular_rates'.tr,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.refresh, size: 14, color: Colors.teal),
                        const SizedBox(width: 4),
                        Text(
                          'rates_updated_live'.tr,
                          style: const TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              ...controller.getPopularRates().map((item) {
                final isPositive = (item['change'] as double) >= 0;
                final changeText = '${isPositive ? "+" : ""}${(item['change'] as double).toStringAsFixed(2)}%';

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                    child: Row(
                      children: [
                        Text(
                          item['pair'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const Spacer(),
                        Text(
                          (item['rate'] as double).toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          changeText,
                          style: TextStyle(
                            color: isPositive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  // زرار اختيار العملة اللي بيفتح نافذة البحث والأسماء
  Widget _buildCurrencySelectorButton({
    required BuildContext context,
    required String selectedCode,
    required List<String> currencies,
    required ValueChanged<String> onSelected,
  }) {
    final currencyName = controller.getCurrencyName(selectedCode);

    return InkWell(
      onTap: () => _showCurrencySearchBottomSheet(context, currencies, selectedCode, onSelected),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedCode,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currencyName,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.teal),
          ],
        ),
      ),
    );
  }

  // نافذة البحث عن العملات (BottomSheet with Search) المطابقة لـ Figma
  void _showCurrencySearchBottomSheet(
      BuildContext context,
      List<String> currencies,
      String currentSelected,
      ValueChanged<String> onSelected,
      ) {
    final RxString searchQuery = ''.obs;

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.65,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Choose currency',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // خانة البحث (Search Field)
            TextField(
              autofocus: true,
              onChanged: (val) => searchQuery.value = val,
              decoration: InputDecoration(
                hintText: 'Search currency',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // قائمة العملات المفلترة
            Expanded(
              child: Obx(() {
                final query = searchQuery.value.toLowerCase();
                final filteredList = currencies.where((code) {
                  final name = controller.getCurrencyName(code).toLowerCase();
                  return code.toLowerCase().contains(query) || name.contains(query);
                }).toList();

                if (filteredList.isEmpty) {
                  return const Center(child: Text('No currencies found'));
                }

                return ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final code = filteredList[index];
                    final name = controller.getCurrencyName(code);
                    final isSelected = code == currentSelected;

                    return ListTile(
                      onTap: () {
                        onSelected(code);
                        Get.back();
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      tileColor: isSelected ? Colors.teal.shade50 : null,
                      title: Text(
                        '$code - $name',
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.teal.shade800 : null,
                        ),
                      ),
                      trailing: isSelected ? const Icon(Icons.check, color: Colors.teal) : null,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}













/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/converter_controller.dart';

class ConverterScreen extends GetView<ConverterController> {
  const ConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('converter'.tr),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final ratesModel = controller.currencyRates.value;
        final List<String> allRatesKeys = (ratesModel != null && ratesModel.rates.isNotEmpty)
            ? ratesModel.rates.keys.toList()
            : ['EGP', 'USD', 'EUR', 'GBP', 'SAR', 'AED', 'KWD'];

        final popularCurrencies = ['EGP', 'USD', 'EUR', 'GBP', 'SAR', 'AED', 'KWD', 'QAR', 'JOD', 'BHD', 'OMR'];

        final currencies = [
          ...popularCurrencies.where((c) => allRatesKeys.contains(c)),
          ...allRatesKeys.where((c) => !popularCurrencies.contains(c)),
        ];

        if (!currencies.contains(controller.fromCurrency.value)) {
          controller.fromCurrency.value = currencies.first;
        }
        if (!currencies.contains(controller.toCurrency.value)) {
          controller.toCurrency.value = currencies.length > 1 ? currencies[1] : currencies.first;
        }

        return RefreshIndicator(
          onRefresh: () async => controller.fetchRates(),
          child: ListView( // 👈 هنا السر: لفين العناصر بـ ListView عشان تدعم السحب والـ RefreshIndicator
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            children: [
              // حقل إدخال المبلغ
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'أدخل المبلغ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money),
                ),
                onChanged: (val) {
                  controller.amount.value = double.tryParse(val) ?? 0.0;
                },
              ),

              const SizedBox(height: 25),

              // اختيار العملات
              Row(
                children: [
                  Expanded(
                    child: _buildCurrencySelector(
                      context: context,
                      label: 'من',
                      selectedCurrency: controller.fromCurrency.value,
                      currencies: currencies,
                      onSelected: (val) => controller.fromCurrency.value = val,
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.swapCurrencies(),
                    icon: const Icon(Icons.swap_horiz, size: 32, color: Colors.teal),
                  ),
                  Expanded(
                    child: _buildCurrencySelector(
                      context: context,
                      label: 'إلى',
                      selectedCurrency: controller.toCurrency.value,
                      currencies: currencies,
                      onSelected: (val) => controller.toCurrency.value = val,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // كارد النتيجة
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        '${controller.amount.value} ${controller.getCurrencyName(controller.fromCurrency.value)} =',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${controller.convertedAmount.toStringAsFixed(2)} ${controller.getCurrencyName(controller.toCurrency.value)}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'popular_rates'.tr,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.refresh, size: 14, color: Colors.teal),
                        const SizedBox(width: 4),
                        Text(
                          'rates_updated_live'.tr,
                          style: const TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              ...controller.getPopularRates().map((item) {
                final isPositive = (item['change'] as double) >= 0;
                final changeText = '${isPositive ? "+" : ""}${(item['change'] as double).toStringAsFixed(2)}%';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                    child: Row(
                      children: [
                        // اسم الزوج (مثل EUR / EGP)
                        Text(
                          item['pair'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Spacer(),
                        // سعر الصرف
                        Text(
                          (item['rate'] as double).toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 15),
                        // نسبة التغير مؤطرة باللون الأخضر أو الأحمر
                        Text(
                          changeText,
                          style: TextStyle(
                            color: isPositive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  // ودجت زر اختيار العملة يفتح نافذة سفلية مع البحث والأسماء
  Widget _buildCurrencySelector({
    required BuildContext context,
    required String label,
    required String selectedCurrency,
    required List<String> currencies,
    required ValueChanged<String> onSelected,
  }) {
    return InkWell(
      onTap: () => _showCurrencySearchSheet(context, currencies, onSelected),
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '$selectedCurrency (${controller.getCurrencyName(selectedCurrency)})',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  // نافذة البحث السفلية (Bottom Sheet with Search)
  void _showCurrencySearchSheet(
      BuildContext context,
      List<String> currencies,
      ValueChanged<String> onSelected,
      ) {
    final searchController = TextEditingController();
    final filteredCurrencies = currencies.obs;

    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
             Text(
              'choose_currency'.tr,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // حقل البحث
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'search_currency'.tr,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                final query = val.toLowerCase();
                filteredCurrencies.value = currencies.where((code) {
                  final name = controller.getCurrencyName(code).toLowerCase();
                  return code.toLowerCase().contains(query) || name.contains(query);
                }).toList();
              },
            ),
            const SizedBox(height: 12),
            // قائمة العملات
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: filteredCurrencies.length,
                itemBuilder: (context, index) {
                  final code = filteredCurrencies[index];
                  final name = controller.getCurrencyName(code);
                  return ListTile(
                    title: Text('$code - $name'),
                    onTap: () {
                      onSelected(code);
                      Get.back(); // إغلاق الشيت
                    },
                  );
                },
              )),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

 */