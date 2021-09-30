import 'package:hermez/src/domain/settings/settings_repository.dart';
import 'package:hermez/src/domain/transactions/transaction.dart';

class LevelUseCase {
  final SettingsRepository _settingsRepository;

  LevelUseCase(this._settingsRepository);

  Future<TransactionLevel> getLevel() async {
    return _settingsRepository.getLevel();
  }

  Future<void> setLevel(TransactionLevel level) async {
    _settingsRepository.updateLevel(level);
  }
}
