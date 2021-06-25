import 'dart:async';
import 'dart:collection';

import 'package:hermez/service/network/api_exchange_rate_client.dart';
import 'package:hermez/service/network/model/rates_request.dart';

abstract class IExchangeService {
  Future<LinkedHashMap<String, dynamic>> getFiatExchangeRates(
      List<String> symbols);
}

class ExchangeService implements IExchangeService {
  String _exchangeUrl;
  String _exchangeApiKey;
  ExchangeService(this._exchangeUrl, this._exchangeApiKey);

  ApiExchangeRateClient _apiExchangeRateClient() =>
      ApiExchangeRateClient(_exchangeUrl, _exchangeApiKey);

  @override
  Future<LinkedHashMap<String, dynamic>> getFiatExchangeRates(
      List<String> symbols) async {
    final request = RatesRequest.fromJson(
        {"base": "USD", "symbols": symbols, "access_key": _exchangeApiKey});
    LinkedHashMap<String, dynamic> response =
        await _apiExchangeRateClient().getExchangeRates(request);
    return response;
  }
}
