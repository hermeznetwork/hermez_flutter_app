import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hermez/model/wallet.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IConfigurationService {
  Future<void> setMnemonic(String value);
  Future<void> setupDone(bool value);
  Future<void> setPrivateKey(String value);
  Future<void> setHermezPrivateKey(String value);
  Future<void> setBabyJubJubHex(String value);
  Future<void> setBabyJubJubBase64(String value);
  Future<void> setEthereumAddress(String value);
  Future<void> setHermezAddress(String value);
  Future<void> setDefaultCurrency(WalletDefaultCurrency defaultCurrency);
  Future<String> getMnemonic();
  Future<String> getPrivateKey();
  Future<String> getHermezPrivateKey();
  Future<String> getBabyJubJubHex();
  Future<String> getBabyJubJubBase64();
  Future<String> getEthereumAddress();
  Future<String> getHermezAddress();
  Future<WalletDefaultCurrency> getDefaultCurrency();
  bool didSetupWallet();
}

class ConfigurationService implements IConfigurationService {
  SharedPreferences _preferences;
  FlutterSecureStorage _secureStorage;
  ConfigurationService(this._preferences, this._secureStorage);

  @override
  Future<void> setMnemonic(String value) async {
    await _secureStorage.write(key: "mnemonic", value: value);
  }

  @override
  Future<void> setPrivateKey(String value) async {
    await _secureStorage.write(key: "privateKey", value: value);
  }

  @override
  Future<void> setHermezPrivateKey(String value) async {
    await _secureStorage.write(key: "hermezPrivateKey", value: value);
  }

  @override
  Future<void> setBabyJubJubHex(String value) async {
    await _secureStorage.write(key: "babyJubJubHex", value: value);
  }

  @override
  Future<void> setBabyJubJubBase64(String value) async {
    await _secureStorage.write(key: "babyJubJubBase64", value: value);
  }

  @override
  Future<void> setEthereumAddress(String value) async {
    await _secureStorage.write(key: "ethereumAddress", value: value);
  }

  @override
  Future<void> setHermezAddress(String value) async {
    await _secureStorage.write(key: "hermezAddress", value: value);
  }

  @override
  Future<void> setDefaultCurrency(WalletDefaultCurrency value) async {
    await _secureStorage.write(
        key: "defaultCurrency", value: value.toString().split(".").last);
  }

  Future<void> setExchangeRatio(double value) async {
    await _preferences.setDouble("exchangeRatio", value);
  }

  @override
  Future<void> setLevelSelected(TransactionLevel value) async {
    await _secureStorage.write(
        key: "levelSelected", value: value.toString().split(".").last);
  }

  @override
  Future<void> setupDone(bool value) async {
    await _preferences.setBool("didSetupWallet", value);
  }

  // gets
  @override
  Future<String> getMnemonic() async {
    return await _secureStorage.read(key: "mnemonic");
  }

  @override
  Future<String> getPrivateKey() async {
    return _secureStorage.read(key: "privateKey");
  }

  @override
  Future<String> getHermezPrivateKey() async {
    return _secureStorage.read(key: "hermezPrivateKey");
  }

  @override
  Future<String> getBabyJubJubHex() async {
    return _secureStorage.read(key: "babyJubJubHex");
  }

  @override
  Future<String> getBabyJubJubBase64() async {
    return _secureStorage.read(key: "babyJubJubBase64");
  }

  @override
  Future<String> getEthereumAddress() async {
    return _secureStorage.read(key: "ethereumAddress");
  }

  @override
  Future<String> getHermezAddress() async {
    return _secureStorage.read(key: "hermezAddress");
  }

  @override
  Future<WalletDefaultCurrency> getDefaultCurrency() async {
    String defaultCurrencyString =
        await _secureStorage.read(key: "defaultCurrency");
    if (defaultCurrencyString == "EUR") {
      return WalletDefaultCurrency.EUR;
    } else {
      return WalletDefaultCurrency.USD;
    }
  }

  @override
  double getExchangeRatio() {
    return _preferences.getDouble("exchangeRatio") ?? 0.0;
  }

  @override
  Future<TransactionLevel> getLevelSelected() async {
    String levelSelected = await _secureStorage.read(key: "levelSelected");
    if (levelSelected == "LEVEL2") {
      return TransactionLevel.LEVEL2;
    } else {
      return TransactionLevel.LEVEL1;
    }
  }

  @override
  bool didSetupWallet() {
    return _preferences.getBool("didSetupWallet") ?? false;
  }
}
