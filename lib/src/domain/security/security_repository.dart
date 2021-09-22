abstract class SecurityRepository {
  Future<String> createPin(String pin);
  Future<bool> confirmPin(String pin);
  Future<bool> isValidPin(String pin);
}
