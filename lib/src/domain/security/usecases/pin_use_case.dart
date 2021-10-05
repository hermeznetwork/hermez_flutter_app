import 'package:hermez/src/domain/security/security_repository.dart';

class PinUseCase {
  final SecurityRepository _securityRepository;

  PinUseCase(this._securityRepository);

  Future<bool> setPin(String pin) {
    return _securityRepository.setPasscode(pin);
  }

  Future<String> getPin() async {
    return _securityRepository.getPasscode();
  }

  Future<bool> isValidPin(String passcode) {
    return _securityRepository.isValidPasscode(passcode);
  }
}
