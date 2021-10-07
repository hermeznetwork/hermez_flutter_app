import 'package:hermez/src/domain/settings/settings_repository.dart';
import 'package:hermez/src/domain/wallets/wallet.dart';

class DefaultCurrencyUseCase {
  final SettingsRepository _settingsRepository;

  DefaultCurrencyUseCase(this._settingsRepository);

  Future<WalletDefaultCurrency> getDefaultCurrency() async {
    return _settingsRepository.getDefaultCurrency();
  }

  Future<void> setDefaultCurrency(WalletDefaultCurrency defaultCurrency) async {
    _settingsRepository.updateDefaultCurrency(defaultCurrency);
  }

  Future<double> getExchangeRatio(WalletDefaultCurrency defaultCurrency) async {
    return _settingsRepository.getExchangeRatio(defaultCurrency);
  }
}
