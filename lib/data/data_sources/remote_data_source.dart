import 'package:get/get.dart';
import 'package:masrefi/data/models/currency_rates_model.dart';
import 'package:masrefi/data/data_sources/api_link.dart';

abstract class RemoteDataSource {
  Future<CurrencyRatesModel> getLiveCurrencyRates();
}

class RemoteDataSourceImpl extends GetConnect implements RemoteDataSource {
  @override
  Future<CurrencyRatesModel> getLiveCurrencyRates() async {
    try {
      // GetConnect sends the GET request directly using linkServerName
      final response = await get(linkServerName);

      if (response.hasError) {
        throw Exception(response.statusText ?? 'Failed to fetch currency rates');
      }

      // response.body is already parsed as Map<String, dynamic> in GetConnect
      return CurrencyRatesModel.fromJson(response.body);
    } catch (e) {
      throw Exception('RemoteDataSource Error: $e');
    }
  }
}