import 'package:hermez/src/domain/security/security_repository.dart';
import 'package:local_auth/local_auth.dart';

class AuthenticateBiometricsUseCase {
  final SecurityRepository _securityRepository;

  AuthenticateBiometricsUseCase(this._securityRepository);

  Future<bool> execute(BiometricType biometricType, String infoMessage) {
    return _securityRepository.authenticateBiometrics(
        biometricType, infoMessage);
  }
}
