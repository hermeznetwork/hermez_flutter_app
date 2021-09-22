import 'package:hermez/src/domain/security/security_repository.dart';

class CreatePinUseCase {
  final SecurityRepository _securityRepository;

  CreatePinUseCase(this._securityRepository);

  Future<String> execute(String pin) {
    return _securityRepository.createPin(pin);
  }
}
