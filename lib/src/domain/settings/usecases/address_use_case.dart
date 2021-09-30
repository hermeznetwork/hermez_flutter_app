import 'package:hermez/src/domain/settings/settings_repository.dart';

class AddressUseCase {
  final SettingsRepository _settingsRepository;

  AddressUseCase(this._settingsRepository);

  Future<String> getHermezAddress() async {
    return await _settingsRepository.getHermezAddress();
  }

  Future<String> getEthereumAddress() async {
    return await _settingsRepository.getEthereumAddress();
  }
}
