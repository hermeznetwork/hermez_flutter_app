import 'package:hermez/src/domain/settings/settings_repository.dart';

class PrivateSettingsUseCase {
  final SettingsRepository _settingsRepository;

  PrivateSettingsUseCase(this._settingsRepository);

  Future<String> getRecoveryPhrase() async {
    return await _settingsRepository.getRecoveryPhrase();
  }
}
