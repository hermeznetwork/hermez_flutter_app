import 'package:hermez/src/domain/onboarding/onboarding_repository.dart';

class CheckMnemonicUseCase {
  final OnboardingRepository _onboardingRepository;

  CheckMnemonicUseCase(this._onboardingRepository);

  bool execute(String mnemonic) {
    return _onboardingRepository.isValidMnemonic(mnemonic);
  }
}
