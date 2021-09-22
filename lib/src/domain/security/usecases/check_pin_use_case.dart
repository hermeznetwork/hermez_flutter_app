import 'package:hermez/src/domain/security/security_repository.dart';

class CheckPinUseCase {
  final SecurityRepository _securityRepository;

  CheckPinUseCase(this._securityRepository);

  Future<bool> execute(String pin) {
    return _securityRepository.isValidPin(pin);
  }
}
