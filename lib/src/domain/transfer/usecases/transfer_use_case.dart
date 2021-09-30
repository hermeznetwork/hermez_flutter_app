import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez/src/domain/transfer/transfer_repository.dart';
import 'package:hermez_sdk/model/token.dart';

class TransferUseCase {
  final TransferRepository _transferRepository;

  TransferUseCase(this._transferRepository);

  Future<bool> execute(TransactionLevel level, String from, String to,
      double amount, Token token,
      {double fee, int gasLimit, int gasPrice}) {
    return _transferRepository.transfer(level, from, to, amount, token,
        fee: fee, gasLimit: gasLimit, gasPrice: gasPrice);
  }
}
