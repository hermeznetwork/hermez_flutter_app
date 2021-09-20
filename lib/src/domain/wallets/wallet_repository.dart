import 'package:hermez/src/domain/wallets/wallet.dart';

abstract class WalletRepository {
  Future<List<Wallet>> getWallets();
  Future<void> resetWallet();
}
