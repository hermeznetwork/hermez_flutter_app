import 'package:flutter/widgets.dart';
import 'package:hermez/src/domain/accounts/account.dart';

abstract class WalletsState {
  WalletsState();

  factory WalletsState.loading() => LoadingWalletsState();

  factory WalletsState.loaded(List<WalletItemState> wallets) =>
      LoadedWalletsState(wallets: wallets);

  factory WalletsState.error(String message) =>
      ErrorWalletsState(message: message);
}

class LoadingWalletsState extends WalletsState {
  LoadingWalletsState();
}

class LoadedWalletsState extends WalletsState {
  final List<WalletItemState> wallets;

  LoadedWalletsState({@required this.wallets});
}

class ErrorWalletsState<T> extends WalletsState {
  final String message;

  ErrorWalletsState({@required this.message});
}

class WalletItemState {
  final bool l2Wallet;
  final String address;
  final String totalBalance;
  final List<Account> accounts;

  WalletItemState(
      this.l2Wallet, this.address, this.totalBalance, this.accounts);
}
