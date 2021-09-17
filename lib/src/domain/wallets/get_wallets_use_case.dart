import 'package:hermez/src/domain/wallets/wallet.dart';
import 'package:hermez/src/domain/wallets/wallet_repository.dart';

class GetWalletsUseCase {
  final WalletRepository _walletRepository;

  GetWalletsUseCase(this._walletRepository);

  Future<List<Wallet>> execute() {
    return _walletRepository.getWallets();
  }
}
