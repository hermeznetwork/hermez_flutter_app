import 'dart:async';
import 'dart:collection';

import 'package:hermez/service/network/api_price_updater_client.dart';

import 'network/model/currency.dart';
import 'network/model/price_token.dart';

abstract class IPriceUpdaterService {
  Future<LinkedHashMap<String, dynamic>> getTokensPrices();
  Future<LinkedHashMap<String, dynamic>> getTokenPrice(int tokenId);
  Future<LinkedHashMap<String, dynamic>> getCurrenciesPrices();
  Future<LinkedHashMap<String, dynamic>> getCurrencyPrice(String currency);
}

class PriceUpdaterService implements IPriceUpdaterService {
  ApiPriceUpdaterClient _client;
  PriceUpdaterService(String base, String apiKey) {
    _client = new ApiPriceUpdaterClient(base, apiKey);
  }

  @override
  Future<LinkedHashMap<String, dynamic>> getTokensPrices() async {
    LinkedHashMap<String, dynamic> result = LinkedHashMap<String, dynamic>();
    List<PriceToken> response = await _client.getTokensPrices();
    response.forEach((token) {
      result[token.symbol] = token;
    });
    return result;
  }

  @override
  Future<LinkedHashMap<String, dynamic>> getTokenPrice(int tokenId) async {
    LinkedHashMap<String, dynamic> result = LinkedHashMap<String, dynamic>();
    PriceToken response = await _client.getTokenPrice(tokenId);
    if (response != null) {
      result[response.symbol] = response;
    }
    return result;
  }

  @override
  Future<LinkedHashMap<String, dynamic>> getCurrenciesPrices() async {
    LinkedHashMap<String, dynamic> result = LinkedHashMap<String, dynamic>();
    List<Currency> response = await _client.getCurrenciesPrices();
    response.forEach((currency) {
      result[currency.currency] = currency.price;
    });
    return result;
  }

  @override
  Future<LinkedHashMap<String, dynamic>> getCurrencyPrice(
      String currency) async {
    LinkedHashMap<String, dynamic> result = LinkedHashMap<String, dynamic>();
    Currency response = await _client.getCurrencyPrice(currency);
    if (response != null) {
      result[response.currency] = response.price;
    }
    return result;
  }
}
