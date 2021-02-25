import 'dart:async';

import 'package:hermez/service/network/api_exchange_rate_client.dart';
import 'package:hermez/service/network/model/rates_request.dart';
import 'package:hermez_plugin/addresses.dart' as addresses;
import 'package:hermez_plugin/api.dart' as api;
import 'package:hermez_plugin/api.dart';
import 'package:hermez_plugin/constants.dart';
import 'package:hermez_plugin/hermez_compressed_amount.dart';
import 'package:hermez_plugin/hermez_wallet.dart';
import 'package:hermez_plugin/model/account.dart';
import 'package:hermez_plugin/model/coordinator.dart';
import 'package:hermez_plugin/model/create_account_authorization.dart';
import 'package:hermez_plugin/model/exit.dart';
import 'package:hermez_plugin/model/exits_request.dart';
import 'package:hermez_plugin/model/forged_transaction.dart';
import 'package:hermez_plugin/model/forged_transactions_request.dart';
import 'package:hermez_plugin/model/recommended_fee.dart';
import 'package:hermez_plugin/model/state_response.dart';
import 'package:hermez_plugin/model/token.dart';
import 'package:hermez_plugin/model/tokens_request.dart';
import 'package:hermez_plugin/model/transaction.dart';
import 'package:hermez_plugin/tx.dart' as tx;
import 'package:web3dart/web3dart.dart' as web3;

import 'configuration_service.dart';

abstract class IHermezService {
  Future<StateResponse> getState();
  Future<bool> authorizeAccountCreation(
      web3.EthereumAddress ethereumAddress, String bjj, String signature);
  Future<CreateAccountAuthorization> getCreateAccountAuthorization(
      web3.EthereumAddress ethereumAddress);
  Future<List<Account>> getAccounts(
      web3.EthereumAddress ethereumAddress, List<int> tokenIds,
      {int fromItem = 0,
      PaginationOrder order = PaginationOrder.ASC,
      int limit = DEFAULT_PAGE_SIZE});
  Future<Account> getAccount(String accountIndex);
  Future<List<Exit>> getExits(web3.EthereumAddress ethereumAddress);
  Future<List<Coordinator>> getCoordinators(
      String forgerAddr, String bidderAddr);
  Future<List<ForgedTransaction>> getForgedTransactions(
      ForgedTransactionsRequest request);
  Future<ForgedTransaction> getTransactionById(String transactionId);
  Future<Transaction> getPoolTransactionById(String transactionId);
  Future<List<Token>> getTokens();
  Future<Token> getTokenById(int tokenId);
  Future<bool> deposit(BigInt amount, String hezEthereumAddress, Token token,
      String babyJubJub, String privateKey,
      {int gasLimit = GAS_LIMIT, int gasMultiplier = GAS_MULTIPLIER});
  Future<void> withdraw(BigInt amount, Account account, Exit exit,
      bool completeDelayedWithdrawal, bool instantWithdrawal,
      {int gasLimit = GAS_LIMIT, int gasMultiplier = GAS_MULTIPLIER});
  Future<void> generateAndSendL2Tx(
      Transaction transaction, HermezWallet wallet, Token token);
  Future<bool> sendL2Transaction(Transaction transaction, String bjj);
  Future<RecommendedFee> getRecommendedFee();
}

class HermezService implements IHermezService {
  final web3.Web3Client client;
  String _exchangeUrl;
  IConfigurationService _configService;
  HermezService(this.client, this._exchangeUrl, this._configService);

  ApiExchangeRateClient _apiExchangeRateClient() =>
      ApiExchangeRateClient(_exchangeUrl);

  @override
  Future<StateResponse> getState() async {
    final StateResponse state = await api.getState();
    //api.setBaseApiUrl(state.network.nextForgers[0].coordinator.URL);
    return state;
  }

  @override
  Future<bool> authorizeAccountCreation(web3.EthereumAddress ethereumAddress,
      String bjj, String signature) async {
    final response = await api.postCreateAccountAuthorization(
        addresses.getHermezAddress(ethereumAddress.hex), bjj, signature);
    if (response != null) {
      return response.statusCode == 200;
    } else {
      return false;
    }
  }

  @override
  Future<CreateAccountAuthorization> getCreateAccountAuthorization(
      web3.EthereumAddress ethereumAddress) async {
    final response = await api.getCreateAccountAuthorization(
        addresses.getHermezAddress(ethereumAddress.hex));
    return response;
  }

  @override
  Future<List<Account>> getAccounts(
      web3.EthereumAddress ethereumAddress, List<int> tokenIds,
      {int fromItem = 0,
      PaginationOrder order = PaginationOrder.ASC,
      int limit = DEFAULT_PAGE_SIZE}) async {
    final accountsResponse = await api.getAccounts(
        addresses.getHermezAddress(ethereumAddress.hex), tokenIds,
        fromItem: fromItem, order: order, limit: limit);
    return accountsResponse.accounts;
  }

  @override
  Future<Account> getAccount(String accountIndex) async {
    final response = await api.getAccount(accountIndex);
    return response;
  }

  @override
  Future<List<Token>> getTokens() async {
    final TokensRequest tokensRequest = null;
    final tokensResponse = await api.getTokens(
        tokenIds: tokensRequest != null ? tokensRequest.ids : List());
    return tokensResponse.tokens;
  }

  @override
  Future<Token> getTokenById(int tokenId) async {
    final tokenResponse = await api.getToken(tokenId);
    return tokenResponse;
  }

  @override
  Future<List<ForgedTransaction>> getForgedTransactions(
      ForgedTransactionsRequest request) async {
    final response = await api.getTransactions(
        accountIndex: request.accountIndex, fromItem: request.fromItem);
    return response;
  }

  @override
  Future<ForgedTransaction> getTransactionById(String transactionId) async {
    final response = await api.getHistoryTransaction(transactionId);
    return response;
  }

  @override
  Future<Transaction> getPoolTransactionById(String transactionId) async {
    final response = await api.getPoolTransaction(transactionId);
    return response;
  }

  @override
  Future<void> generateAndSendL2Tx(
      Transaction transaction, HermezWallet wallet, Token token) async {
    tx.generateAndSendL2Tx(transaction, wallet, token);
  }

  @override
  Future<bool> sendL2Transaction(Transaction transaction, String bjj) async {
    final response = await tx.sendL2Transaction(transaction.toJson(), bjj);
    return response.isNotEmpty;
  }

  @override
  Future<List<Exit>> getExits(web3.EthereumAddress ethereumAddress) async {
    ExitsRequest exitsRequest = new ExitsRequest(
        hezEthereumAddress: addresses.getHermezAddress(ethereumAddress.hex),
        onlyPendingWithdraws: true);
    final exitsResponse = await api.getExits(
        exitsRequest.hezEthereumAddress, exitsRequest.onlyPendingWithdraws);
    return exitsResponse.exits;
  }

  @override
  Future<Exit> getExit(int batchNum, String accountIndex) async {
    final exitResponse = await api.getExit(batchNum, accountIndex);
    return exitResponse;
  }

  @override
  Future<RecommendedFee> getRecommendedFee() async {
    final StateResponse state = await api.getState();
    return state.recommendedFee;
  }

  @override
  Future<List<Coordinator>> getCoordinators(
      String forgerAddr, String bidderAddr) async {}

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
  Future<bool> deposit(BigInt amount, String hezEthereumAddress, Token token,
      String babyJubJub, String privateKey,
      {int gasLimit = GAS_LIMIT, int gasMultiplier = GAS_MULTIPLIER}) async {
    return tx.deposit(HermezCompressedAmount.compressAmount(amount.toDouble()),
        hezEthereumAddress, token, babyJubJub, client, privateKey,
        gasMultiplier: gasMultiplier);
  }

  @override
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
