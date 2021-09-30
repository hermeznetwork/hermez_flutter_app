import 'package:hermez/src/domain/settings/settings_repository.dart';

class ExplorerUseCase {
  final SettingsRepository _settingsRepository;

  ExplorerUseCase(this._settingsRepository);

  Future<bool> showInBatchExplorer(String hermezAddress) async {
    return _settingsRepository.showInBatchExplorer(hermezAddress);
  }
}
