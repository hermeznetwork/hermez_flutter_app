import 'dart:convert';
import 'dart:io';

import 'package:hermez/src/common/api/api_base_client.dart';
import 'package:hermez/src/common/api/api_client_exceptions.dart';
import 'package:hermez/src/data/prices/currencies_response.dart';
import 'package:hermez/src/data/prices/tokens_response.dart';
import 'package:hermez/src/domain/prices/currency.dart';
import 'package:hermez/src/domain/prices/price_repository.dart';
import 'package:hermez/src/domain/prices/price_token.dart';
import 'package:http/http.dart' as http2;

class PriceInNetworkRepository extends ApiBaseClient
    implements PriceRepository {
  final String _baseAddress;
  final String _apiKey;

  final String TOKENS_URL = "/v1/tokens";
  final String CURRENCIES_URL = "/v1/currencies";

  PriceInNetworkRepository(this._baseAddress, this._apiKey)
      : super(_baseAddress);

  @override
  Future<List<PriceToken>> getTokensPrices([List<int> tokenIds]) async {
    final response = await get(TOKENS_URL, null);
    final TokensResponse tokensResponse =
        TokensResponse.fromJson(json.decode(response.body));
    return tokensResponse.tokens;
  }

  @override
  Future<PriceToken> getTokenPrice(int tokenId) async {
    final response = await get(TOKENS_URL + "/" + tokenId.toString(), null);
    final PriceToken priceToken =
        PriceToken.fromJson(json.decode(response.body));
    return priceToken;
  }

  @override
  Future<List<Currency>> getCurrenciesPrices() async {
    final response = await get(CURRENCIES_URL, null);
    final CurrenciesResponse currenciesResponse =
        CurrenciesResponse.fromJson(json.decode(response.body));
    return currenciesResponse.currencies;
  }

  @override
  Future<Currency> getCurrencyPrice(String currency) async {
    final response = await get(CURRENCIES_URL + "/" + currency, null);
    final Currency currencyResponse =
        Currency.fromJson(json.decode(response.body));
    return currencyResponse;
  }

  @override
  Future<http2.Response> get(
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
}
