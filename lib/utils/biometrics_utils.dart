import 'package:flutter/services.dart' show PlatformException;
import 'package:local_auth/local_auth.dart';

class BiometricsUtils {
  static Future<bool> isDeviceSupported() async {
    LocalAuthentication auth = LocalAuthentication();
    bool isDeviceSupported = false;
    try {
      isDeviceSupported = await auth.isDeviceSupported();
    } on PlatformException catch (e) {
      isDeviceSupported = false;
      print(e);
    }
    return isDeviceSupported;
  }

  static Future<bool> canCheckBiometrics() async {
    LocalAuthentication auth = LocalAuthentication();
    bool canCheckBiometrics = false;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    return canCheckBiometrics;
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    LocalAuthentication auth = LocalAuthentication();
    return await auth.getAvailableBiometrics();
  }

  static Future<bool> authenticateWithBiometrics(String localizedReason) async {
    LocalAuthentication auth = LocalAuthentication();
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
          localizedReason: localizedReason,
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true);
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
    //if (!mounted) return false;

    return authenticated;
  }
}
