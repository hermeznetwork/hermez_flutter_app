import 'package:hermez/src/data/network/configuration_service.dart';
import 'package:hermez/src/domain/security/security_repository.dart';

class SecurityInLocalRepository implements SecurityRepository {
  final IConfigurationService _configurationService;
  SecurityInLocalRepository(this._configurationService);

  @override
  Future<String> createPin(String pin) {
    // TODO: implement createPin
    throw UnimplementedError();
  }

  @override
  Future<bool> confirmPin(String pin) {
    // TODO: implement confirmPin
    throw UnimplementedError();
  }

  @override
  Future<bool> isValidPin(String pin) async {
    String pinSaved = await _configurationService.getPasscode();
    return pinSaved == pin;
  }
}
