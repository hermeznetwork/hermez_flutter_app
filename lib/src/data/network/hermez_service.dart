import 'dart:async';
import 'dart:collection';

import 'package:hermez_sdk/api.dart' as api;
import 'package:hermez_sdk/constants.dart';
import 'package:hermez_sdk/hermez_compressed_amount.dart';
import 'package:hermez_sdk/hermez_sdk.dart';
import 'package:hermez_sdk/hermez_wallet.dart';
import 'package:hermez_sdk/model/account.dart';
import 'package:hermez_sdk/model/coordinator.dart';
import 'package:hermez_sdk/model/create_account_authorization.dart';
import 'package:hermez_sdk/model/exit.dart';
import 'package:hermez_sdk/model/forged_transaction.dart';
import 'package:hermez_sdk/model/forged_transactions_request.dart';
import 'package:hermez_sdk/model/forged_transactions_response.dart';
import 'package:hermez_sdk/model/pool_transaction.dart';
import 'package:hermez_sdk/model/recommended_fee.dart';
import 'package:hermez_sdk/model/state_response.dart';
import 'package:hermez_sdk/model/token.dart';
import 'package:hermez_sdk/model/transaction.dart';
import 'package:hermez_sdk/tx.dart' as tx;
import 'package:hermez_sdk/tx_pool.dart' as tx_pool;
import 'package:hermez_sdk/tx_utils.dart';
import 'package:web3dart/crypto.dart';

import 'configuration_service.dart';

abstract class IHermezService {
  Future<StateResponse> getState();
  Future<bool> authorizeAccountCreation();
  Future<CreateAccountAuthorization> getCreateAccountAuthorization(
      String hermezAddress);
  Future<List<Account>> getAccounts(String hezAddress, List<int> tokenIds,
      {int fromItem = 0,
      api.PaginationOrder order = api.PaginationOrder.ASC,
      int limit = DEFAULT_PAGE_SIZE});
  Future<Account> getAccount(String accountIndex);
  Future<List<Exit>> getExits(String hermezAddress,
      {bool onlyPendingWithdraws = true, int tokenId = -1});
  Future<Exit> getExit(int batchNum, String accountIndex);
  Future<List<Coordinator>> getCoordinators(
      String forgerAddr, String bidderAddr);
  Future<ForgedTransactionsResponse> getForgedTransactions(
      ForgedTransactionsRequest request);
  Future<ForgedTransaction> getTransactionById(String transactionId);
  Future<List<PoolTransaction>> getPoolTransactions([String accountIndex]);
  Future<PoolTransaction> getPoolTransactionById(String transactionId);
  Future<List<Token>> getTokens({List<int> tokenIds});
  Future<Token> getTokenById(int tokenId);
  Future<LinkedHashMap<String, BigInt>> depositGasLimit(
      double amount, Token token);
  Future<bool> deposit(double amount, Token token,
      {BigInt approveGasLimit, BigInt depositGasLimit, int gasPrice = 0});
  Future<BigInt> withdrawGasLimit(double amount, Exit exit,
      bool completeDelayedWithdrawal, bool instantWithdrawal);
  Future<bool> withdraw(double amount, Exit exit,
      bool completeDelayedWithdrawal, bool instantWithdrawal,
      {BigInt gasLimit, int gasPrice = 0});
  Future<BigInt> forceExitGasLimit(
      double amount, String accountIndex, Token token);
  Future<bool> forceExit(double amount, String accountIndex, Token token,
      {BigInt gasLimit, int gasPrice = 0});
  Future<bool> generateAndSendL2Tx(Map transaction, int tokenId);
  Future<bool> sendL2Transaction(Transaction transaction);
  Future<RecommendedFee> getRecommendedFee();
  Future<bool> isInstantWithdrawalAllowed(double amount, Token token);
}

class HermezService implements IHermezService {
  IConfigurationService _configService;
  HermezService(this._configService);

  @override
  Future<StateResponse> getState() async {
    final StateResponse state = await api.getState();
    if (state.network.nextForgers != null &&
        state.network.nextForgers.length > 0) {
      final baseApiUrl = state.network.nextForgers[0].coordinator.URL;
      Uri uri = Uri.parse(baseApiUrl);
      api.setBaseApiUrl(uri.host);
    }
    return state;
  }

  @override
  Future<bool> authorizeAccountCreation() async {
    final ethereumPrivateKey = await _configService.getPrivateKey();
    final hermezPrivateKey = await _configService.getHermezPrivateKey();
    final hermezAddress = await _configService.getHermezAddress();
    final hermezWallet =
        HermezWallet(hexToBytes(hermezPrivateKey), hermezAddress);
    String bjj = hermezWallet.publicKeyBase64;
    final signature =
        await hermezWallet.signCreateAccountAuthorization(ethereumPrivateKey);
    final response =
        await api.postCreateAccountAuthorization(hermezAddress, bjj, signature);
    if (response != null) {
      return response.statusCode == 200;
    } else {
      return false;
    }
  }

  @override
  Future<CreateAccountAuthorization> getCreateAccountAuthorization(
      String hermezAddress) async {
    final response = await api.getCreateAccountAuthorization(hermezAddress);
    return response;
  }

  @override
  Future<List<Account>> getAccounts(String hezAddress, List<int> tokenIds,
      {int fromItem = 0,
      api.PaginationOrder order = api.PaginationOrder.ASC,
      int limit = DEFAULT_PAGE_SIZE}) async {
    final accountsResponse = await api.getAccounts(hezAddress, tokenIds,
        fromItem: fromItem, order: order, limit: limit);
    return accountsResponse.accounts;
  }

  @override
  Future<Account> getAccount(String accountIndex) async {
    final response = await api.getAccount(accountIndex);
    return response;
  }

  @override
  Future<List<Token>> getTokens({List<int> tokenIds}) async {
    final tokensResponse = await api.getTokens(
        tokenIds: tokenIds != null ? tokenIds : List.empty(), limit: 2049);
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
        tokenIds: request.tokenIds,
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
  Future<List<PoolTransaction>> getPoolTransactions(
      [String accountIndex]) async {
    final hermezPrivateKey = await _configService.getHermezPrivateKey();
    final hermezAddress = await _configService.getHermezAddress();
    final hermezWallet =
        HermezWallet(hexToBytes(hermezPrivateKey), hermezAddress);
    return await tx_pool.getPoolTransactions(
        accountIndex, hermezWallet.publicKeyCompressedHex);
  }

  @override
  Future<PoolTransaction> getPoolTransactionById(String transactionId) async {
    final response = await api.getPoolTransaction(transactionId);
    return response;
  }

  @override
  Future<bool> generateAndSendL2Tx(Map transaction, int tokenId) async {
    try {
      final hermezPrivateKey = await _configService.getHermezPrivateKey();
      final hermezAddress = await _configService.getHermezAddress();
      final hermezWallet =
          HermezWallet(hexToBytes(hermezPrivateKey), hermezAddress);
      Token token = await getTokenById(tokenId);
      final l2TxResult =
          await tx.generateAndSendL2Tx(transaction, hermezWallet, token);
      if (l2TxResult != null && l2TxResult['status'] == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> sendL2Transaction(Transaction transaction) async {
    try {
      String bjj = await _configService.getBabyJubJubHex();
      final l2TxResult = await tx.sendL2Transaction(transaction.toJson(), bjj);
      if (l2TxResult != null && l2TxResult['status'] == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Exit>> getExits(String hermezAddress,
      {bool onlyPendingWithdraws = true, int tokenId = -1}) async {
    final exitsResponse =
        await api.getExits(hermezAddress, onlyPendingWithdraws, tokenId);
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
  /// @param {double} amount - The amount to be deposited
  //// @param {String} hezEthereumAddress - The Hermez address of the transaction sender
  /// @param {Object} token - The token information object as returned from the API
  //// @param {String} babyJubJub - The compressed BabyJubJub in hexadecimal format of the transaction sender.
  /// @param {String} providerUrl - Network url (i.e, http://localhost:8545). Optional
  /// @param {Object} signerData - Signer data used to build a Signer to send the transaction
  /// @param {Number} gasLimit - Optional gas limit
  /// @param {Number} gasMultiplier - Optional gas multiplier
  /// @returns {Promise} transaction parameters
  @override
  Future<bool> deposit(double amount, Token token,
      {BigInt approveGasLimit,
      BigInt depositGasLimit,
      int gasPrice = 0}) async {
    final hermezPrivateKey = await _configService.getHermezPrivateKey();
    final hermezAddress = await _configService.getHermezAddress();
    final ethereumPrivateKey = await _configService.getPrivateKey();
    final hermezWallet =
        HermezWallet(hexToBytes(hermezPrivateKey), hermezAddress);
    String babyJubJub = hermezWallet.publicKeyCompressedHex;

    HermezCompressedAmount compressedAmount;
    try {
      compressedAmount = HermezCompressedAmount.compressAmount(amount);
    } catch (e) {
      return false;
    }
    final txHash = await tx
        .deposit(compressedAmount, hermezAddress, token, babyJubJub,
            ethereumPrivateKey,
            approveMaxGas: approveGasLimit,
            depositMaxGas: depositGasLimit,
            gasPrice: gasPrice)
        .then((txHash) async {
      if (txHash != null) {
        await api.getAccounts(hermezAddress, [token.id]).then((res) {
          _configService.addPendingDeposit({
            'txHash': txHash,
            'from': hermezAddress,
            'to': hermezAddress,
            'token': token.toJson(),
            'value': amount.toString(),
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

  @override
  Future<LinkedHashMap<String, BigInt>> depositGasLimit(
      double amount, Token token) async {
    final hermezPrivateKey = await _configService.getHermezPrivateKey();
    final hermezAddress = await _configService.getHermezAddress();
    final hermezWallet =
        HermezWallet(hexToBytes(hermezPrivateKey), hermezAddress);
    String babyJubJub = hermezWallet.publicKeyCompressedHex;
    final LinkedHashMap<String, BigInt> gasLimit = await tx.depositGasLimit(
        HermezCompressedAmount.compressAmount(amount.toDouble()),
        hermezAddress,
        token,
        babyJubJub);
    return gasLimit;
  }

  @override
  Future<BigInt> withdrawGasLimit(double amount, Exit exit,
      bool completeDelayedWithdrawal, bool instantWithdrawal) async {
    final hermezPrivateKey = await _configService.getHermezPrivateKey();
    final hermezAddress = await _configService.getHermezAddress();
    final hermezWallet =
        HermezWallet(hexToBytes(hermezPrivateKey), hermezAddress);
    final babyJubJub = hermezWallet.publicKeyCompressedHex;
    Token token = await getTokenById(exit.tokenId);
    if (completeDelayedWithdrawal == null ||
        completeDelayedWithdrawal == false) {
      bool isIntant = instantWithdrawal == null ? true : instantWithdrawal;

      return tx.withdrawGasLimit(
          amount,
          hermezAddress,
          exit != null ? exit.accountIndex : "hez:" + token.symbol + ":0",
          token,
          babyJubJub,
          exit != null ? exit.batchNum : 0,
          exit.merkleProof.siblings != null ? exit.merkleProof.siblings : [],
          isInstant: isIntant);
    } else {
      return tx.delayedWithdrawGasLimit(hermezAddress, token);
    }
  }

  @override
  Future<bool> withdraw(double amount, Exit exit,
      bool completeDelayedWithdrawal, bool instantWithdrawal,
      {BigInt gasLimit, int gasPrice = 0}) async {
    final hermezPrivateKey = await _configService.getHermezPrivateKey();
    final hermezAddress = await _configService.getHermezAddress();
    final ethereumPrivateKey = await _configService.getPrivateKey();
    final hermezWallet =
        HermezWallet(hexToBytes(hermezPrivateKey), hermezAddress);
    final babyJubJub = hermezWallet.publicKeyCompressedHex;
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
        Token token = await getTokenById(exit.tokenId);
        final txHash = await tx
            .withdraw(amount, exit.accountIndex, token, babyJubJub,
                exit.batchNum, exit.merkleProof.siblings, ethereumPrivateKey,
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
                            exit.tokenId,
                    orElse: () => null);
                if (pendingDelayedWithdraw != null) {
                  amount += pendingDelayedWithdraw['amount'];
                  _configService
                      .removePendingWithdraw(pendingDelayedWithdraw['id']);
                }
              }
            }
            await _configService.addPendingWithdraw({
              'id': withdrawalId,
              'hash': txHash,
              'blockNum': block,
              'hermezEthereumAddress': hermezAddress,
              'itemId': exit.itemId,
              'accountIndex': exit.accountIndex,
              'batchNum': exit.batchNum,
              'instant': isInstant,
              'date': DateTime.now().millisecondsSinceEpoch,
              'amount': amount,
              'token': token.toJson(),
              'status': 'pending'
            });
          }
          return txHash != null;
        });
        return txHash;
      } catch (error) {
        print(error);
        return false;
      }
    } else {
      try {
        Token token = await getTokenById(exit.tokenId);
        final txHash = await tx
            .delayedWithdraw(token, ethereumPrivateKey)
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
        return false;
      }
    }
  }

  @override
  Future<bool> isInstantWithdrawalAllowed(double amount, Token token) async {
    return await tx.isInstantWithdrawalAllowed(amount, token);
  }

  @override
  Future<BigInt> forceExitGasLimit(
      double amount, String accountIndex, Token token) async {
    final hermezAddress = await _configService.getHermezAddress();
    return await tx.forceExitGasLimit(
        HermezCompressedAmount.compressAmount(amount),
        hermezAddress,
        accountIndex,
        token);
  }

  @override
  Future<bool> forceExit(double amount, String accountIndex, Token token,
      {BigInt gasLimit, int gasPrice = 0}) async {
    try {
      //Token token = await getTokenById(tokenId);
      final hermezAddress = await _configService.getHermezAddress();
      String ethereumPrivateKey = await _configService.getPrivateKey();
      final txHash = await tx
          .forceExit(HermezCompressedAmount.compressAmount(amount.toDouble()),
              accountIndex, token, ethereumPrivateKey,
              gasLimit: gasLimit, gasPrice: gasPrice)
          .then((txHash) async {
        if (txHash != null) {
          _configService.addPendingForceExit({
            'hash': txHash,
            'accountIndex': accountIndex,
            'fromHezEthereumAddress': hermezAddress,
            'toHezEthereumAddress': hermezAddress,
            'token': token.toJson(),
            'amount': amount,
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
      return false;
    }
  }
}
