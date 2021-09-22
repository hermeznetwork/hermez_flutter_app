import 'package:hermez/src/common/bloc/bloc.dart';
import 'package:hermez/src/domain/security/usecases/check_pin_use_case.dart';
import 'package:hermez/src/domain/security/usecases/confirm_pin_use_case.dart';
import 'package:hermez/src/domain/security/usecases/create_pin_use_case.dart';
import 'package:hermez/src/presentation/onboarding/onboarding_state.dart';
import 'package:hermez/src/presentation/security/security_state.dart';

class SecurityBloc extends Bloc<SecurityState> {
  final CreatePinUseCase _createPinUseCase;
  final ConfirmPinUseCase _confirmPinUseCase;
  final CheckPinUseCase _checkPinUseCase;
  final SetupBiometricsUseCase _setupBiometricsUseCase;
  final CheckBiometricsUseCase _checkBiometricsUseCase;

  SecurityBloc(this._createPinUseCase, this._checkPinUseCase,
      this._setupBiometricsUseCase, this._checkBiometricsUseCase) {
    changeState(SecurityState.init());
  }

  Future<String> createPin(String pin) {
    return _createPinUseCase.execute(pin).then((mnemonic) {
      changeState(SecurityState.mnemonicCreated(OnboardingItemState(mnemonic)));
    }).catchError((error) {
      changeState(SecurityState.error('A network error has occurred'));
    });
  }

  Future<bool> confirmMnemonic(String mnemonic) async {
    if (this.state.onboardingItem.mnemonic == mnemonic) {
    } else {}
    return await _confirmMnemonicUseCase.execute(mnemonic).then((confirmed) {
      changeState(OnboardingState.mnemonicConfirmed());
    }).catchError((error) {
      changeState(OnboardingState.error('A network error has occurred'));
    });
  }

  bool checkMnemonic(String mnemonic) {
    return _checkMnemonicUseCase.execute(mnemonic);
  }

  Future<bool> importMnemonic(String mnemonic) async {
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
  }
}
