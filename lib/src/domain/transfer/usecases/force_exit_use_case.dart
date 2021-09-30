import 'package:hermez/src/domain/transfer/transfer_repository.dart';
import 'package:hermez_sdk/model/account.dart';

class ForceExitUseCase {
  final TransferRepository _transferRepository;

  ForceExitUseCase(this._transferRepository);

  Future<bool> execute(double amount, Account account) {
    return _transferRepository.forceExit(amount, account);
  }
}
