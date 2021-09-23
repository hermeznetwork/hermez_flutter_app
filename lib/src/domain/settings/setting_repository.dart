import 'package:hermez/src/domain/wallets/wallet.dart';
import 'package:hermez/src/presentation/transactions/widgets/transaction_amount.dart';

abstract class SettingRepository {
  Future<void> updateDefaultCurrency(WalletDefaultCurrency defaultCurrency);
  Future<void> updateDefaultFee(WalletDefaultFee defaultFee);
  Future<void> updateLevel(TransactionLevel txLevel);
  Future<void> resetDefault();
}
