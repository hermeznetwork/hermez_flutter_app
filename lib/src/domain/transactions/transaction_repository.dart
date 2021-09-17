import 'package:hermez_sdk/model/forged_transaction.dart';
import 'package:hermez_sdk/model/forged_transactions_request.dart';
import 'package:hermez_sdk/model/forged_transactions_response.dart';
import 'package:hermez_sdk/model/pool_transaction.dart';

abstract class TransactionRepository {
  // L2
  Future<ForgedTransactionsResponse> getForgedTransactions(
      ForgedTransactionsRequest request);

  Future<ForgedTransaction> getTransactionById(String transactionId);

  Future<PoolTransaction> getPoolTransactionById(String transactionId);

  // L1
  Future<List> getEthereumTransactionsByAddress(
      String address, String tokenAddress);
}
