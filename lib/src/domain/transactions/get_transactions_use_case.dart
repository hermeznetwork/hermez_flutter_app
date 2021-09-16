import 'package:hermez/src/domain/transactions/transaction_repository.dart';
import 'package:hermez_sdk/model/transaction.dart';

class GetTransactionsUseCase {
  final TransactionRepository _transactionRepository;

  GetTransactionsUseCase(this._transactionRepository);

  Future<List<Transaction>> execute() {
    return null; //_transactionRepository.getForgedTransactions(request);
  }
}
