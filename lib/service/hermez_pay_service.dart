import 'dart:async';

import 'configuration_service.dart';
import 'network/api_hermez_pay_client.dart';
import 'network/model/pay_product.dart';
import 'network/model/pay_provider.dart';
import 'network/model/purchase.dart';

abstract class IHermezPayService {
  Future<bool> requestPurchase(Purchase purchase);
  Future<List<Purchase>> getAllPurchases(String hermezAddress);
  Future<Purchase> getPurchase(String l2TxId);
  Future<String> confirmPurchase(String l2TxId);
  Future<List<PayProvider>> getAllProviders();
  Future<PayProvider> getProvider(int providerId);
  Future<List<PayProduct>> getAllProducts(int providerId);
}

class HermezPayService implements IHermezPayService {
  String _baseUrl;
  IConfigurationService _configService;
  ApiHermezPayClient _apiClient;
  HermezPayService(this._baseUrl, this._configService);

  ApiHermezPayClient _apiHermezPayClient() {
    if (_apiClient == null) {
      _apiClient = ApiHermezPayClient(_baseUrl, _configService);
    }
    return _apiClient;
  }

  @override
  Future<bool> requestPurchase(Purchase purchase) async {
    bool response = await _apiHermezPayClient().requestPurchase(purchase);
    return response;
  }

  @override
  Future<List<Purchase>> getAllPurchases(String hermezAddress) async {
    final response = await _apiHermezPayClient().getAllPurchases(hermezAddress);
    if (response != null &&
        response.purchases != null &&
        response.purchases.length > 0) {
      return response.purchases;
    }
    return null;
  }

  @override
  Future<Purchase> getPurchase(String l2TxId) async {
    final response = await _apiHermezPayClient().getPurchase(l2TxId);
    if (response != null &&
        response.purchases != null &&
        response.purchases.length > 0) {
      return response.purchases[0];
    }
    return null;
  }

  @override
  Future<String> confirmPurchase(String l2TxId) async {
    final response = await _apiHermezPayClient().confirmPurchase(l2TxId);
    return response;
  }

  Future<List<PayProvider>> getAllProviders() async {
    final response = await _apiHermezPayClient().getAllProviders();
    if (response != null &&
        response.providers != null &&
        response.providers.length > 0) {
      return response.providers;
    }
    return null;
  }

  Future<PayProvider> getProvider(int providerId) async {
    final response = await _apiHermezPayClient().getProvider(providerId);
    return response;
  }

  Future<List<PayProduct>> getAllProducts(int providerId) async {
    final response = await _apiHermezPayClient().getAllProducts(providerId);
    if (response != null &&
        response.products != null &&
        response.products.length > 0) {
      return response.products;
    }
    return null;
  }
}
