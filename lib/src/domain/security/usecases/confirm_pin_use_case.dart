import 'package:hermez/src/domain/security/security_repository.dart';

class ConfirmPinUseCase {
  final SecurityRepository _securityRepository;

  ConfirmPinUseCase(this._securityRepository);

  Future<bool> execute(String pin) {
    return _securityRepository.confirmPin(pin);
  }
}
