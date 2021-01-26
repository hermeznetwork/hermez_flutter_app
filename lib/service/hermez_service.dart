import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:hermez/service/network/api_client.dart';
import 'package:hermez/service/network/api_exchange_rate_client.dart';
import 'package:hermez/service/network/model/account.dart';
import 'package:hermez/service/network/model/account_request.dart';
import 'package:hermez/service/network/model/accounts_request.dart';
import 'package:hermez/service/network/model/exit.dart';
import 'package:hermez/service/network/model/exits_request.dart';
import 'package:hermez/service/network/model/rates_request.dart';
import 'package:hermez/service/network/model/transaction.dart';
import 'package:hermez_plugin/addresses.dart' as addresses;
import 'package:web3dart/web3dart.dart' as web3;

import 'configuration_service.dart';
import 'network/model/token.dart';

abstract class IHermezService {
  Future<List<Account>> getAccounts(web3.EthereumAddress ethereumAddress);
  Future<Account> getAccount(String accountIndex);
  Future<List<Transaction>> getTransactions(
      web3.EthereumAddress ethereumAddress);
  Future<bool> sendL2Transaction(Transaction transaction);
  Future<List<Exit>> getExits(web3.EthereumAddress ethereumAddress);
  Future<List<Token>> getTokens();
  Future<void> deposit(BigInt amount, String hezEthereumAddress, Token token,
      String babyjubjub, int gasLimit, int gasMultiplier);
}

class HermezService implements IHermezService {
  String _baseUrl;
  String _exchangeUrl;
  IConfigurationService _configService;
  HermezService(this._baseUrl, this._exchangeUrl, this._configService);

  ApiClient _apiClient() => ApiClient(this._baseUrl);
  ApiExchangeRateClient _apiExchangeRateClient() =>
      ApiExchangeRateClient(_exchangeUrl);

  //final String mockedEthereumAddress =
  //    '0xaa942cfcd25ad4d90a62358b0dd84f33b398262a';

  //String url = 'https://jsonplaceholder.typicode.com/posts';

  @override
  Future<List<Account>> getAccounts(
      web3.EthereumAddress ethereumAddress) async {
    AccountsRequest accountsRequest = new AccountsRequest(
        hezEthereumAddress: addresses.getHermezAddress(ethereumAddress.hex),
        tokenIds: [3, 87, 91]);
    return _apiClient().getAccounts(accountsRequest);
  }

  @override
  Future<Account> getAccount(String accountIndex) async {
    AccountRequest accountRequest =
        new AccountRequest(accountIndex: accountIndex);
    return _apiClient().getAccount(accountRequest);
  }

  @override
  Future<List<Token>> getTokens() async {
    return _apiClient().getSupportedTokens(null);
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

  @override
  Future<bool> sendL2Transaction(Transaction transaction) {
    return _apiClient().sendL2Transaction(transaction);
  }

  @override
  Future<List<Exit>> getExits(web3.EthereumAddress ethereumAddress) {
    ExitsRequest exitsRequest = new ExitsRequest(
        hezEthereumAddress: addresses.getHermezAddress(ethereumAddress.hex),
        onlyPendingWithdraws: true);
    return _apiClient().getExits(exitsRequest);
  }

  /// Makes a deposit.
  /// It detects if it's a 'createAccountDeposit' or a 'deposit' and prepares the parameters accodingly.
  /// Detects if it's an Ether, ERC 20 or ERC 777 token and sends the transaction accordingly.
  /// @param {BigInt} amount - The amount to be deposited
  /// @param {String} hezEthereumAddress - The Hermez address of the transaction sender
  /// @param {Object} token - The token information object as returned from the API
  /// @param {String} babyJubJub - The compressed BabyJubJub in hexadecimal format of the transaction sender.
  /// @param {String} providerUrl - Network url (i.e, http://localhost:8545). Optional
  /// @param {Object} signerData - Signer data used to build a Signer to send the transaction
  /// @param {Number} gasLimit - Optional gas limit
  /// @param {Number} gasMultiplier - Optional gas multiplier
  /// @returns {Promise} transaction parameters
  @override
  Future<void> deposit(BigInt amount, String hezEthereumAddress, Token token,
      String babyjubjub, int gasLimit, int gasMultiplier) {
    /*tx.deposit(amount, addresses.getHermezAddress(ethereumAddress.hex),
        account.token, /*babyJubJub*/, null, null);*/

    final ethereumAddress = addresses.getEthereumAddress(hezEthereumAddress);
  }

  @override
  Future<double> getEURUSDExchangeRatio() async {
    final request = RatesRequest.fromJson({
      "base": "USD",
      "symbols": {"EUR"},
    });
    double response = await _apiExchangeRateClient().getExchangeRates(request);
    return response;
  }
}
