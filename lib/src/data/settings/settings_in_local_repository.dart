import 'dart:collection';

import 'package:hermez/src/data/network/configuration_service.dart';
import 'package:hermez/src/data/network/price_updater_service.dart';
import 'package:hermez/src/domain/settings/settings_repository.dart';
import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez/src/domain/wallets/wallet.dart';
import 'package:hermez/utils/biometrics_utils.dart';
import 'package:hermez_sdk/environment.dart';
import 'package:local_auth/local_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsInLocalRepository implements SettingsRepository {
  final IConfigurationService _configurationService;
  final PriceUpdaterService _priceUpdaterService;
  SettingsInLocalRepository(
      this._configurationService, this._priceUpdaterService);

  // CURRENCY
  @override
  Future<WalletDefaultCurrency> getDefaultCurrency() {
    return _configurationService.getDefaultCurrency();
  }

  @override
  Future<void> updateDefaultCurrency(
      WalletDefaultCurrency defaultCurrency) async {
    _configurationService.setDefaultCurrency(defaultCurrency);
  }

  @override
  Future<double> getExchangeRatio(WalletDefaultCurrency defaultCurrency) async {
    double result = 0;
    if (_configurationService
            .getExchangeRatio(defaultCurrency.toString().split(".").last) ==
        0) {
      try {
        final currenciesPrices =
            await _priceUpdaterService.getCurrenciesPrices();
        await updateExchangeRatios(currenciesPrices);
      } catch (e) {
        LinkedHashMap<String, double> exchangeRatio = LinkedHashMap.from({
          "EUR": 0.837775,
          "CNY": 6.446304,
          "JPY": 110.253954,
          "GBP": 0.716945
        });
        await updateExchangeRatios(exchangeRatio);
      }
    }

    result = _configurationService
        .getExchangeRatio(defaultCurrency.toString().split(".").last);

    return result;
  }

  @override
  Future<bool> updateExchangeRatios(LinkedHashMap<String, dynamic> ratios) {
    return _configurationService.setExchangeRatio(ratios);
  }

  // FEE
  @override
  Future<WalletDefaultFee> getDefaultFee() {
    return _configurationService.getDefaultFee();
  }

  @override
  Future<bool> updateDefaultFee(WalletDefaultFee defaultFee) async {
    return _configurationService.setDefaultFee(defaultFee);
  }

  @override
  Future<void> updateLevel(TransactionLevel txLevel) async {
    await _configurationService.setLevelSelected(txLevel);
  }

  @override
  Future<TransactionLevel> getLevel() {
    return _configurationService.getLevelSelected();
  }

  // Biometrics

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    if (await BiometricsUtils.canCheckBiometrics() &&
        await BiometricsUtils.isDeviceSupported()) {
      availableBiometrics = await BiometricsUtils.getAvailableBiometrics();
    }
    return availableBiometrics;
  }

  @override
  Future<bool> authenticateWithBiometrics(String infoDescription) async {
    bool authenticated = false;
    List<BiometricType> availableBiometrics = await getAvailableBiometrics();
    if (availableBiometrics.contains(BiometricType.face) ||
        availableBiometrics.contains(BiometricType.fingerprint)) {
      authenticated =
          await BiometricsUtils.authenticateWithBiometrics(infoDescription);
    }
    return authenticated;
  }

  @override
  bool getBiometricsFace() {
    return _configurationService.getBiometricsFace();
  }

  @override
  bool getBiometricsFingerprint() {
    return _configurationService.getBiometricsFingerprint();
  }

  @override
  Future<void> updateBiometricsFace(bool value) {
    return _configurationService.setBiometricsFace(value);
  }

  @override
  Future<void> updateBiometricsFingerprint(bool value) {
    return _configurationService.setBiometricsFingerprint(value);
  }

  // Explorer

  @override
  Future<bool> showInBatchExplorer(String hermezAddress) async {
    bool result;
    var url = getCurrentEnvironment().batchExplorerUrl +
        '/user-account/' +
        hermezAddress;
    if (await canLaunch(url)) {
      result = await launch(url);
    }
    return result;
  }

  @override
  Future<bool> resetDefault() async {
    try {
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
    } catch (e) {
      return false;
    }
    return true;
  }

  @override
  Future<String> getHermezAddress() {
    return _configurationService.getHermezAddress();
  }

  @override
  Future<String> getEthereumAddress() {
    return _configurationService.getEthereumAddress();
  }

  @override
  Future<String> getRecoveryPhrase() {
    return _configurationService.getMnemonic();
  }
}
