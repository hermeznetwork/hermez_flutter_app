import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez/src/domain/transactions/transaction_repository.dart';

class GetAllTransactionsUseCase {
  final TransactionRepository _transactionRepository;

  GetAllTransactionsUseCase(this._transactionRepository);

  Future<List<Transaction>> execute(
      [LayerFilter layerFilter = LayerFilter.ALL,
      String address,
      String accountIndex,
      List<int> tokenIds]) {
    if (tokenIds == null) {
      tokenIds = [];
    }

    return _transactionRepository.getTransactions(
        address,
        accountIndex,
        layerFilter,
        TransactionStatusFilter.ALL,
        TransactionTypeFilter.ALL,
        tokenIds);
  }
}
