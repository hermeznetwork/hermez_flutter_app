import 'package:hermez/src/domain/security/security_repository.dart';
import 'package:local_auth/local_auth.dart';

class CheckBiometricsUseCase {
  final SecurityRepository _securityRepository;

  CheckBiometricsUseCase(this._securityRepository);

  Future<bool> execute(BiometricType biometricType) {
    return _securityRepository.checkBiometrics(biometricType);
  }
}
