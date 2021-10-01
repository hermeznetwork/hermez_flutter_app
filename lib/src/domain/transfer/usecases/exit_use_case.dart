import 'package:hermez/src/domain/transfer/transfer_repository.dart';
import 'package:hermez_sdk/model/token.dart';

class ExitUseCase {
  final TransferRepository _transferRepository;

  ExitUseCase(this._transferRepository);

  Future<bool> execute(
      double amount, String accountIndex, Token token, double fee) {
    return _transferRepository.exit(amount, accountIndex, token, fee);
  }
}
