import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:hermez/model/account.dart';
import 'package:hermez/model/transaction.dart';
import 'package:hermez/service/network/api_client.dart';
import 'package:web3dart/web3dart.dart' as web3;

import 'configuration_service.dart';
import 'network/model/token.dart';

abstract class IHermezService {
  Future<List<Account>> getAccounts(web3.EthereumAddress ethereumAddress);
  Future<Account> getAccount(web3.EthereumAddress ethereumAddress, int tokenId);
  Future<List<Transaction>> getTransactions(
      web3.EthereumAddress ethereumAddress);
  Future<List<Token>> getTokens();
}

class HermezService implements IHermezService {
  String _baseUrl;
  IConfigurationService _configService;
  HermezService(this._baseUrl, this._configService);

  ApiClient _apiClient() => ApiClient(this._baseUrl);

  //final String mockedEthereumAddress =
  //    '0xaa942cfcd25ad4d90a62358b0dd84f33b398262a';

  //String url = 'https://jsonplaceholder.typicode.com/posts';

  @override
  Future<List<Account>> getAccounts(
      web3.EthereumAddress ethereumAddress) async {
    // TODO: implement getAccounts
    return BuiltList<Account>().toList(); // List.of(Account());
  }

  @override
  Future<Account> getAccount(
      web3.EthereumAddress ethereumAddress, int tokenId) async {
    // TODO: implement getAccount
    return Account();
  }

  @override
  Future<List<Token>> getTokens() async {
    return _apiClient().getSupportedTokens(null);
    // TODO: implement getTokens. Store in cache?
    //return BuiltList<Token>().toList();
  }

  Future<Token> getTokenById(int tokenId) {
    return _apiClient().getSupportedTokenById(tokenId.toString());
  }

  @override
  Future<List<Transaction>> getTransactions(
      web3.EthereumAddress ethereumAddress) async {
    // TODO: implement getTransactions
    return BuiltList<Transaction>().toList();
  }
}
