import 'package:local_auth/local_auth.dart';

abstract class SecurityRepository {
  Future<String> getPasscode();
  Future<bool> setPasscode(String passcode);
  Future<bool> isValidPasscode(String passcode);
  Future<bool> checkBiometrics(BiometricType biometricType);
  Future<bool> authenticateBiometrics(
      BiometricType biometricType, String infoMessage);
}
