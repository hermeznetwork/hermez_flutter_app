abstract class OnboardingRepository {
  Future<String> generateMnemonic();
  bool isValidMnemonic(String mnemonic);
  Future<bool> confirmMnemonic(String mnemonic);
  Future<bool> importFromMnemonic(String mnemonic);
  Future<bool> importFromPrivateKey(String privateKey);
}
