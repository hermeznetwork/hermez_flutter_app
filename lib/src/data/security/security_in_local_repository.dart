import 'package:hermez/src/data/network/configuration_service.dart';
import 'package:hermez/src/domain/security/security_repository.dart';
import 'package:hermez/utils/biometrics_utils.dart';
import 'package:local_auth/local_auth.dart';

class SecurityInLocalRepository implements SecurityRepository {
  final IConfigurationService _configurationService;
  SecurityInLocalRepository(this._configurationService);

  @override
  Future<String> createPin(String pin) {
    // TODO: implement createPin
    throw UnimplementedError();
  }

  @override
  Future<bool> confirmPin(String pin) {
    // TODO: implement confirmPin
    throw UnimplementedError();
  }

  @override
  Future<bool> isValidPin(String pin) async {
    String pinSaved = await _configurationService.getPasscode();
    return pinSaved == pin;
  }

  @override
  Future<bool> checkBiometrics(BiometricType biometricType) async {
    if (await BiometricsUtils.canCheckBiometrics() &&
        await BiometricsUtils.isDeviceSupported()) {
      List<BiometricType> availableBiometrics =
          await BiometricsUtils.getAvailableBiometrics();
      if (availableBiometrics.contains(biometricType) &&
          _configurationService.getBiometricsFace()) {
        return true;
      }
    }
    return false;
  }

  @override
  Future<bool> authenticateBiometrics(
      BiometricType biometricType, String infoMessage) async {
    if (await checkBiometrics(biometricType)) {
      bool authenticated =
          await BiometricsUtils.authenticateWithBiometrics(infoMessage);
      return authenticated;
    } else {
      return false;
    }
  }
}
