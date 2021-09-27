import 'package:hermez/src/common/bloc/bloc.dart';
import 'package:hermez/src/domain/onboarding/usecases/check_mnemonic_use_case.dart';
import 'package:hermez/src/domain/onboarding/usecases/confirm_mnemonic_use_case.dart';
import 'package:hermez/src/domain/onboarding/usecases/create_mnemonic_use_case.dart';
import 'package:hermez/src/domain/onboarding/usecases/import_mnemonic_use_case.dart';
import 'package:hermez/src/domain/onboarding/usecases/import_private_key_use_case.dart';
import 'package:hermez/src/presentation/onboarding/onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingState> {
  final CreateMnemonicUseCase _createMnemonicUseCase;
  final ConfirmMnemonicUseCase _confirmMnemonicUseCase;
  final CheckMnemonicUseCase _checkMnemonicUseCase;
  final ImportMnemonicUseCase _importMnemonicUseCase;
  final ImportPrivateKeyUseCase _importPrivateKeyUseCase;

  OnboardingBloc(
      this._createMnemonicUseCase,
      this._confirmMnemonicUseCase,
      this._checkMnemonicUseCase,
      this._importMnemonicUseCase,
      this._importPrivateKeyUseCase) {
    changeState(OnboardingState.init());
  }

  Future<String> generateMnemonic() {
    return _createMnemonicUseCase.execute().then((mnemonic) {
      changeState(
          OnboardingState.mnemonicCreated(OnboardingItemState(mnemonic)));
    }).catchError((error) {
      changeState(OnboardingState.error('A network error has occurred'));
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
