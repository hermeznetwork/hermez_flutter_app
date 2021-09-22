import 'package:hermez/src/domain/onboarding/onboarding_repository.dart';

class ImportPrivateKeyUseCase {
  final OnboardingRepository _onboardingRepository;

  ImportPrivateKeyUseCase(this._onboardingRepository);

  Future<bool> execute(String privateKey) {
    return _onboardingRepository.importFromPrivateKey(privateKey);
  }
}
