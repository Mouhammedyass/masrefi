class CurrencyRatesModel {
  final String baseCurrency;
  final Map<String, double> rates;
  final String lastUpdated;

  const CurrencyRatesModel({
    required this.baseCurrency,
    required this.rates,
    required this.lastUpdated,
  });

  factory CurrencyRatesModel.fromJson(Map<String, dynamic> json) {
    Map<String, double> parsedRates = {};

    // بناخد خريطة الاسعار من المفتاح الصحيح 'conversion_rates'
    if (json['conversion_rates'] != null) {
      (json['conversion_rates'] as Map<String, dynamic>).forEach((key, value) {
        parsedRates[key] = (value as num).toDouble();
      });
    }

    return CurrencyRatesModel(
      baseCurrency: json['base_code'] ?? 'USD', // نفس اسم الـ Key في الـ API
      rates: parsedRates,
      lastUpdated: json['time_last_update_utc'] ?? '', // نفس اسم الـ Key في الـ API
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_code': baseCurrency,
      'conversion_rates': rates,
      'time_last_update_utc': lastUpdated,
    };
  }
}