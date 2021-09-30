import 'package:hermez/src/domain/transfer/transfer_repository.dart';
import 'package:hermez_sdk/model/account.dart';
import 'package:hermez_sdk/model/exit.dart';

class WithdrawUseCase {
  final TransferRepository _transferRepository;

  WithdrawUseCase(this._transferRepository);

  Future<bool> execute(double amount, Account account, Exit exit,
      {bool completeDelayedWithdrawal = false, bool instantWithdrawal = true}) {
    return _transferRepository.withdraw(
        amount, account, exit, completeDelayedWithdrawal, instantWithdrawal);
  }
}
