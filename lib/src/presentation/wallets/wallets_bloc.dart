import 'package:hermez/src/common/bloc/bloc.dart';
import 'package:hermez/src/domain/accounts/account.dart';
import 'package:hermez/src/domain/accounts/usecases/get_accounts_use_case.dart';
import 'package:hermez/src/domain/transactions/transaction_repository.dart';
import 'package:hermez/src/domain/transactions/usecases/get_transactions_use_case.dart';
import 'package:hermez/src/domain/wallets/usecases/get_wallets_use_case.dart';
import 'package:hermez/src/domain/wallets/wallet.dart';
import 'package:hermez/src/presentation/wallets/wallets_state.dart';

class WalletsBloc extends Bloc<WalletsState> {
  final GetWalletsUseCase _getWalletsUseCase;
  final GetAccountsUseCase _getAccountsUseCase;
  final GetAllTransactionsUseCase _getAllTransactionsUseCase;

  List<WalletItemState> walletItems;

  WalletsBloc(this._getWalletsUseCase, this._getAccountsUseCase,
      this._getAllTransactionsUseCase) {
    changeState(WalletsState.loading());
  }

  void fetchData() {
    _getWalletsUseCase.execute().then((wallets) {
      walletItems = _mapWalletsToState(wallets);
      if (wallets.isNotEmpty) {
        changeState(WalletsState.loaded(_mapWalletsToState(wallets)));
      } else {
        changeState(WalletsState.error('Wallet is not initialized'));
      }
    }).catchError((error) {
      changeState(WalletsState.error('A network error has occurred'));
    });
  }

  Future<bool> refreshAccounts(
      [LayerFilter layerFilter = LayerFilter.ALL]) async {
    if (layerFilter == LayerFilter.ALL) {
      for (WalletItemState walletItem in walletItems) {
        await _getAccountsUseCase
            .execute(
                walletItem.l2Wallet == true ? LayerFilter.L2 : LayerFilter.L1,
                walletItem.address)
            .then((accounts) {
          walletItem.accounts = accounts;
        }).catchError((error) {
          changeState(WalletsState.error('A network error has occurred'));
        });
      }
      changeState(WalletsState.loaded(walletItems));
      return true;
    } else if (layerFilter == LayerFilter.L2) {
      WalletItemState walletItem = walletItems.firstWhere((walletItem) =>
          layerFilter == LayerFilter.L2 && walletItem.l2Wallet == true);
      return await _getAccountsUseCase
          .execute(layerFilter, walletItem.address)
          .then((accounts) {
        walletItem.accounts = accounts;
        changeState(WalletsState.loaded(walletItems));
        return true;
      }).catchError((error) {
        changeState(WalletsState.error('A network error has occurred'));
        return false;
      });
    } else if (layerFilter == LayerFilter.L1) {
      WalletItemState walletItem = walletItems.firstWhere((walletItem) =>
          layerFilter == LayerFilter.L1 && walletItem.l2Wallet == false);
      return await _getAccountsUseCase
          .execute(layerFilter, walletItem.address)
          .then((accounts) {
        walletItem.accounts = accounts;
        changeState(WalletsState.loaded(walletItems));
        return true;
      }).catchError((error) {
        changeState(WalletsState.error('A network error has occurred'));
        return false;
      });
    } else {
      return false;
    }
  }

  Future<void> refreshTransactions([Account account]) async {
    if (account != null) {
      if (account.accountIndex != null) {
        WalletItemState wallet =
            walletItems.firstWhere((wallet) => wallet.l2Wallet == true);
        Account walletAccount = wallet.accounts.firstWhere((walletAccount) =>
            walletAccount.accountIndex == account.accountIndex);
        _getAllTransactionsUseCase.execute(
            LayerFilter.L2,
            walletAccount.address,
            walletAccount.accountIndex,
            [walletAccount.token.token.id]).then((transactions) {
          walletAccount.transactions = transactions;
        });
      } else {
        WalletItemState wallet =
            walletItems.firstWhere((wallet) => wallet.l2Wallet == false);
        Account walletAccount = wallet.accounts.firstWhere(
            (walletAccount) => walletAccount.address == account.address);
        _getAllTransactionsUseCase.execute(
            LayerFilter.L1,
            walletAccount.address,
            walletAccount.accountIndex,
            [walletAccount.token.token.id]).then((transactions) {
          walletAccount.transactions = transactions;
        });
      }
    } else {
      for (WalletItemState walletItem in walletItems) {
        for (Account account in walletItem.accounts) {
          _getAllTransactionsUseCase.execute(
              walletItem.l2Wallet == true ? LayerFilter.L2 : LayerFilter.L1,
              account.address,
              account.accountIndex,
              [account.token.token.id]).then((transactions) {
            account.transactions = transactions;
          });
        }
      }
    }
    changeState(WalletsState.loaded(walletItems));
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
