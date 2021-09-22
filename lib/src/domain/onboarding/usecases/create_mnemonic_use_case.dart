import 'package:hermez/src/domain/onboarding/onboarding_repository.dart';

class CreateMnemonicUseCase {
  final OnboardingRepository _onboardingRepository;

  CreateMnemonicUseCase(this._onboardingRepository);

  Future<String> execute() {
    return _onboardingRepository.generateMnemonic();
  }
}
