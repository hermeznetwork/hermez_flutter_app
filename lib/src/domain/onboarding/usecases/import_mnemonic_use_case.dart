import 'package:hermez/src/domain/onboarding/onboarding_repository.dart';

class ImportMnemonicUseCase {
  final OnboardingRepository _onboardingRepository;

  ImportMnemonicUseCase(this._onboardingRepository);

  Future<bool> execute(String mnemonic) {
    return _onboardingRepository.importFromMnemonic(mnemonic);
  }
}
