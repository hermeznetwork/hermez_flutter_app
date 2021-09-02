library api_testing_flutter_kata;

import 'dart:convert';
import 'dart:io';

import 'package:hermez/service/network/api_client_exceptions.dart';
import 'package:hermez/service/network/model/purchases_response.dart';
import 'package:http/http.dart' as http2;
import 'package:visa/auth-data.dart';
import 'package:visa/engine/oauth.dart';
import 'package:visa/engine/simple-auth.dart';
import 'package:visa/engine/visa.dart';

import 'model/access_token_response.dart';
import 'model/credential_response.dart';
import 'model/pay_provider.dart';
import 'model/products_response.dart';
import 'model/providers_response.dart';
import 'model/purchase.dart';

class ApiHermezPayClient implements Visa {
  final String _baseAddress;

  final String INIT_CREDENTIALS_URL = "/oauth2/initializecredentials";
  final String TOKEN_URL = "/oauth2/token";
  final String CREDENTIALS_URL = "/oauth2/credentials/";
  final String HEALTH_URL = "/health";
  final String METRICS_URL = "/metrics";
  final String V1_URL = "/v1";
  final String PURCHASE_URL = "/purchase";
  final String PROVIDERS_URL = "/providers";
  final String PRODUCTS_URL = "/products";
  final String CONFIRM_URL = "/confirm";
  final String ACCOUNT_URL = "/account";

  ApiHermezPayClient(this._baseAddress);

  Future<CredentialResponse> initCredential() async {
    Map<String, dynamic> body = {};
    body['user_id'] = 2;
    body['legacy_partner_id'] = "old";
    body['name'] = "Pepe";
    final response = await _post(INIT_CREDENTIALS_URL, body, null);
    final CredentialResponse credentialResponse =
        CredentialResponse.fromJson(json.decode(response.body));
    return credentialResponse;
  }

  Future<AccessTokenResponse> getAccessToken(
      String username, String password) async {
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    final response = await _get(TOKEN_URL, null, basicAuth);
    final AccessTokenResponse accessTokenResponse =
        AccessTokenResponse.fromJson(json.decode(response.body));
    return accessTokenResponse;
  }

  Future<CredentialResponse> getCredential(int userId, String token) async {
    final response =
        await _get(CREDENTIALS_URL + '$userId', null, 'Bearer $token');
    final CredentialResponse credentialResponse =
        CredentialResponse.fromJson(json.decode(response.body));
    return credentialResponse;
  }

  Future<bool> requestPurchase(Purchase purchase, String token) async {
    final response =
        await _post(V1_URL + PURCHASE_URL, purchase.toJson(), token);
    return response.statusCode == 200;
  }

  Future<String> confirmPurchase(String l2TxId, String token) async {
    final response = await _post(
        V1_URL + PURCHASE_URL + '/$l2TxId' + CONFIRM_URL, null, token);
    final String l1TxId = json.decode(response.body);
    return l1TxId;
  }

  Future<PurchasesResponse> getAllPurchases(
      String hermezAddress, String token) async {
    final response = await _get(
        V1_URL + ACCOUNT_URL + '/$hermezAddress' + PURCHASE_URL,
        null,
        'Bearer $token');
    final PurchasesResponse purchaseResponse =
        PurchasesResponse.fromJson(json.decode(response.body));
    return purchaseResponse;
  }

  Future<PurchasesResponse> getPurchase(String l2TxId, String token) async {
    final response =
        await _get(V1_URL + PURCHASE_URL + '/$l2TxId', null, 'Bearer $token');
    final PurchasesResponse purchaseResponse =
        PurchasesResponse.fromJson(json.decode(response.body));
    return purchaseResponse;
  }

  Future<ProvidersResponse> getAllProviders(String token) async {
    final response = await _get(V1_URL + PROVIDERS_URL, null, 'Bearer $token');
    final ProvidersResponse providersResponse =
        ProvidersResponse.fromJson(json.decode(response.body));
    return providersResponse;
  }

  Future<PayProvider> getProvider(int providerId, String token) async {
    final response = await _get(
        V1_URL + PROVIDERS_URL + '/$providerId', null, 'Bearer $token');
    final PayProvider payProvider =
        PayProvider.fromJson(json.decode(response.body));
    return payProvider;
  }

  Future<ProductsResponse> getAllProducts(int providerId, String token) async {
    final response = await _get(
        V1_URL + PRODUCTS_URL + '/$providerId', null, 'Bearer $token');
    final ProductsResponse productsResponse =
        ProductsResponse.fromJson(json.decode(response.body));
    return productsResponse;
  }

  Future<http2.Response> _get(String endpoint,
      Map<String, String> queryParameters, String basicAuth) async {
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
          HttpHeaders.authorizationHeader: basicAuth != null ? basicAuth : ''
        },
      );

      return returnResponseOrThrowException(response);
    } on IOException catch (e) {
      print(e.toString());
      throw NetworkException();
    }
  }

  Future<http2.Response> _post(
      String endpoint, Map<String, dynamic> body, String token) async {
    try {
      var url = Uri.https(_baseAddress, endpoint);
      final response = await http2.post(
        url,
        body: json.encode(body),
        headers: {
          HttpHeaders.acceptHeader: '*/*',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: token != null ? 'Bearer $token' : ''
        },
      );

      return returnResponseOrThrowException(response);
    } on IOException {
      throw NetworkException();
    }
  }

  Future<http2.Response> _put(dynamic task) async {
    try {
      var url = Uri.parse('$_baseAddress/todos/${task.id}');
      final response = await http2.put(
        url,
        body: json.encode(task.toJson()),
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );

      return returnResponseOrThrowException(response);
    } on IOException {
      throw NetworkException();
    }
  }

  Future<http2.Response> _delete(String id) async {
    try {
      var url = Uri.parse('$_baseAddress/todos/$id');
      final response = await http2.delete(
        url,
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
        },
      );

      return returnResponseOrThrowException(response);
    } on IOException {
      throw NetworkException();
    }
  }

  /// This function combines information
  /// from the user [userJson] and auth response [responseData]
  /// to build an [AuthData] object.
  @override
  AuthData authData(
      Map<String, dynamic> userJson, Map<String, String> responseData) {
    final String accessToken = responseData[OAuth.TOKEN_KEY];
    final String userId = userJson['id'] as String;
    final String avatar = userJson['avatar'] as String;
    final String profileImgUrl = 'https://cdn.discordapp.com/'
        'avatars/$userId/$avatar.png';

    return AuthData(
        clientID: responseData['clientID'],
        accessToken: accessToken,
        userID: userId,
        email: userJson['email'] as String,
        profileImgUrl: profileImgUrl,
        response: responseData,
        userJson: userJson);
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

  @override
  bool debugMode;

  @override
  set debug(bool debugMode) {
    this.debugMode = debugMode;
  }

  // SimpleAuth instance
  SimpleAuth visa;
}
