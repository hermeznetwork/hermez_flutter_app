import 'package:hermez/src/domain/onboarding/onboarding_repository.dart';

class ConfirmMnemonicUseCase {
  final OnboardingRepository _onboardingRepository;

  ConfirmMnemonicUseCase(this._onboardingRepository);

  Future<bool> execute(String mnemonic) {
    return _onboardingRepository.confirmMnemonic(mnemonic);
  }
}
