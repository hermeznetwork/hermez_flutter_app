import 'dart:async';
import 'dart:collection';

import 'package:hermez_sdk/addresses.dart' as addresses;
import 'package:hermez_sdk/api.dart';
import 'package:hermez_sdk/api.dart' as api;
import 'package:hermez_sdk/constants.dart';
import 'package:hermez_sdk/hermez_compressed_amount.dart';
import 'package:hermez_sdk/hermez_sdk.dart';
import 'package:hermez_sdk/hermez_wallet.dart';
import 'package:hermez_sdk/model/account.dart';
import 'package:hermez_sdk/model/coordinator.dart';
import 'package:hermez_sdk/model/create_account_authorization.dart';
import 'package:hermez_sdk/model/exit.dart';
import 'package:hermez_sdk/model/exits_request.dart';
import 'package:hermez_sdk/model/forged_transaction.dart';
import 'package:hermez_sdk/model/forged_transactions_request.dart';
import 'package:hermez_sdk/model/forged_transactions_response.dart';
import 'package:hermez_sdk/model/pool_transaction.dart';
import 'package:hermez_sdk/model/recommended_fee.dart';
import 'package:hermez_sdk/model/state_response.dart';
import 'package:hermez_sdk/model/token.dart';
import 'package:hermez_sdk/model/tokens_request.dart';
import 'package:hermez_sdk/model/transaction.dart';
import 'package:hermez_sdk/tx.dart' as tx;
import 'package:hermez_sdk/tx_utils.dart';
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
  Future<Exit> getExit(int batchNum, String accountIndex);
  Future<List<Coordinator>> getCoordinators(
      String forgerAddr, String bidderAddr);
  Future<ForgedTransactionsResponse> getForgedTransactions(
      ForgedTransactionsRequest request);
  Future<ForgedTransaction> getTransactionById(String transactionId);
  Future<PoolTransaction> getPoolTransactionById(String transactionId);
  Future<List<Token>> getTokens();
  Future<Token> getTokenById(int tokenId);
  Future<bool> deposit(BigInt amount, String hezEthereumAddress, Token token,
      String babyJubJub, String privateKey,
      {BigInt approveGasLimit, BigInt depositGasLimit, int gasPrice = 0});
  Future<bool> withdraw(
      double amount,
      Account account,
      Exit exit,
      bool completeDelayedWithdrawal,
      bool instantWithdrawal,
      String hezEthereumAddress,
      String babyJubJub,
      String privateKey,
      {BigInt gasLimit,
      int gasPrice = 0});
  Future<bool> forceExit(BigInt amount, String hezEthereumAddress,
      Account account, String privateKey,
      {BigInt gasLimit, int gasPrice = 0});
  Future<bool> generateAndSendL2Tx(
      Map transaction, HermezWallet wallet, Token token);
  Future<bool> sendL2Transaction(Transaction transaction, String bjj);
  Future<RecommendedFee> getRecommendedFee();
}

class HermezService implements IHermezService {
  IConfigurationService _configService;
  HermezService(this._configService);

  @override
  Future<StateResponse> getState() async {
    final StateResponse state = await api.getState();
    final baseApiUrl = state.network.nextForgers[0].coordinator.URL;
    Uri uri = Uri.parse(baseApiUrl);

    api.setBaseApiUrl(uri.host);
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
        tokenIds: tokensRequest != null ? tokensRequest.ids : List.empty());
    return tokensResponse.tokens;
  }

  @override
  Future<Token> getTokenById(int tokenId) async {
    final tokenResponse = await api.getToken(tokenId);
    return tokenResponse;
  }

  @override
  Future<ForgedTransactionsResponse> getForgedTransactions(
      ForgedTransactionsRequest request) async {
    final response = await api.getTransactions(
        accountIndex: request.accountIndex,
        fromItem: request.fromItem,
        order: api.PaginationOrder.DESC);
    return response;
  }

  @override
  Future<ForgedTransaction> getTransactionById(String transactionId) async {
    final response = await api.getHistoryTransaction(transactionId);
    return response;
  }

  @override
  Future<PoolTransaction> getPoolTransactionById(String transactionId) async {
    final response = await api.getPoolTransaction(transactionId);
    return response;
  }

  @override
  Future<bool> generateAndSendL2Tx(
      Map transaction, HermezWallet wallet, Token token) async {
    try {
      final l2TxResult =
          await tx.generateAndSendL2Tx(transaction, wallet, token);
      return l2TxResult != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> sendL2Transaction(Transaction transaction, String bjj) async {
    try {
      final response = await tx.sendL2Transaction(transaction.toJson(), bjj);
      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Exit>> getExits(web3.EthereumAddress ethereumAddress,
      {bool onlyPendingWithdraws = true, int tokenId = -1}) async {
    ExitsRequest exitsRequest = new ExitsRequest(
        hezEthereumAddress: addresses.getHermezAddress(ethereumAddress.hex),
        onlyPendingWithdraws: onlyPendingWithdraws,
        tokenId: tokenId);
    final exitsResponse = await api.getExits(exitsRequest.hezEthereumAddress,
        exitsRequest.onlyPendingWithdraws, exitsRequest.tokenId);
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
      {BigInt approveGasLimit,
      BigInt depositGasLimit,
      int gasPrice = 0}) async {
    HermezCompressedAmount compressedAmount;
    try {
      compressedAmount =
          HermezCompressedAmount.compressAmount(amount.toDouble());
    } catch (e) {
      return false;
    }
    final txHash = await tx
        .deposit(
            compressedAmount, hezEthereumAddress, token, babyJubJub, privateKey,
            approveMaxGas: approveGasLimit,
            depositMaxGas: depositGasLimit,
            gasPrice: gasPrice)
        .then((txHash) async {
      if (txHash != null) {
        await api.getAccounts(hezEthereumAddress, [token.id]).then((res) {
          _configService.addPendingDeposit({
            'txHash': txHash,
            'from': hezEthereumAddress,
            'to': hezEthereumAddress,
            'token': token.toJson(),
            'value': amount.toDouble().toString(),
            'fee': '0',
            'status': 'PENDING',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'type': 'DEPOSIT'
            /*res != null && res.accounts != null && res.accounts.length > 0
                    ? TxType.Deposit.toString().split('.').last
                    : TxType.CreateAccountDeposit.toString().split('.').last*/
          });
        });
      }
      return txHash != null;
    });
    return txHash;
  }

  Future<LinkedHashMap<String, BigInt>> depositGasLimit(BigInt amount,
      String hezEthereumAddress, Token token, String babyJubJub) async {
    final LinkedHashMap<String, BigInt> gasLimit = await tx.depositGasLimit(
        HermezCompressedAmount.compressAmount(amount.toDouble()),
        hezEthereumAddress,
        token,
        babyJubJub);
    return gasLimit;
  }

  Future<BigInt> withdrawGasLimit(
      double amount,
      Account account,
      Exit exit,
      bool completeDelayedWithdrawal,
      bool instantWithdrawal,
      String hezEthereumAddress,
      String babyJubJub) async {
    if (completeDelayedWithdrawal == null ||
        completeDelayedWithdrawal == false) {
      bool isIntant = instantWithdrawal == null ? true : instantWithdrawal;
      return tx.withdrawGasLimit(
          amount,
          hezEthereumAddress,
          exit != null
              ? exit.accountIndex
              : "hez:" + account.token.symbol + ":0",
          exit != null ? exit.token : account.token,
          babyJubJub,
          exit != null ? exit.batchNum : 0,
          exit.merkleProof.siblings != null ? exit.merkleProof.siblings : [],
          isInstant: isIntant);
    } else {
      return tx.delayedWithdrawGasLimit(hezEthereumAddress, exit.token);
    }
  }

  @override
  Future<bool> withdraw(
      double amount,
      Account account,
      Exit exit,
      bool completeDelayedWithdrawal,
      bool instantWithdrawal,
      String hezEthereumAddress,
      String babyJubJub,
      String privateKey,
      {BigInt gasLimit,
      int gasPrice = 0}) async {
    final withdrawalId = exit.accountIndex + exit.batchNum.toString();
    /*HermezCompressedAmount compressedAmount;
    try {
      compressedAmount =
          HermezCompressedAmount.compressAmount(amount.toDouble());
    } catch (e) {
      return false;
    }*/
    if (completeDelayedWithdrawal == null ||
        completeDelayedWithdrawal == false) {
      try {
        bool isInstant = instantWithdrawal == null ? true : instantWithdrawal;

        final txHash = await tx
            .withdraw(amount, exit.accountIndex, exit.token, babyJubJub,
                exit.batchNum, exit.merkleProof.siblings, privateKey,
                isInstant: isInstant, gasLimit: gasLimit, gasPrice: gasPrice)
            .then((txHash) async {
          if (txHash != null) {
            int block = await HermezSDK.currentWeb3Client.getBlockNumber();
            dynamic pendingDelayedWithdraw;
            if (isInstant == false) {
              List<dynamic> pendingWithdraws =
                  await _configService.getPendingWithdraws();
              if (pendingWithdraws != null) {
                pendingDelayedWithdraw = pendingWithdraws.firstWhere(
                    (pendingWithdraw) =>
                        pendingWithdraw['instant'] == false &&
                        Token.fromJson(pendingWithdraw['token']).id ==
                            exit.token.id,
                    orElse: () => null);
                if (pendingDelayedWithdraw != null) {
                  amount += pendingDelayedWithdraw['amount'];
                  _configService
                      .removePendingWithdraw(pendingDelayedWithdraw['id']);
                }
              }
              _configService.addPendingWithdraw({
                'id': withdrawalId,
                'hash': txHash,
                'blockNum': block,
                'hermezEthereumAddress': hezEthereumAddress,
                'itemId': exit.itemId,
                'accountIndex': exit.accountIndex,
                'batchNum': exit.batchNum,
                'instant': isInstant,
                'date': DateTime.now().millisecondsSinceEpoch,
                'amount': amount.toDouble(),
                'token': exit.token.toJson(),
                'status': 'pending'
              });
            }
          }
          return txHash != null;
        });
        return txHash;
      } catch (error) {
        print(error);
      }
    } else {
      try {
        final txHash = await tx
            .delayedWithdraw(exit.token, privateKey)
            .then((txHash) async {
          if (txHash != null) {
            String status = 'completed';
            final withdrawalId = exit.accountIndex + exit.batchNum.toString();
            _configService.updatePendingWithdraw(
                'status', status, withdrawalId);
            _configService.updatePendingWithdraw('hash', txHash, withdrawalId);
          }
          return txHash != null;
        });
        return txHash;
      } catch (error) {
        print(error);
      }
    }
  }

  Future<bool> isInstantWithdrawalAllowed(double amount, Token token) async {
    return await tx.isInstantWithdrawalAllowed(amount, token);
  }

  Future<BigInt> forceExitGasLimit(
      BigInt amount, String hezEthereumAddress, Account account) async {
    return await tx.forceExitGasLimit(
        hezEthereumAddress,
        HermezCompressedAmount.compressAmount(amount.toDouble()),
        account.accountIndex,
        account.token);
  }

  @override
  Future<bool> forceExit(BigInt amount, String hezEthereumAddress,
      Account account, String privateKey,
      {BigInt gasLimit, int gasPrice = 0}) async {
    try {
      final txHash = await tx
          .forceExit(HermezCompressedAmount.compressAmount(amount.toDouble()),
              account.accountIndex, account.token, privateKey,
              gasLimit: gasLimit, gasPrice: gasPrice)
          .then((txHash) async {
        if (txHash != null) {
          _configService.addPendingForceExit({
            'hash': txHash,
            'accountIndex': account.accountIndex,
            'fromHezEthereumAddress': hezEthereumAddress,
            'toHezEthereumAddress': hezEthereumAddress,
            'token': account.token.toJson(),
            'amount': amount.toDouble(),
            'state': 'pend',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'type': TxType.Exit.toString().split('.').last
            /*'hermezEthereumAddress': hezEthereumAddress,
            ,*/
          });
        }
        return txHash;
      });
      return txHash != null;
    } catch (error) {
      print(error);
    }
  }
}
