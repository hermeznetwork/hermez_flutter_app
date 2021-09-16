import 'dart:io';

import 'package:hermez/service/network/api_client_exceptions.dart';
import 'package:http/http.dart' as http2;

class ApiBaseClient {
  final String _baseAddress;

  ApiBaseClient(this._baseAddress);

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
