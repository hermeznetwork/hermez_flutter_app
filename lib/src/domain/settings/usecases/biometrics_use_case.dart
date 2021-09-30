import 'package:hermez/src/domain/settings/settings_repository.dart';
import 'package:local_auth/local_auth.dart';

class BiometricsUseCase {
  final SettingsRepository _settingsRepository;

  BiometricsUseCase(this._settingsRepository);

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return _settingsRepository.getAvailableBiometrics();
  }

  bool getBiometricsFace() {
    return _settingsRepository.getBiometricsFace();
  }

  Future<void> setBiometricsFace(bool value) async {
    _settingsRepository.updateBiometricsFace(value);
  }

  bool getBiometricsFingerprint() {
    return _settingsRepository.getBiometricsFingerprint();
  }

  Future<void> setBiometricsFingerprint(bool value) async {
    _settingsRepository.updateBiometricsFingerprint(value);
  }

  Future<bool> authenticateWithBiometrics(String infoDescription) async {
    return _settingsRepository.authenticateWithBiometrics(infoDescription);
  }
}
