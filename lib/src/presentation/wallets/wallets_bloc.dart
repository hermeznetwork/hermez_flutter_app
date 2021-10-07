import 'package:hermez/src/common/bloc/bloc.dart';
import 'package:hermez/src/domain/wallets/usecases/get_wallets_use_case.dart';
import 'package:hermez/src/domain/wallets/wallet.dart';
import 'package:hermez/src/presentation/wallets/wallets_state.dart';

class WalletsBloc extends Bloc<WalletsState> {
  final GetWalletsUseCase _getWalletsUseCase;

  WalletsBloc(this._getWalletsUseCase) {
    changeState(WalletsState.loading());
  }

  void fetchData() {
    _getWalletsUseCase.execute().then((wallets) {
      if (wallets.isNotEmpty) {
        changeState(WalletsState.loaded(_mapWalletsToState(wallets)));
      } else {
        changeState(WalletsState.error('Wallet is not initialized'));
      }
    }).catchError((error) {
      changeState(WalletsState.error('A network error has occurred'));
    });
  }

  List<WalletItemState> _mapWalletsToState(List<Wallet> wallets) {
    List<WalletItemState> walletItems = [];
    if (wallets != null && wallets.length > 0) {
      Wallet wallet = wallets[0];
      if (wallet.l1Address != null && wallet.l1Address.isNotEmpty) {
        String formattedBalance = wallet.totalL1Balance.toString();
        walletItems.add(WalletItemState(false, wallet.l1Address,
            formattedBalance, wallet.l1Accounts, wallet.isBackedUp));
      }
      if (wallet.l2Address != null && wallet.l2Address.isNotEmpty) {
        String formattedBalance = wallet.totalL2Balance.toString();
        walletItems.add(WalletItemState(true, wallet.l2Address,
            formattedBalance, wallet.l2Accounts, wallet.isBackedUp));
      }
    }
    return walletItems;
  }
}
