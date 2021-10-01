import 'package:hermez/src/domain/transfer/transfer_repository.dart';
import 'package:hermez_sdk/model/token.dart';

class ForceExitUseCase {
  final TransferRepository _transferRepository;

  ForceExitUseCase(this._transferRepository);

  Future<bool> execute(double amount, String accountIndex, Token token) {
    return _transferRepository.forceExit(amount, accountIndex, token);
  }
}
