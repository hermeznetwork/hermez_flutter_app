import 'package:hermez/src/data/network/configuration_service.dart';
import 'package:hermez/src/data/network/contract_service.dart';
import 'package:hermez/src/data/network/explorer_service.dart';
import 'package:hermez/src/data/network/hermez_service.dart';
import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez/src/domain/transactions/transaction_repository.dart';
import 'package:hermez/utils/contract_parser.dart';
import 'package:hermez_sdk/addresses.dart';
import 'package:hermez_sdk/api.dart';
import 'package:hermez_sdk/environment.dart';
import 'package:hermez_sdk/model/exit.dart';
import 'package:hermez_sdk/model/forged_transaction.dart';
import 'package:hermez_sdk/model/forged_transactions_request.dart';
import 'package:hermez_sdk/model/forged_transactions_response.dart';
import 'package:hermez_sdk/model/pool_transaction.dart';
import 'package:hermez_sdk/model/token.dart';
import 'package:hermez_sdk/tx_utils.dart';
import 'package:web3dart/web3dart.dart' as web3;

class TransactionInNetworkRepository implements TransactionRepository {
  final IConfigurationService _configurationService;
  final IHermezService _hermezService;
  final ExplorerService _explorerService;
  final ContractService _contractService;
  TransactionInNetworkRepository(this._configurationService,
      this._hermezService, this._explorerService, this._contractService);

  @override
  Future<List<Transaction>> getTransactions(String address, String accountIndex,
      [LayerFilter layerFilter = LayerFilter.ALL,
      TransactionStatusFilter transactionFilter = TransactionStatusFilter.ALL,
      TransactionTypeFilter transactionType = TransactionTypeFilter.ALL,
      List<int> tokenIds,
      int fromItem = 0]) async {
    List<Transaction> response = [];
    if (address == null || address.isEmpty) {
      address = await _configurationService.getHermezAddress();
    }
    if (layerFilter == LayerFilter.ALL || layerFilter == LayerFilter.L2) {
      String hermezAddress = address;
      bool validAddress = false;
      validAddress = isHermezEthereumAddress(hermezAddress) ||
          isHermezBjjAddress(hermezAddress) ||
          isHermezAccountIndex(accountIndex);
      if (!validAddress && isEthereumAddress(address)) {
        hermezAddress = getHermezAddress(address);
        validAddress = isHermezEthereumAddress(hermezAddress);
      }
      if (validAddress) {
        if (transactionType == TransactionTypeFilter.ALL &&
            (transactionFilter == TransactionStatusFilter.ALL ||
                transactionFilter == TransactionStatusFilter.HISTORY)) {
          final hermezTransactions = await _getHermezTransactionsByAddress(
              hermezAddress, accountIndex,
              tokenIds: tokenIds, fromItem: fromItem);
          response.addAll(hermezTransactions.transactions
              .map((forgedTransaction) => Transaction(
                    level: TransactionLevel.LEVEL2,
                    status: TransactionStatus.CONFIRMED,
                  )));
        }

        if (transactionType == TransactionTypeFilter.ALL &&
                transactionFilter == TransactionStatusFilter.ALL ||
            transactionFilter == TransactionStatusFilter.PENDING) {
          bool isAccountIndex = isHermezAccountIndex(accountIndex);
          if (isAccountIndex) {
            final hermezPoolTransactions =
                await getPoolTransactions(accountIndex);
            response.addAll(
                hermezPoolTransactions.map((poolTransaction) => Transaction(
                      level: TransactionLevel.LEVEL2,
                      status: TransactionStatus.PENDING,
                    )));
          }
        }
      }
    }

    if (layerFilter == LayerFilter.ALL || layerFilter == LayerFilter.L1) {
      String ethereumAddress = address;
      bool validAddress = false;
      validAddress = isEthereumAddress(ethereumAddress);
      if (!validAddress && isHermezEthereumAddress(address)) {
        ethereumAddress = getEthereumAddress(address);
        validAddress = isEthereumAddress(ethereumAddress);
      }
      if (validAddress) {
        final ethereumTransactions = await _getEthereumTransactionsByAddress(
            ethereumAddress,
            tokenIds: tokenIds);
        response.addAll(
            ethereumTransactions.map((ethereumTransaction) => Transaction(
                  level: TransactionLevel.LEVEL1,
                  status: TransactionStatus.CONFIRMED,
                )));
      }

      if ((transactionType == TransactionTypeFilter.ALL ||
                  transactionType == TransactionTypeFilter.SEND ||
                  transactionType == TransactionTypeFilter.RECEIVE) &&
              transactionFilter == TransactionStatusFilter.ALL ||
          transactionFilter == TransactionStatusFilter.PENDING) {
        final pendingTransfers = await getPendingTransfers();
        response.addAll(pendingTransfers.map((pendingTransfer) => Transaction(
              level: TransactionLevel.LEVEL1,
              status: TransactionStatus.PENDING,
            )));
      }
    }

    if (transactionType == TransactionTypeFilter.ALL ||
        transactionType == TransactionTypeFilter.EXIT) {
      String hermezAddress = address;
      bool validAddress = false;
      validAddress = isHermezEthereumAddress(hermezAddress) ||
          isHermezBjjAddress(hermezAddress);
      if (!validAddress && isEthereumAddress(address)) {
        hermezAddress = getHermezAddress(address);
        validAddress = isHermezEthereumAddress(hermezAddress);
      }
      if (validAddress) {
        final exits = await getExits(hermezAddress);
        response.addAll(exits.map((exit) => Transaction(
              level: TransactionLevel.LEVEL2,
              status: TransactionStatus.CONFIRMED,
            )));
      }
    }

    if ((transactionType == TransactionTypeFilter.ALL ||
                transactionType == TransactionTypeFilter.DEPOSIT) &&
            transactionFilter == TransactionStatusFilter.ALL ||
        transactionFilter == TransactionStatusFilter.PENDING) {
      final pendingDeposits = await getPendingDeposits();
      response.addAll(pendingDeposits.map((pendingDeposit) => Transaction(
            level: TransactionLevel.LEVEL1,
            status: TransactionStatus.PENDING,
          )));
    }

    if ((transactionType == TransactionTypeFilter.ALL ||
                transactionType == TransactionTypeFilter.WITHDRAW) &&
            transactionFilter == TransactionStatusFilter.ALL ||
        transactionFilter == TransactionStatusFilter.PENDING) {
      final pendingWithdraws = await getPendingWithdraws();
      response.addAll(pendingWithdraws.map((pendingWithdraw) => Transaction(
            level: TransactionLevel.LEVEL1,
            status: TransactionStatus.PENDING,
          )));
    }

    if ((transactionType == TransactionTypeFilter.ALL ||
                transactionType == TransactionTypeFilter.FORCEEXIT) &&
            transactionFilter == TransactionStatusFilter.ALL ||
        transactionFilter == TransactionStatusFilter.PENDING) {
      final pendingForceExits = await getPendingForceExits();
      response.addAll(pendingForceExits.map((pendingForceExits) => Transaction(
            level: TransactionLevel.LEVEL1,
            status: TransactionStatus.PENDING,
          )));
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

  Future<List<dynamic>> _getEthereumTransactionsByAddress(String address,
      {List<int> tokenIds}) async {
    List response = [];
    response.addAll(
      tokenIds.map(
        (tokenId) async {
          if (tokenId == 0) {
            return _explorerService.getTransactionsByAccountAddress(address);
          } else {
            Token token;
            try {
              token = await getToken(tokenId);
            } catch (e) {}
            if (token != null) {
              List<dynamic> transactions =
                  await _explorerService.getTokenTransferEventsByAccountAddress(
                      address, token.ethereumAddress);
              return transactions;
            }
          }
        },
      ),
    );
    return response;
  }

  Future<ForgedTransactionsResponse> _getHermezTransactionsByAddress(
      String address, String accountIndex,
      {List<int> tokenIds, int fromItem = 0}) async {
    Token token = await getToken(0);
    ForgedTransactionsRequest request = ForgedTransactionsRequest(
        ethereumAddress: address,
        accountIndex: accountIndex,
        batchNum: token.ethereumBlockNum,
        tokenIds: tokenIds,
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
        List<dynamic> transactions = await _getEthereumTransactionsByAddress(
            ethereumAddress,
            tokenIds: [Token.fromJson(pendingTransfer['token']).id]);
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
