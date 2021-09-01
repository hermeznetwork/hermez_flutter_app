import 'dart:async';

import 'package:hermez/service/network/model/access_token_response.dart';

import 'configuration_service.dart';
import 'network/api_hermez_pay_client.dart';
import 'network/model/credential_response.dart';
import 'network/model/purchase.dart';

abstract class IHermezPayService {
  Future<CredentialResponse> initCredential();
  Future<String> getAccessToken(String username, String password);
  Future<CredentialResponse> getCredential(int userId, String token);
  Future<bool> requestPurchase(Purchase purchase, String token);
  Future<List<Purchase>> getAllPurchases(String hermezAddress, String token);
  Future<Purchase> getPurchase(String l2TxId, String token);
  Future<String> confirmPurchase(String l2TxId, String token);
}

class HermezPayService implements IHermezPayService {
  String _baseUrl;
  IConfigurationService _configService;
  HermezPayService(this._baseUrl, this._configService);

  ApiHermezPayClient _apiHermezPayClient() {
    return ApiHermezPayClient(_baseUrl);
  }

  @override
  Future<CredentialResponse> initCredential() async {
    CredentialResponse credentialResponse =
        await _apiHermezPayClient().initCredential();
    return credentialResponse;
  }

  @override
  Future<CredentialResponse> getCredential(int userId, String token) async {
    CredentialResponse credentialResponse =
        await _apiHermezPayClient().getCredential(userId, token);
    return credentialResponse;
  }

  @override
  Future<String> getAccessToken(String username, String password) async {
    AccessTokenResponse accessTokenResponse =
        await _apiHermezPayClient().getAccessToken(username, password);
    return accessTokenResponse.accessToken;
  }

  @override
  Future<bool> requestPurchase(Purchase purchase, String token) async {
    bool response =
        await _apiHermezPayClient().requestPurchase(purchase, token);
    return response;
  }

  @override
  Future<List<Purchase>> getAllPurchases(
      String hermezAddress, String token) async {
    final response =
        await _apiHermezPayClient().getAllPurchases(hermezAddress, token);
    if (response != null &&
        response.purchases != null &&
        response.purchases.length > 0) {
      return response.purchases;
    }
    return null;
  }

  @override
  Future<Purchase> getPurchase(String l2TxId, String token) async {
    final response = await _apiHermezPayClient().getPurchase(l2TxId, token);
    if (response != null &&
        response.purchases != null &&
        response.purchases.length > 0) {
      return response.purchases[0];
    }
    return null;
  }

  @override
  Future<String> confirmPurchase(String l2TxId, String token) async {
    final response = await _apiHermezPayClient().confirmPurchase(l2TxId, token);
    return response;
  }
}
