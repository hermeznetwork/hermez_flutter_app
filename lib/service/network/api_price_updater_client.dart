library api_testing_flutter_kata;

import 'dart:convert';
import 'dart:io';

import 'package:hermez/service/network/api_client_exceptions.dart';
import 'package:hermez/service/network/model/currencies_response.dart';
import 'package:http/http.dart' as http2;

import 'model/currency.dart';
import 'model/price_token.dart';
import 'model/tokens_response.dart';

class ApiPriceUpdaterClient {
  final String _baseAddress;
  final String _apiKey;

  final String TOKENS_URL = "/v1/tokens";
  final String CURRENCIES_URL = "/v1/currencies";

  ApiPriceUpdaterClient(this._baseAddress, this._apiKey);

  // TOKENS PRICES
  Future<List<PriceToken>> getTokensPrices() async {
    final response = await _get(TOKENS_URL, null);
    final TokensResponse tokensResponse =
        TokensResponse.fromJson(json.decode(response.body));
    return tokensResponse.tokens;
  }

  // TOKEN PRICE
  Future<PriceToken> getTokenPrice(int tokenId) async {
    final response = await _get(TOKENS_URL + "/" + tokenId.toString(), null);
    final PriceToken priceToken =
        PriceToken.fromJson(json.decode(response.body));
    return priceToken;
  }

  // CURRENCIES PRICES
  Future<List<Currency>> getCurrenciesPrices() async {
    final response = await _get(CURRENCIES_URL, null);
    final CurrenciesResponse currenciesResponse =
        CurrenciesResponse.fromJson(json.decode(response.body));
    return currenciesResponse.currencies;
  }

  // CURRENCY PRICE
  Future<Currency> getCurrencyPrice(String currency) async {
    final response = await _get(CURRENCIES_URL + "/" + currency, null);
    final Currency currencyResponse =
        Currency.fromJson(json.decode(response.body));
    return currencyResponse;
  }

  Future<http2.Response> _get(
      String endpoint, Map<String, String> queryParameters) async {
    try {
      var uri;
      if (queryParameters != null) {
        uri = Uri.https(_baseAddress, endpoint, queryParameters);
      } else {
        uri = Uri.https(_baseAddress, endpoint);
      }
      final response = await http2.get(
        uri,
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          "X-API-KEY": _apiKey
        },
      );

      return returnResponseOrThrowException(response);
    } on IOException catch (e) {
      print(e.toString());
      throw NetworkException();
    }
  }

  http2.Response returnResponseOrThrowException(http2.Response response) {
    if (response.statusCode == 404) {
      // Not found
      throw ItemNotFoundException();
    } else if (response.statusCode == 500) {
      throw InternalServerErrorException();
    } else if (response.statusCode > 400) {
      throw UnknownApiException(response.statusCode);
    } else {
      return response;
    }
  }
}
