import 'package:hermez/service/explorer_service.dart';
import 'package:hermez/src/common/api/api_base_client.dart';
import 'package:hermez/src/domain/transactions/transaction_repository.dart';
import 'package:hermez_sdk/api.dart' as api;
import 'package:hermez_sdk/model/forged_transaction.dart';
import 'package:hermez_sdk/model/forged_transactions_request.dart';
import 'package:hermez_sdk/model/forged_transactions_response.dart';
import 'package:hermez_sdk/model/pool_transaction.dart';

class TransactionInNetworkRepository extends ApiBaseClient
    implements TransactionRepository {
  final ExplorerService _explorerService;
  TransactionInNetworkRepository(this._explorerService, baseAddress)
      : super(baseAddress);

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
  Future<List> getEthereumTransactionsByAddress(
      String address, String tokenAddress) async {
    if (tokenAddress.isEmpty) {
      return _explorerService.getTransactionsByAccountAddress(address);
    } else {
      List<dynamic> transactions = await _explorerService
          .getTokenTransferEventsByAccountAddress(address, tokenAddress);
      return transactions;
    }
  }
}
