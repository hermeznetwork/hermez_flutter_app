import 'dart:async';
import 'package:built_collection/built_collection.dart';
import 'package:hermezwallet/model/account.dart';
import 'package:hermezwallet/model/token.dart';
import 'package:hermezwallet/model/transaction.dart';
import 'package:web3dart/web3dart.dart' as web3;

import 'configuration_service.dart';

abstract class IRollupService {
  Future<List<Account>> getAccounts(web3.EthereumAddress ethereumAddress);
  Future<Account> getAccount(web3.EthereumAddress ethereumAddress, int tokenId);
  Future<List<Transaction>> getTransactions(web3.EthereumAddress ethereumAddress);
  Future<List<Token>> getTokens();
}

class RollupService implements IRollupService {
  IConfigurationService _configService;
  RollupService(this._configService);

  final String mockedEthereumAddress = '0xaa942cfcd25ad4d90a62358b0dd84f33b398262a';

  @override
  Future<List<Account>> getAccounts(web3.EthereumAddress ethereumAddress) async {
    // TODO: implement getAccounts
    return BuiltList<Account>().toList();// List.of(Account());
  }

  @override
  Future<Account> getAccount(web3.EthereumAddress ethereumAddress, int tokenId) async {
    // TODO: implement getAccount
    return Account();
  }


  @override
  Future<List<Token>> getTokens() async {
    // TODO: implement getTokens
    return BuiltList<Token>().toList();
  }

  @override
  Future<List<Transaction>> getTransactions(web3.EthereumAddress ethereumAddress) async {
    // TODO: implement getTransactions
    return BuiltList<Transaction>().toList();
  }
}
