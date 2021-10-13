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
import 'package:intl/intl.dart';
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
      {LayerFilter layerFilter = LayerFilter.ALL,
      TransactionStatusFilter transactionStatusFilter =
          TransactionStatusFilter.ALL,
      TransactionTypeFilter transactionTypeFilter = TransactionTypeFilter.ALL,
      List<int> tokenIds,
      int fromItem = 0}) async {
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
        if (transactionTypeFilter == TransactionTypeFilter.ALL &&
            (transactionStatusFilter == TransactionStatusFilter.ALL ||
                transactionStatusFilter == TransactionStatusFilter.HISTORY)) {
          final hermezTransactions = await _getHermezTransactionsByAddress(
              hermezAddress, accountIndex,
              tokenIds: tokenIds, fromItem: fromItem);

          response.addAll(hermezTransactions.transactions
              .map((ForgedTransaction forgedTransaction) {
            String id = "";
            String block = "";
            TransactionType type;
            TransactionLevel level;
            TransactionStatus status;
            String timestamp = "";
            String value = "0.0";
            String fee = "";
            String from = "";
            String to = "";
            int tokenId = -1;
            if (forgedTransaction.type == "Receive") {
              type = TransactionType.RECEIVE;
            } else if (forgedTransaction.type == "Deposit" ||
                forgedTransaction.type == "CreateAccountDeposit") {
              type = TransactionType.DEPOSIT;
            } else if (forgedTransaction.type == "Exit") {
              type = TransactionType.EXIT;
            } else if (forgedTransaction.type == "Withdraw") {
              type = TransactionType.WITHDRAW;
            } else if (forgedTransaction.type == "Transfer") {
              type = TransactionType.SEND;
            }
            if (forgedTransaction.timestamp != null) {
              status = TransactionStatus.CONFIRMED;
            } else {
              status = TransactionStatus.PENDING;
            }
            if (forgedTransaction.id != null) {
              id = forgedTransaction.id;
              block = forgedTransaction.batchNum.toString();
              level = TransactionLevel.LEVEL2;
              if (forgedTransaction != null) {
                final formatter = DateFormat(
                    "yyyy-MM-ddThh:mm:ssZ"); // "2021-03-18T10:42:01Z"
                final DateTime dateTimeFromStr =
                    formatter.parse(forgedTransaction.timestamp, true);
                timestamp = dateTimeFromStr.millisecondsSinceEpoch.toString();
              }
              if (type == TransactionType.DEPOSIT) {
                value = forgedTransaction.l1info.depositAmount;
              } else {
                value = forgedTransaction.amount;
              }
              fee = forgedTransaction.l2info.fee.toString();
              if (type == TransactionType.DEPOSIT) {
                from = getEthereumAddress(
                    forgedTransaction.fromHezEthereumAddress);
              } else {
                from = forgedTransaction.fromHezEthereumAddress;
              }
              if (type == TransactionType.DEPOSIT) {
                to = forgedTransaction.fromHezEthereumAddress;
              } else if (type == TransactionType.EXIT ||
                  type == TransactionType.WITHDRAW) {
                to = getEthereumAddress(
                    forgedTransaction.fromHezEthereumAddress);
              } else {
                to = forgedTransaction.toHezEthereumAddress;
              }
              tokenId = forgedTransaction.token.id;
            }
            return Transaction(
              id: id,
              block: block,
              level: level,
              status: status,
              type: type,
              from: from,
              to: to,
              timestamp: timestamp,
              amount: double.tryParse(value),
              fee: double.tryParse(fee),
              tokenId: tokenId,
            );
            return Transaction();
          }));
        }

        if (transactionTypeFilter == TransactionTypeFilter.ALL &&
                transactionStatusFilter == TransactionStatusFilter.ALL ||
            transactionStatusFilter == TransactionStatusFilter.PENDING) {
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
        response.addAll(ethereumTransactions.map((ethereumTransaction) {
          String id = "";
          String block = "";
          TransactionLevel level;
          TransactionStatus status;
          TransactionType type;
          String timestamp = "";
          String value = "0.0";
          String fee = "";
          String from = "";
          String to = "";
          int tokenId = -1;
          if (ethereumTransaction["type"] == "RECEIVE") {
            type = TransactionType.RECEIVE;
          } else if (ethereumTransaction["type"] == "DEPOSIT") {
            type = TransactionType.DEPOSIT;
          } else if (ethereumTransaction["type"] == "WITHDRAW") {
            type = TransactionType.WITHDRAW;
          } else if (ethereumTransaction["type"] == "SEND") {
            type = TransactionType.SEND;
          }
          if (ethereumTransaction["status"] == "CONFIRMED") {
            status = TransactionStatus.CONFIRMED;
          } else if (ethereumTransaction["status"] == "PENDING") {
            status = TransactionStatus.PENDING;
          }
          if (ethereumTransaction["txHash"] != null) {
            id = ethereumTransaction["txHash"];
            block = ethereumTransaction["blockNumber"].toString();
            level = TransactionLevel.LEVEL1;
            timestamp = ethereumTransaction["timestamp"].toString();
            value = ethereumTransaction["value"];
            fee = ethereumTransaction["fee"];
            from = ethereumTransaction["from"];
            to = ethereumTransaction["to"];
            tokenId = ethereumTransaction["tokenId"];
          }
          /*if (ethereumTransaction.type == "Transfer" ||
              ethereumTransaction.type == "TransferToEthAddr") {
            String value = ethereumTransaction.amount.toString();
            /*if (transaction.L1orL2 == 'L1') {
                        if (transaction.fromHezEthereumAddress.toLowerCase() ==
                            widget.arguments.store.state.ethereumAddress
                                .toLowerCase()) {
                          type = "SEND";
                        } else if (transaction.toHezEthereumAddress
                                .toLowerCase() ==
                            widget.arguments.store.state.ethereumAddress
                                .toLowerCase()) {}
                      } else {*/
            /*if ((ethereumTransaction.fromAccountIndex != null &&
                    ethereumTransaction.fromAccountIndex ==
                        widget.arguments.account.accountIndex) ||
                (ethereumTransaction.fromHezEthereumAddress != null &&
                    ethereumTransaction.fromHezEthereumAddress.toLowerCase() ==
                        (_settingsBloc.state as LoadedSettingsState)
                            .settings
                            .ethereumAddress
                            .toLowerCase())) {
              type = "SEND";
              if (transaction.batchNum != null) {
                status = "CONFIRMED";
                final formatter = DateFormat(
                    "yyyy-MM-ddThh:mm:ssZ"); // "2021-03-18T10:42:01Z"
                final DateTime dateTimeFromStr =
                    formatter.parse(transaction.timestamp, true);
                timestamp = dateTimeFromStr.millisecondsSinceEpoch;
              } else if (transaction.timestamp.isNotEmpty) {
                final formatter = DateFormat(
                    "yyyy-MM-ddThh:mm:ss"); // "2021-03-24T15:42:544802"
                final DateTime dateTimeFromStr =
                    formatter.parse(transaction.timestamp, true);
                timestamp = dateTimeFromStr.millisecondsSinceEpoch;
              }
              addressFrom = transaction.fromHezEthereumAddress;
              addressTo = transaction.toHezEthereumAddress;
            } else if ((transaction.toAccountIndex != null &&
                    transaction.toAccountIndex ==
                        widget.arguments.account.accountIndex) ||
                (transaction.toHezEthereumAddress != null &&
                    transaction.toHezEthereumAddress.toLowerCase() ==
                        (_settingsBloc.state as LoadedSettingsState)
                            .settings
                            .ethereumAddress
                            .toLowerCase())) {
              type = "RECEIVE";
              if (transaction.timestamp.isNotEmpty) {
                status = "CONFIRMED";
                final formatter = DateFormat(
                    "yyyy-MM-ddThh:mm:ssZ"); // "2021-03-18T10:42:01Z"
                final DateTime dateTimeFromStr =
                    formatter.parse(transaction.timestamp, true);
                timestamp = dateTimeFromStr.millisecondsSinceEpoch;
              }
              addressFrom = transaction.fromHezEthereumAddress;
              addressTo = transaction.toHezEthereumAddress;
            }*/
          }*/
          return Transaction(
            id: id,
            block: block,
            level: level,
            status: status,
            type: type,
            from: from,
            to: to,
            timestamp: timestamp,
            amount: double.tryParse(value),
            fee: double.tryParse(fee),
            tokenId: tokenId,
          );
        }));
      }

      if ((transactionTypeFilter == TransactionTypeFilter.ALL ||
                  transactionTypeFilter == TransactionTypeFilter.SEND ||
                  transactionTypeFilter == TransactionTypeFilter.RECEIVE) &&
              transactionStatusFilter == TransactionStatusFilter.ALL ||
          transactionStatusFilter == TransactionStatusFilter.PENDING) {
        final pendingTransfers = await getPendingTransfers();
        response.addAll(pendingTransfers.map((pendingTransfer) => Transaction(
              level: TransactionLevel.LEVEL1,
              status: TransactionStatus.PENDING,
            )));
      }
    }

    if (transactionTypeFilter == TransactionTypeFilter.ALL ||
        transactionTypeFilter == TransactionTypeFilter.EXIT) {
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

    if ((transactionTypeFilter == TransactionTypeFilter.ALL ||
                transactionTypeFilter == TransactionTypeFilter.DEPOSIT) &&
            transactionStatusFilter == TransactionStatusFilter.ALL ||
        transactionStatusFilter == TransactionStatusFilter.PENDING) {
      final pendingDeposits = await getPendingDeposits();
      response.addAll(pendingDeposits.map((pendingDeposit) => Transaction(
            level: TransactionLevel.LEVEL1,
            status: TransactionStatus.PENDING,
          )));
    }

    if ((transactionTypeFilter == TransactionTypeFilter.ALL ||
                transactionTypeFilter == TransactionTypeFilter.WITHDRAW) &&
            transactionStatusFilter == TransactionStatusFilter.ALL ||
        transactionStatusFilter == TransactionStatusFilter.PENDING) {
      final pendingWithdraws = await getPendingWithdraws();
      response.addAll(pendingWithdraws.map((pendingWithdraw) => Transaction(
            level: TransactionLevel.LEVEL1,
            status: TransactionStatus.PENDING,
          )));
    }

    if ((transactionTypeFilter == TransactionTypeFilter.ALL ||
                transactionTypeFilter == TransactionTypeFilter.FORCEEXIT) &&
            transactionStatusFilter == TransactionStatusFilter.ALL ||
        transactionStatusFilter == TransactionStatusFilter.PENDING) {
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
    for (int tokenId in tokenIds) {
      if (tokenId == 0) {
        try {
          List<dynamic> transactions =
              await _explorerService.getTransactionsByAccountAddress(address);
          response.addAll(transactions);
        } catch (e) {}
      } else {
        Token token;
        try {
          token = await getToken(tokenId);
        } catch (e) {}
        if (token != null) {
          List<dynamic> transactions =
              await _explorerService.getTokenTransferEventsByAccountAddress(
                  address, token.ethereumAddress,
                  tokenId: token.id);
          response.addAll(transactions);
        }
      }
    }
    /*response.addAll(tokenIds.map(
      (tokenId) async {
        if (tokenId == 0) {
          try {
            List<dynamic> transactions =
                await _explorerService.getTransactionsByAccountAddress(address);
            return transactions;
          } catch (e) {}
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
    ).toList());*/
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
