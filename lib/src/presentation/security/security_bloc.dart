import 'package:hermez/src/common/bloc/bloc.dart';
import 'package:hermez/src/domain/security/usecases/authenticate_biometrics_use_case.dart';
import 'package:hermez/src/domain/security/usecases/check_biometrics_use_case.dart';
import 'package:hermez/src/domain/security/usecases/check_pin_use_case.dart';
import 'package:hermez/src/domain/security/usecases/confirm_pin_use_case.dart';
import 'package:hermez/src/domain/security/usecases/create_pin_use_case.dart';
import 'package:hermez/src/presentation/security/security_state.dart';
import 'package:local_auth/local_auth.dart';

class SecurityBloc extends Bloc<SecurityState> {
  final CreatePinUseCase _createPinUseCase;
  final ConfirmPinUseCase _confirmPinUseCase;
  final CheckPinUseCase _checkPinUseCase;
  //final SetupBiometricsUseCase _setupBiometricsUseCase;
  final CheckBiometricsUseCase _checkBiometricsUseCase;
  final AuthenticateBiometricsUseCase _authenticateBiometricsUseCase;

  SecurityBloc(
      this._createPinUseCase,
      this._confirmPinUseCase,
      this._checkPinUseCase,
      /*this._setupBiometricsUseCase,*/ this._checkBiometricsUseCase,
      this._authenticateBiometricsUseCase) {
    changeState(SecurityState.init());
  }

  Future<String> createPin(String pin) {
    return _createPinUseCase.execute(pin).then((pin) {
      changeState(SecurityState.pinCreated(PinItemState(pin)));
    }).catchError((error) {
      changeState(SecurityState.error('A network error has occurred'));
    });
  }

  Future<bool> confirmPin(String pin) async {
    if (this.state.pinItem.pin == pin) {
      return await _confirmPinUseCase.execute(pin).then((confirmed) {
        changeState(SecurityState.pinConfirmed(PinItemState(pin)));
      }).catchError((error) {
        changeState(SecurityState.error('A network error has occurred'));
      });
    } else {
      changeState(SecurityState.error('Wrong pin'));
      return false;
    }
  }

  Future<bool> checkBiometrics(BiometricType biometricType) {
    return _checkBiometricsUseCase
        .execute(biometricType)
        .then((biometricsEnabled) {
      //changeState(SecurityState.pinConfirmed(PinItemState(pin)));
    }).catchError((error) {
      //changeState(SecurityState.error('A network error has occurred'));
    });
  }

  Future<bool> authenticateBiometrics() async {
    await _checkBiometricsUseCase
        .execute(BiometricType.face)
        .then((faceEnabled) async {
      if (faceEnabled) {
        return await _authenticateBiometricsUseCase.execute(
            BiometricType.face, 'Scan your face to authenticate');
      }
      //changeState(SecurityState.pinConfirmed(PinItemState(pin)));
    }).catchError((error) {
      //changeState(SecurityState.error('A network error has occurred'));
    });
    await _checkBiometricsUseCase
        .execute(BiometricType.fingerprint)
        .then((fingerprintEnabled) async {
      if (fingerprintEnabled) {
        return await _authenticateBiometricsUseCase.execute(
            BiometricType.fingerprint, 'Scan your fingerprint to authenticate');
      }
      //changeState(SecurityState.pinConfirmed(PinItemState(pin)));
    }).catchError((error) {
      //changeState(SecurityState.error('A network error has occurred'));
    });
    return false;
  }

  /*Future<bool> importMnemonic(String mnemonic) async {
    return await _importMnemonicUseCase.execute(mnemonic).then((confirmed) {
      changeState(OnboardingState.mnemonicConfirmed());
    }).catchError((error) {
      changeState(OnboardingState.error('A network error has occurred'));
    });
  }

  Future<bool> importPrivateKey(String privateKey) async {
    return await _importPrivateKeyUseCase.execute(privateKey).then((confirmed) {
      changeState(OnboardingState.mnemonicConfirmed());
    }).catchError((error) {
      changeState(OnboardingState.error('A network error has occurred'));
    });
  }*/
}
