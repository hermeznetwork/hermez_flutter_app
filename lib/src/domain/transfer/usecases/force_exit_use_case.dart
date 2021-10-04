import 'package:hermez/src/domain/transfer/transfer_repository.dart';
import 'package:hermez_sdk/model/token.dart';

class ForceExitUseCase {
  final TransferRepository _transferRepository;

  ForceExitUseCase(this._transferRepository);

  Future<bool> forceExit(double amount, String accountIndex, Token token,
      {BigInt gasLimit, int gasPrice = 0}) {
    return _transferRepository.forceExit(amount, accountIndex, token,
        gasLimit: gasLimit, gasPrice: gasPrice);
  }

  Future<BigInt> forceExitGasLimit(
      double amount, String accountIndex, Token token) {
    return _transferRepository.forceExitGasLimit(amount, accountIndex, token);
  }
}
