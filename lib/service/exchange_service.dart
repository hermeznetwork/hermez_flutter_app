import 'dart:async';
import 'dart:collection';

import 'package:hermez/service/network/api_exchange_rate_client.dart';
import 'package:hermez_sdk/api.dart' as api;

import 'network/model/currency.dart';

abstract class IExchangeService {
  Future<LinkedHashMap<String, dynamic>> getFiatExchangeRates();
}

class ExchangeService implements IExchangeService {
  ExchangeService();

  ApiExchangeRateClient _apiExchangeRateClient() {
    String baseUrl = api.getBaseApiUrl();
    return ApiExchangeRateClient(baseUrl);
  }

  @override
  Future<LinkedHashMap<String, dynamic>> getFiatExchangeRates() async {
    LinkedHashMap<String, dynamic> result = LinkedHashMap<String, dynamic>();
    List<Currency> response = await _apiExchangeRateClient().getExchangeRates();
    response.forEach((currency) {
      result[currency.currency] = currency.price;
    });
    return result;
  }
}
