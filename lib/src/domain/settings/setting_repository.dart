import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez/src/domain/wallets/wallet.dart';

abstract class SettingRepository {
  Future<void> updateDefaultCurrency(WalletDefaultCurrency defaultCurrency);
  Future<void> updateDefaultFee(WalletDefaultFee defaultFee);
  Future<void> updateLevel(TransactionLevel txLevel);
  Future<void> resetDefault();
}
