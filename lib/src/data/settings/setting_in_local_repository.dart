import 'package:hermez/src/data/network/configuration_service.dart';
import 'package:hermez/src/domain/settings/setting_repository.dart';
import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez/src/domain/wallets/wallet.dart';

class SettingInLocalRepository implements SettingRepository {
  final IConfigurationService _configurationService;
  SettingInLocalRepository(this._configurationService);

  @override
  Future<void> updateDefaultCurrency(
      WalletDefaultCurrency defaultCurrency) async {
    _configurationService.setDefaultCurrency(defaultCurrency);
  }

  @override
  Future<void> updateDefaultFee(WalletDefaultFee defaultFee) async {
    _configurationService.setDefaultFee(defaultFee);
  }

  @override
  Future<void> updateLevel(TransactionLevel txLevel) async {
    await _configurationService.setLevelSelected(txLevel);
  }

  @override
  Future<void> resetDefault() async {
    await _configurationService.setMnemonic("");
    await _configurationService.setPrivateKey("");
    await _configurationService.setHermezPrivateKey("");
    await _configurationService.setBabyJubJubHex("");
    await _configurationService.setBabyJubJubBase64("");
    await _configurationService.setEthereumAddress("");
    await _configurationService.setHermezAddress("");
    await _configurationService.setPasscode("");
    await _configurationService.setBiometricsFingerprint(false);
    await _configurationService.setBiometricsFace(false);
    await _configurationService.setDefaultCurrency(WalletDefaultCurrency.USD);
    await _configurationService.setDefaultFee(WalletDefaultFee.AVERAGE);
    await _configurationService.setLevelSelected(TransactionLevel.LEVEL1);
    await _configurationService.setupDone(false);
    await _configurationService.backupDone(false);
  }
}
