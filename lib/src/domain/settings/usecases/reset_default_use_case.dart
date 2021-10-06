import 'package:hermez/src/domain/settings/settings_repository.dart';

class ResetDefaultUseCase {
  final SettingsRepository _settingsRepository;

  ResetDefaultUseCase(this._settingsRepository);

  Future<bool> resetDefault() async {
    return await _settingsRepository.resetDefault();
  }
}
