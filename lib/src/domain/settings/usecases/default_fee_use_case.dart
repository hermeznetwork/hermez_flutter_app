import 'package:hermez/src/domain/settings/settings_repository.dart';
import 'package:hermez/src/domain/wallets/wallet.dart';

class DefaultFeeUseCase {
  final SettingsRepository _settingsRepository;

  DefaultFeeUseCase(this._settingsRepository);

  Future<WalletDefaultFee> getDefaultFee() async {
    return _settingsRepository.getDefaultFee();
  }

  Future<void> setDefaultFee(WalletDefaultFee defaultFee) async {
    _settingsRepository.updateDefaultFee(defaultFee);
  }
}
