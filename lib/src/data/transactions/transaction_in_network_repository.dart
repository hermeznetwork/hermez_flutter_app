import 'dart:collection';

import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/service/contract_service.dart';
import 'package:hermez/service/explorer_service.dart';
import 'package:hermez/service/hermez_service.dart';
import 'package:hermez/src/domain/transactions/transaction_repository.dart';
import 'package:hermez/utils/contract_parser.dart';
import 'package:hermez_sdk/api.dart';
import 'package:hermez_sdk/environment.dart';
import 'package:hermez_sdk/hermez_compressed_amount.dart';
import 'package:hermez_sdk/model/account.dart';
import 'package:hermez_sdk/model/exit.dart';
import 'package:hermez_sdk/model/forged_transaction.dart';
import 'package:hermez_sdk/model/forged_transactions_request.dart';
import 'package:hermez_sdk/model/forged_transactions_response.dart';
import 'package:hermez_sdk/model/pool_transaction.dart';
import 'package:hermez_sdk/model/token.dart';
import 'package:hermez_sdk/model/transaction.dart';
import 'package:hermez_sdk/tx_utils.dart';
import 'package:web3dart/web3dart.dart' as web3;

class TransactionInNetworkRepository implements TransactionRepository {
  final IConfigurationService _configurationService;
  final HermezService _hermezService;
  final ExplorerService _explorerService;
  final ContractService _contractService;
  TransactionInNetworkRepository(this._configurationService,
      this._hermezService, this._explorerService, this._contractService);

  @override
  Future<List<dynamic>> getTransactions(
      {LayerFilter layerFilter = LayerFilter.ALL,
      String address,
      String accountIndex,
      int tokenId = 0,
      int fromItem = 0}) async {
    List response = [];
    switch (layerFilter) {
      case LayerFilter.ALL:
        final hermezAddress = await _configurationService.getHermezAddress();
        Token token = await getToken(tokenId);
        ForgedTransactionsRequest request = ForgedTransactionsRequest(
            ethereumAddress: hermezAddress,
            accountIndex: accountIndex,
            batchNum: token.ethereumBlockNum,
            tokenId: tokenId,
            fromItem: fromItem);
        ForgedTransactionsResponse forgedTransactionsResponse =
            await _hermezService.getForgedTransactions(request);
        response.addAll(forgedTransactionsResponse.transactions);
        final ethereumAddress =
            await _configurationService.getEthereumAddress();
        final ethereumTransactions = await getEthereumTransactionsByAddress(
            ethereumAddress,
            tokenId: tokenId);
        response.addAll(ethereumTransactions);
        break;
      case LayerFilter.L1:
        final ethereumAddress =
            await _configurationService.getEthereumAddress();
        final ethereumTransactions = await getEthereumTransactionsByAddress(
            ethereumAddress,
            tokenId: tokenId);
        response.addAll(ethereumTransactions);
        break;
      case LayerFilter.L2:
        final hermezAddress = await _configurationService.getHermezAddress();
        Token token = await getToken(tokenId);
        ForgedTransactionsRequest request = ForgedTransactionsRequest(
            ethereumAddress: hermezAddress,
            accountIndex: accountIndex,
            batchNum: token.ethereumBlockNum,
            tokenId: tokenId,
            fromItem: fromItem);
        ForgedTransactionsResponse forgedTransactionsResponse =
            await _hermezService.getForgedTransactions(request);
        response.addAll(forgedTransactionsResponse.transactions);
        break;
    }
    return response;
  }

  @override
  Future<dynamic> getTransactionById(String transactionId,
      {LayerFilter layerFilter = LayerFilter.ALL}) async {
    switch (layerFilter) {
      case LayerFilter.ALL:
        final response = await getForgedTransactionById(transactionId);
        return response;
        break;
      case LayerFilter.L1:
        // TODO missing this method
        break;
      case LayerFilter.L2:
        final response = await getForgedTransactionById(transactionId);
        return response;
        break;
    }
  }

  @override
  Future<ForgedTransactionsResponse> getForgedTransactions(
      ForgedTransactionsRequest request) async {
    final response = await _hermezService.getForgedTransactions(request);
    return response;
  }

  @override
  Future<ForgedTransaction> getForgedTransactionById(
      String transactionId) async {
    final response = await _hermezService.getTransactionById(transactionId);
    return response;
  }

  @override
  Future<List<dynamic>> getEthereumTransactionsByAddress(String address,
      {int tokenId = 0}) async {
    if (tokenId == 0) {
      return _explorerService.getTransactionsByAccountAddress(address);
    } else {
      Token token = await getToken(tokenId);
      List<dynamic> transactions =
          await _explorerService.getTokenTransferEventsByAccountAddress(
              address, token.ethereumAddress);
      return transactions;
    }
  }

  Future<ForgedTransactionsResponse> getHermezTransactionsByAddress(
      String address, Account account, int fromItem) async {
    Token token = await getToken(account.tokenId);
    ForgedTransactionsRequest request = ForgedTransactionsRequest(
        ethereumAddress: addresses.getHermezAddress(address),
        accountIndex: account.accountIndex,
        batchNum: token.ethereumBlockNum,
        tokenId: token.id,
        fromItem: fromItem);
    return _hermezService.getForgedTransactions(request);
  }

  @override
  Future<List<PoolTransaction>> getPoolTransactions(
      [String accountIndex]) async {
    final response = await _hermezService.getPoolTransactions(accountIndex);
    return response;
  }

  @override
  Future<PoolTransaction> getPoolTransactionById(String transactionId) async {
    final response = await _hermezService.getPoolTransactionById(transactionId);
    return response;
  }

  @override
  Future<List<Exit>> getExits(String hermezAddress,
      {bool onlyPendingWithdraws = true, int tokenId = -1}) async {
    final exits = await _hermezService.getExits(hermezAddress,
        onlyPendingWithdraws: onlyPendingWithdraws, tokenId: tokenId);
    exits.sort((exit1, exit2) {
      return exit2.itemId.compareTo(exit1.itemId);
    });
    return exits;
  }

  /// Fetches the details of an exit
  /// @param {string} accountIndex - account index
  /// @param {number} batchNum - batch number
  /// @returns {Exit}
  @override
  Future<Exit> getExit(String accountIndex, int batchNum) {
    return _hermezService.getExit(batchNum, accountIndex);
  }

  @override
  Future<List<dynamic>> getPendingForceExits() async {
    final List accountPendingForceExits =
        await _configurationService.getPendingForceExits();

    List forceExitIds = [];
    for (final pendingForceExit in accountPendingForceExits) {
      final transactionHash = pendingForceExit['hash'];
      web3.TransactionReceipt receipt =
          await _contractService.getTxReceipt(transactionHash);
      if (receipt != null) {
        if (receipt.status == false) {
          // Tx didn't pass
          if (pendingForceExit['id'] == null) {
            pendingForceExit['id'] = transactionHash;
            accountPendingForceExits[accountPendingForceExits.indexWhere(
                    (element) => element['hash'] == pendingForceExit['hash'])] =
                pendingForceExit;
            await _configurationService.updatePendingForceExitId(
                transactionHash, transactionHash);
          }
          forceExitIds.add(transactionHash);
          await _configurationService.removePendingForceExit(transactionHash);
        } else {
          final hermezContract = await ContractParser.fromAssets(
              'HermezABI.json',
              getCurrentEnvironment().contracts['Hermez'],
              "Hermez");
          final contractEvent = hermezContract.event('L1UserTxEvent');
          for (var log in receipt.logs) {
            if (log.address.hex == hermezContract.address.hex) {
              try {
                List<String> topics = List<String>.from(
                    log.topics.map((topic) => topic.toString()));
                List l1UserTxEvent =
                    contractEvent.decodeResults(topics, log.data);
                final transactionId =
                    getL1UserTxId(l1UserTxEvent[0], l1UserTxEvent[1]);

                if (pendingForceExit['id'] == null) {
                  pendingForceExit['id'] = transactionId;
                  accountPendingForceExits[accountPendingForceExits.indexWhere(
                          (element) =>
                              element['hash'] == pendingForceExit['hash'])] =
                      pendingForceExit;
                  await _configurationService.updatePendingForceExitId(
                      transactionHash, transactionId);
                }

                final forgedTransaction =
                    await getTransactionById(transactionId);
                if (forgedTransaction != null &&
                    forgedTransaction.batchNum != null) {
                  forceExitIds.add(transactionHash);
                  await _configurationService
                      .removePendingForceExit(transactionHash, name: 'hash');
                }
              } catch (e) {
                print(e.toString());
              }
            }
          }
        }
      }
    }

    accountPendingForceExits.removeWhere(
        (pendingForceExit) => forceExitIds.contains(pendingForceExit['hash']));

    return accountPendingForceExits.reversed.toList();
  }

  @override
  Future<List<dynamic>> getPendingWithdraws() async {
    final List accountPendingWithdraws =
        await _configurationService.getPendingWithdraws();

    List removeWithdawalIds = [];
    List removeWithdawalHashes = [];
    List updateWithdawalIds = [];
    List<dynamic> updatePendingWithdraws = [];
    accountPendingWithdraws.forEach((pendingWithdraw) async {
      final String transactionHash = pendingWithdraw['hash'];
      final String status = pendingWithdraw['status'];
      Exit exit;
      if (pendingWithdraw['accountIndex'] != null &&
          pendingWithdraw['batchNum'] != null &&
          (status == 'pending' || status == 'completed')) {
        exit = await getExit(
            pendingWithdraw['accountIndex'], pendingWithdraw['batchNum']);
        if (exit.instantWithdraw != null || exit.delayedWithdraw != null) {
          final withdrawalId = exit.accountIndex + exit.batchNum.toString();
          removeWithdawalIds.add(withdrawalId);
          _configurationService.removePendingWithdraw(withdrawalId);
        }
      }

      if (transactionHash != null) {
        web3.TransactionInformation txInfo;
        try {
          txInfo = await _contractService.getTransactionByHash(transactionHash);
        } catch (e) {
          // wait an hour and if not, it failed
          if ((pendingWithdraw['instant'] == true ||
                  pendingWithdraw['status'] == 'completed') &&
              (DateTime.now().subtract(Duration(hours: 1)).isAfter(
                  DateTime.fromMillisecondsSinceEpoch(
                      pendingWithdraw['date'])))) {
            if (exit == null) {
              removeWithdawalHashes.add(transactionHash);
              _configurationService.removePendingWithdraw(transactionHash,
                  name: 'hash');
            } else {
              String status = 'fail';
              pendingWithdraw['status'] = status;
              final withdrawalId = exit.accountIndex + exit.batchNum.toString();
              updateWithdawalIds.add(withdrawalId);
              updatePendingWithdraws.add(withdrawalId);
              _configurationService.updatePendingWithdraw(
                  'status', status, withdrawalId);
            }
          }
        }
        if (txInfo != null) {
          web3.TransactionReceipt receipt =
              await _contractService.getTxReceipt(transactionHash);
          if (receipt != null) {
            if (receipt.status == false) {
              // Tx didn't pass
              if (exit == null) {
                removeWithdawalHashes.add(transactionHash);
                _configurationService.removePendingWithdraw(transactionHash,
                    name: 'hash');
              } else {
                String status = 'fail';
                pendingWithdraw['status'] = status;
                final withdrawalId =
                    exit.accountIndex + exit.batchNum.toString();
                updateWithdawalIds.add(withdrawalId);
                updatePendingWithdraws.add(withdrawalId);
                _configurationService.updatePendingWithdraw(
                    'status', status, withdrawalId);
              }
            } else {
              if (status == 'initiated') {
                String hermezAddress =
                    await _configurationService.getHermezAddress();
                List<Exit> exits = await getExits(hermezAddress,
                    tokenId: Token.fromJson(pendingWithdraw['token']).id);
                exit = exits.firstWhere(
                    (Exit exit) =>
                        pendingWithdraw['accountIndex'] == exit.accountIndex &&
                        (pendingWithdraw['amount'] as double)
                                .toInt()
                                .toString() ==
                            exit.balance &&
                        Token.fromJson(pendingWithdraw['token']).id ==
                            exit.tokenId &&
                        (exit.instantWithdraw == null &&
                            exit.delayedWithdraw == null),
                    orElse: () => null);
                if (exit != null) {
                  removeWithdawalHashes.add(transactionHash);
                  _configurationService.removePendingWithdraw(transactionHash,
                      name: 'hash');
                }
              }
            }
          }
        }
      }
    });

    /*accountPendingWithdraws[accountPendingWithdraws.indexWhere(
            (pendingWithdraw) =>
                updateWithdawalIds.contains(pendingWithdraw['id']))] =
        updatePendingWithdraws[0];*/

    accountPendingWithdraws.removeWhere((pendingWithdraw) =>
        removeWithdawalIds.contains(pendingWithdraw['id']));

    accountPendingWithdraws.removeWhere((pendingWithdraw) =>
        removeWithdawalHashes.contains(pendingWithdraw['hash']));

    return accountPendingWithdraws;
  }

  @override
  Future<List<dynamic>> getPendingDeposits() async {
    final List accountPendingDeposits =
        await _configurationService.getPendingDeposits();

    List depositIds = [];
    for (final pendingDeposit in accountPendingDeposits) {
      final transactionHash = pendingDeposit['txHash'];
      web3.TransactionReceipt receipt =
          await _contractService.getTxReceipt(transactionHash);
      if (receipt != null) {
        if (receipt.status == false) {
          // Tx didn't pass
          if (pendingDeposit['id'] == null) {
            pendingDeposit['id'] = transactionHash;
            accountPendingDeposits[accountPendingDeposits.indexWhere(
                    (element) =>
                        element['txHash'] == pendingDeposit['txHash'])] =
                pendingDeposit;
            _configurationService.updatePendingDepositId(
                transactionHash, transactionHash);
          }
          depositIds.add(transactionHash);
          _configurationService.removePendingDeposit(transactionHash);
        } else {
          final hermezContract = await ContractParser.fromAssets(
              'HermezABI.json',
              getCurrentEnvironment().contracts['Hermez'],
              "Hermez");
          final contractEvent = hermezContract.event('L1UserTxEvent');
          for (var log in receipt.logs) {
            if (log.address.hex == hermezContract.address.hex) {
              try {
                List<String> topics = List<String>.from(
                    log.topics.map((topic) => topic.toString()));
                List l1UserTxEvent =
                    contractEvent.decodeResults(topics, log.data);
                final transactionId =
                    getL1UserTxId(l1UserTxEvent[0], l1UserTxEvent[1]);

                if (pendingDeposit['id'] == null) {
                  pendingDeposit['id'] = transactionId;
                  accountPendingDeposits[accountPendingDeposits.indexWhere(
                          (element) =>
                              element['txHash'] == pendingDeposit['txHash'])] =
                      pendingDeposit;
                  _configurationService.updatePendingDepositId(
                      transactionHash, transactionId);
                }

                final forgedTransaction =
                    await getTransactionById(transactionId);
                if (forgedTransaction != null &&
                    forgedTransaction.batchNum != null) {
                  depositIds.add(transactionHash);
                  _configurationService.removePendingDeposit(transactionHash);
                }
              } catch (e) {
                print(e.toString());
              }
            }
          }
        }
      }
      /*
      web3.TransactionInformation transaction =
          await _contractService.getTransactionByHash(transactionHash);
      if (transaction != null && transaction.transactionIndex != null) {
        depositIds.add(transactionId);
        _configurationService.removePendingDeposit(transactionId);
      }*/
    }

    accountPendingDeposits.removeWhere(
        (pendingDeposit) => depositIds.contains(pendingDeposit['txHash']));

    return accountPendingDeposits.reversed.toList();
  }

  @override
  Future<List<dynamic>> getPendingTransfers() async {
    final List accountPendingTransfers =
        await _configurationService.getPendingTransfers();

    List transferIds = [];
    for (final pendingTransfer in accountPendingTransfers) {
      try {
        final transactionHash = pendingTransfer['txHash'];
        web3.TransactionReceipt receipt =
            await _contractService.getTxReceipt(transactionHash);
        final ethereumAddress =
            await _configurationService.getEthereumAddress();
        List<dynamic> transactions = await getEthereumTransactionsByAddress(
            ethereumAddress,
            tokenId: Token.fromJson(pendingTransfer['token']).id);
        final transactionFound = transactions.firstWhere(
            (transaction) => transaction['txHash'] == transactionHash,
            orElse: () => null);
        if (transactionFound != null ||
            (receipt != null && receipt.status == false)) {
          transferIds.add(transactionHash);
          await _configurationService.removePendingTransfer(transactionHash);
        }
      } catch (e) {
        print(e.toString());
      }
    }

    accountPendingTransfers.removeWhere(
        (pendingTransfer) => transferIds.contains(pendingTransfer['txHash']));

    return accountPendingTransfers.reversed.toList();
  }

  // Transactions Operations

  @override
  Future<LinkedHashMap<String, BigInt>> depositGasLimit(
      double amount, Token token) async {
    return _hermezService.depositGasLimit(amount, token);
  }

  @override
  Future<bool> deposit(double amount, Token token,
      {BigInt approveGasLimit, BigInt depositGasLimit, int gasPrice}) async {
    return _hermezService.deposit(amount, token,
        approveGasLimit: approveGasLimit,
        depositGasLimit: depositGasLimit,
        gasPrice: gasPrice);
  }

  @override
  Future<BigInt> withdrawGasLimit(double amount, Account account, Exit exit,
      bool completeDelayedWithdrawal, bool instantWithdrawal) async {
    return _hermezService.withdrawGasLimit(
        amount, account, exit, completeDelayedWithdrawal, instantWithdrawal);
  }

  @override
  Future<bool> withdraw(double amount, Account account, Exit exit,
      bool completeDelayedWithdrawal, bool instantWithdrawal,
      {BigInt gasLimit, int gasPrice = 0}) async {
    final success = await _hermezService.withdraw(
        amount, account, exit, completeDelayedWithdrawal, instantWithdrawal,
        gasLimit: gasLimit, gasPrice: gasPrice);
    return success;
  }

  @override
  Future<BigInt> forceExitGasLimit(double amount, Account account) async {
    return _hermezService.forceExitGasLimit(amount, account);
  }

  @override
  Future<bool> forceExit(double amount, Account account,
      {BigInt gasLimit, int gasPrice = 0}) async {
    return _hermezService.forceExit(amount, account,
        gasLimit: gasLimit, gasPrice: gasPrice);
  }

  @override
  Future<bool> exit(double amount, Account account, double fee) async {
    final exitTx = {
      'from': account.accountIndex,
      'type': 'Exit',
      'amount': HermezCompressedAmount.compressAmount(amount),
      'fee': fee,
    };
    final success =
        await _hermezService.generateAndSendL2Tx(exitTx, account.tokenId);
    return success;
  }

  @override
  Future<bool> transfer(
      double amount, Account from, Account to, double fee) async {
    final transferTx = {
      'from': from.accountIndex,
      'to': to.accountIndex != null
          ? to.accountIndex
          : to.hezEthereumAddress != null
              ? to.hezEthereumAddress
              : to.bjj,
      'amount': HermezCompressedAmount.compressAmount(amount),
      'fee': fee,
    };
    final success =
        await _hermezService.generateAndSendL2Tx(transferTx, from.tokenId);
    return success;
  }

  Future<bool> sendL2Transaction(Transaction transaction) async {
    final result = await _hermezService.sendL2Transaction(transaction);
    return result;
  }

  /*@override
  Future<bool> isInstantWithdrawalAllowed(double amount, Token token) async {
    final success =
    await _hermezService.isInstantWithdrawalAllowed(amount, token);
    return success;
  }*/

  /*List<Exit> exits = await getExits();
  List<PoolTransaction> pendingL2Txs = await getPoolTransactions();
  List<dynamic> pendingL1Transfers = await getPendingTransfers();
  List<dynamic> pendingDeposits = await getPendingDeposits();
  List<dynamic> pendingWithdraws = await getPendingWithdraws();
  List<dynamic> pendingForceExits = await getPendingForceExits();*/
}
