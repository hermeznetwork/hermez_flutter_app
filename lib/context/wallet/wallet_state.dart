import 'package:hermez/model/wallet.dart';

abstract class WalletAction {}

class InitialiseWallet extends WalletAction {
  InitialiseWallet(this.address, this.privateKey, this.defaultCurrency);
  final String address;
  final String privateKey;
  final WalletDefaultCurrency defaultCurrency;
}

class BalanceUpdated extends WalletAction {
  BalanceUpdated(this.ethBalance, this.tokensBalance, this.cryptoList);
  final BigInt ethBalance;
  final Map<String, BigInt> tokensBalance;
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
      ..tokensBalance = action.tokensBalance
      ..cryptoList = action.cryptoList);
  }

  if (action is DefaultCurrencyUpdated) {
    return state.rebuild((b) => b..defaultCurrency = action.defaultCurrency);
  }

  return state;
}
