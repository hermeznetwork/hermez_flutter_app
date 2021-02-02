import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:hermez/service/network/api_client.dart';
import 'package:hermez/service/network/api_exchange_rate_client.dart';
import 'package:hermez/service/network/model/account_request.dart';
import 'package:hermez/service/network/model/accounts_request.dart';
import 'package:hermez/service/network/model/exit.dart';
import 'package:hermez/service/network/model/exits_request.dart';
import 'package:hermez/service/network/model/rates_request.dart';
import 'package:hermez/service/network/model/recommended_fee.dart';
import 'package:hermez/service/network/model/transaction.dart';
import 'package:hermez_plugin/addresses.dart' as addresses;
import 'package:hermez_plugin/constants.dart';
import 'package:hermez_plugin/hermez_wallet.dart';
import 'package:hermez_plugin/model/account.dart';
import 'package:hermez_plugin/model/token.dart';
import 'package:hermez_plugin/tx.dart' as tx;
import 'package:web3dart/web3dart.dart' as web3;

import 'configuration_service.dart';

abstract class IHermezService {
  Future<List<Account>> getAccounts(
      web3.EthereumAddress ethereumAddress, List<int> tokenIds);
  Future<Account> getAccount(String accountIndex);
  Future<List<Exit>> getExits(web3.EthereumAddress ethereumAddress);
  Future<List<Transaction>> getTransactions(
      web3.EthereumAddress ethereumAddress);
  Future<List<Token>> getTokens();
  Future<bool> deposit(
      BigInt amount, String hezEthereumAddress, Token token, String babyJubJub,
      {int gasLimit = GAS_LIMIT, int gasMultiplier = GAS_MULTIPLIER});
  //Future<bool> withdraw(BigInt amount);
  Future<bool> sendL2Transaction(Transaction transaction, String bjj);
}

class HermezService implements IHermezService {
  String _baseUrl;
  final web3.Web3Client client;
  String _exchangeUrl;
  IConfigurationService _configService;
  HermezService(
      this._baseUrl, this.client, this._exchangeUrl, this._configService);

  ApiClient _apiClient() => ApiClient(this._baseUrl);
  ApiExchangeRateClient _apiExchangeRateClient() =>
      ApiExchangeRateClient(_exchangeUrl);

  @override
  Future<List<Account>> getAccounts(
      web3.EthereumAddress ethereumAddress, List<int> tokenIds) async {
    AccountsRequest accountsRequest = new AccountsRequest(
        hezEthereumAddress: addresses.getHermezAddress(ethereumAddress.hex),
        tokenIds: tokenIds);
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

  Future<void> generateAndSendL2Tx(
      Transaction transaction, HermezWallet wallet, Token token) async {
    tx.generateAndSendL2Tx(transaction, wallet, token);
  }

  @override
  Future<bool> sendL2Transaction(Transaction transaction, String bJJ) {
    return _apiClient().sendL2Transaction(transaction, bJJ);
  }

  @override
  Future<List<Exit>> getExits(web3.EthereumAddress ethereumAddress) {
    ExitsRequest exitsRequest = new ExitsRequest(
        hezEthereumAddress: addresses.getHermezAddress(ethereumAddress.hex),
        onlyPendingWithdraws: true);
    return _apiClient().getExits(exitsRequest);
  }

  @override
  Future<Exit> getExit(int batchNum, String accountIndex) {
    return _apiClient().getExit(batchNum, accountIndex);
  }

  Future<RecommendedFee> getRecommendedFee() async {
    return _apiClient().getRecommendedFees();
  }

  /// Makes a deposit.
  /// It detects if it's a 'createAccountDeposit' or a 'deposit' and prepares the parameters accordingly.
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
  Future<bool> deposit(
      BigInt amount, String hezEthereumAddress, Token token, String babyJubJub,
      {int gasLimit = GAS_LIMIT, int gasMultiplier = GAS_MULTIPLIER}) async {
    return tx.deposit(amount, hezEthereumAddress, token, babyJubJub, client);
  }

  Future<void> withdraw(BigInt amount, Account account, Exit exit,
      bool completeDelayedWithdrawal, bool instantWithdrawal,
      {int gasLimit = GAS_LIMIT, int gasMultiplier = GAS_MULTIPLIER}) async {
    final withdrawalId = account.accountIndex + exit.merkleProof.root;

    if (!completeDelayedWithdrawal) {
      tx.withdraw(
          amount,
          account.accountIndex,
          account.token,
          /*babyjubjub*/ null,
          BigInt.from(exit.batchNum),
          exit.merkleProof.siblings,
          client);
    } else {
      tx.delayedWithdraw(
          /*wallet.hermezAddress*/ null,
          account.token,
          client);
    }
  }

  Future<void> forceExit(BigInt amount, Account account,
      {int gasLimit = GAS_LIMIT, int gasMultiplier = GAS_MULTIPLIER}) async {
    tx.forceExit(amount, account.accountIndex, account.token, client);
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
