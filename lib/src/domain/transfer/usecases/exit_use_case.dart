import 'package:hermez/src/domain/transfer/transfer_repository.dart';
import 'package:hermez_sdk/model/account.dart';

class ExitUseCase {
  final TransferRepository _transferRepository;

  ExitUseCase(this._transferRepository);

  Future<bool> execute(double amount, Account account, double fee) {
    return _transferRepository.exit(amount, account, fee);
  }
}
