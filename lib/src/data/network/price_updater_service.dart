import 'dart:async';
import 'dart:collection';

import 'package:hermez/src/data/prices/price_in_network_repository.dart';
import 'package:hermez/src/domain/prices/currency.dart';
import 'package:hermez/src/domain/prices/price_token.dart';

abstract class IPriceUpdaterService {
  Future<List<PriceToken>> getTokensPrices();
  Future<PriceToken> getTokenPrice(int tokenId);
  Future<LinkedHashMap<String, dynamic>> getCurrenciesPrices();
  Future<LinkedHashMap<String, dynamic>> getCurrencyPrice(String currency);
}

class PriceUpdaterService implements IPriceUpdaterService {
  PriceInNetworkRepository _client;
  PriceUpdaterService(String base, String apiKey) {
    _client = new PriceInNetworkRepository(base, apiKey);
  }

  @override
  Future<List<PriceToken>> getTokensPrices() async {
    List<PriceToken> tokensPrices = await _client.getTokensPrices();
    return tokensPrices;
  }

  @override
  Future<PriceToken> getTokenPrice(int tokenId) async {
    PriceToken priceToken = await _client.getTokenPrice(tokenId);
    return priceToken;
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
