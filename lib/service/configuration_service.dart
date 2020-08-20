import 'package:hermez/model/wallet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class IConfigurationService {
  Future<void> setMnemonic(String value);
  Future<void> setupDone(bool value);
  Future<void> setPrivateKey(String value);
  Future<void> setDefaultCurrency(WalletDefaultCurrency defaultCurrency);
  Future<String> getMnemonic();
  Future<String> getPrivateKey();
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
  Future<void> setDefaultCurrency(WalletDefaultCurrency value) async {
    await _secureStorage.write(key: "defaultCurrency", value: value.toString().split(".").last);
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
  Future<WalletDefaultCurrency> getDefaultCurrency() async {
    String defaultCurrencyString = await _secureStorage.read(key: "defaultCurrency");
    if (defaultCurrencyString == "EUR") {
      return WalletDefaultCurrency.EUR;
    } else  if (defaultCurrencyString == "USD") {
      return WalletDefaultCurrency.USD;
    }
    return WalletDefaultCurrency.EUR;
  }

  @override
  bool didSetupWallet() {
    return _preferences.getBool("didSetupWallet") ?? false;
  }
}
