import 'package:local_auth/local_auth.dart';

abstract class SecurityRepository {
  Future<String> createPin(String pin);
  Future<bool> confirmPin(String pin);
  Future<bool> isValidPin(String pin);
  Future<bool> checkBiometrics(BiometricType biometricType);
  Future<bool> authenticateBiometrics(
      BiometricType biometricType, String infoMessage);
}
