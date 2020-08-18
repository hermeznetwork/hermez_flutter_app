import 'package:built_collection/built_collection.dart';
import 'package:hermezwallet/model/wallet.dart';

abstract class WalletAction {}

class InitialiseWallet extends WalletAction {
  InitialiseWallet(this.address, this.privateKey, this.defaultCurrency);
  final String address;
  final String privateKey;
  final WalletDefaultCurrency defaultCurrency;
}

class BalanceUpdated extends WalletAction {
  BalanceUpdated(this.ethBalance, this.tokenBalance, this.cryptoList);
  final BigInt ethBalance;
  final BigInt tokenBalance;
  final List cryptoList;
}

class UpdatingBalance extends WalletAction {}

class DefaultCurrencyUpdated extends WalletAction {
  DefaultCurrencyUpdated(this.defaultCurrency);
  final WalletDefaultCurrency defaultCurrency;
}

Wallet reducer(Wallet state, WalletAction action) {
  if (action is InitialiseWallet) {
    return state.rebuild((b) => b
      ..address = action.address
      ..privateKey = action.privateKey
      ..defaultCurrency = action.defaultCurrency);
  }

  if (action is UpdatingBalance) {
    return state.rebuild((b) => b..loading = true);
  }

  if (action is BalanceUpdated) {
    return state.rebuild((b) => b
      ..loading = false
      ..ethBalance = action.ethBalance
      ..tokenBalance = action.tokenBalance
      ..cryptoList = action.cryptoList);
  }

  if (action is DefaultCurrencyUpdated) {
    return state.rebuild((b) => b
      ..defaultCurrency = action.defaultCurrency);
  }

  return state;
}
