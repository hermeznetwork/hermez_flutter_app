import 'dart:collection';

import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez/src/domain/wallets/wallet.dart';
import 'package:local_auth/local_auth.dart';

abstract class SettingsRepository {
  Future<WalletDefaultCurrency> getDefaultCurrency();
  Future<void> updateDefaultCurrency(WalletDefaultCurrency defaultCurrency);
  Future<double> getExchangeRatio(WalletDefaultCurrency defaultCurrency);
  Future<bool> updateExchangeRatios(LinkedHashMap<String, dynamic> ratios);
  Future<WalletDefaultFee> getDefaultFee();
  Future<void> updateDefaultFee(WalletDefaultFee defaultFee);
  Future<TransactionLevel> getLevel();
  Future<void> updateLevel(TransactionLevel txLevel);

  // Biometrics
  Future<List<BiometricType>> getAvailableBiometrics();
  Future<bool> authenticateWithBiometrics(String infoDescription);
  bool getBiometricsFace();
  Future<void> updateBiometricsFace(bool value);
  bool getBiometricsFingerprint();
  Future<void> updateBiometricsFingerprint(bool value);

  // Explorer
  Future<bool> showInBatchExplorer(String hermezAddress);

  // Address
  Future<String> getHermezAddress();
  Future<String> getEthereumAddress();

  // Private
  Future<String> getRecoveryPhrase();

  Future<bool> resetDefault();
}
