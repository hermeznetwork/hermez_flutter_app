import 'package:hermez/src/domain/transfer/transfer_repository.dart';
import 'package:hermez_sdk/model/token.dart';

class DepositUseCase {
  final TransferRepository _transferRepository;

  DepositUseCase(this._transferRepository);

  Future<bool> execute(double amount, Token token) {
    return _transferRepository.deposit(amount, token);
  }
}
