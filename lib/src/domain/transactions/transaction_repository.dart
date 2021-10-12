import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez_sdk/model/exit.dart';
import 'package:hermez_sdk/model/forged_transaction.dart';
import 'package:hermez_sdk/model/forged_transactions_request.dart';
import 'package:hermez_sdk/model/forged_transactions_response.dart';
import 'package:hermez_sdk/model/pool_transaction.dart';

enum LayerFilter { ALL, L1, L2 }

enum TransactionStatusFilter { ALL, PENDING, HISTORY }

enum TransactionTypeFilter {
  ALL,
  SEND,
  RECEIVE,
  DEPOSIT,
  WITHDRAW,
  EXIT,
  FORCEEXIT
}

abstract class TransactionRepository {
  // ALL
  Future<List<Transaction>> getTransactions(String address, String accountIndex,
      {LayerFilter layerFilter = LayerFilter.ALL,
      TransactionStatusFilter transactionStatusFilter =
          TransactionStatusFilter.ALL,
      TransactionTypeFilter transactionTypeFilter = TransactionTypeFilter.ALL,
      List<int> tokenIds,
      int fromItem = 0});

  Future<dynamic> getTransactionById(String transactionId,
      {LayerFilter layerFilter = LayerFilter.ALL});
  // L2
  Future<ForgedTransactionsResponse> getForgedTransactions(
      ForgedTransactionsRequest request);

  Future<ForgedTransaction> getForgedTransactionById(String transactionId);

  Future<List<PoolTransaction>> getPoolTransactions([String accountIndex]);

  Future<PoolTransaction> getPoolTransactionById(String transactionId);

  Future<List<Exit>> getExits(String hermezAddress,
      {bool onlyPendingWithdraws = true, int tokenId = -1});

  Future<Exit> getExit(String accountIndex, int batchNum);

  Future<List<dynamic>> getPendingForceExits();

  Future<List<dynamic>> getPendingWithdraws();

  Future<List<dynamic>> getPendingDeposits();

  Future<List<dynamic>> getPendingTransfers();
}
