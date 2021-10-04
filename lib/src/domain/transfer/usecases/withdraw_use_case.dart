import 'package:hermez/src/domain/transfer/transfer_repository.dart';
import 'package:hermez_sdk/model/exit.dart';
import 'package:hermez_sdk/model/token.dart';

class WithdrawUseCase {
  final TransferRepository _transferRepository;

  WithdrawUseCase(this._transferRepository);

  Future<bool> withdraw(double amount, Exit exit,
      {bool completeDelayedWithdrawal = false,
      bool instantWithdrawal = true,
      BigInt gasLimit,
      int gasPrice = 0}) {
    return _transferRepository.withdraw(
        amount, exit, completeDelayedWithdrawal, instantWithdrawal,
        gasLimit: gasLimit, gasPrice: gasPrice);
  }

  Future<bool> isInstantWithdrawalAllowed(double amount, Token token) async {
    return _transferRepository.isInstantWithdrawalAllowed(amount, token);
  }

  Future<BigInt> withdrawGasLimit(double amount, Exit exit,
      {bool completeDelayedWithdrawal = false, bool instantWithdrawal = true}) {
    return _transferRepository.withdrawGasLimit(
        amount, exit, completeDelayedWithdrawal, instantWithdrawal);
  }
}
