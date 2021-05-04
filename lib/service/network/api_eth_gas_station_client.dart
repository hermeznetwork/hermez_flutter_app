library api_testing_flutter_kata;

import 'dart:convert';
import 'dart:io';

import 'package:hermez/service/network/api_client_exceptions.dart';
import 'package:hermez/service/network/model/gas_price_response.dart';
import 'package:http/http.dart' as http2;

class ApiEthGasStationClient {
  final String _baseAddress;
  final String _apiKey;

  final String ETH_GAS_URL = "/api/ethgasAPI.json";

  ApiEthGasStationClient(this._baseAddress, this._apiKey);

  Future<GasPriceResponse> getGasPrice() async {
    final response = await _get(ETH_GAS_URL, null);
    GasPriceResponse gasPriceResponse;
    try {
      gasPriceResponse = GasPriceResponse.fromJson(json.decode(response.body));
    } catch (e) {
      print(e.toString());
    }
    return gasPriceResponse;
  }

  Future<http2.Response> _get(
      String endpoint, Map<String, String> queryParameters) async {
    try {
      var uri;
      if (queryParameters != null) {
        uri = Uri.https(_baseAddress, endpoint + '?api-key=' + this._apiKey,
            queryParameters);
      } else {
        uri = Uri.https(_baseAddress, endpoint + '?api-key=' + this._apiKey);
      }
      final response = await http2.get(
        uri,
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
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
