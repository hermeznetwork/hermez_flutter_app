import 'package:hermez/model/wallet.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez/service/network/model/purchase.dart';
import 'package:hermez_sdk/model/account.dart';
import 'package:hermez_sdk/model/exit.dart';
import 'package:hermez_sdk/model/pool_transaction.dart';
import 'package:hermez_sdk/model/token.dart';

abstract class WalletAction {}

class WalletInitialized extends WalletAction {
  WalletInitialized(this.address, this.privateKey);
  final String address;
  final String privateKey;
}

class InitializingWallet extends WalletAction {}

class BalanceUpdated extends WalletAction {
  BalanceUpdated(this.ethBalance, this.tokensBalance);
  final BigInt ethBalance;
  final Map<String, BigInt> tokensBalance;
}

class UpdatingBalance extends WalletAction {}

class WalletUpdated extends WalletAction {
  WalletUpdated(
    this.tokens,
    this.l1Accounts,
    this.l2Accounts,
    this.payTransactions,
    this.exits,
    this.pendingL2Txs,
    this.pendingL1Transfers,
    this.pendingDeposits,
    this.pendingWithdraws,
    this.pendingForceExits,
    /*
      this.pendingL1Txs, this.pendingForceExits*/
  );
  final List<Token> tokens;
  final List<Account> l1Accounts;
  final List<Account> l2Accounts;
  final List<Purchase> payTransactions;
  final List<Exit> exits;
  final List<PoolTransaction> pendingL2Txs;
  final List<dynamic> pendingL1Transfers;
  final List<dynamic> pendingDeposits;
  final List<dynamic> pendingWithdraws;
  final List<dynamic> pendingForceExits;

  /*final List<dynamic> pendingL1Txs;
  final List<dynamic> pendingForceExits;
  */
}

class UpdatingWallet extends WalletAction {}

class DefaultCurrencyUpdated extends WalletAction {
  DefaultCurrencyUpdated(this.defaultCurrency);
  final WalletDefaultCurrency defaultCurrency;
}

class DefaultFeeUpdated extends WalletAction {
  DefaultFeeUpdated(this.defaultFee);
  final WalletDefaultFee defaultFee;
}

class ExchangeRatioUpdated extends WalletAction {
  ExchangeRatioUpdated(this.exchangeRatio);
  final double exchangeRatio;
}

class LevelUpdated extends WalletAction {
  LevelUpdated(this.txLevel);
  final TransactionLevel txLevel;
}

// transaction

class TransactionStarted extends WalletAction {}

class TransactionFinished extends WalletAction {}

Wallet reducer(Wallet state, WalletAction action) {
  if (action is WalletInitialized) {
    return state.rebuild((b) => b
      ..loading = false
      ..walletInitialized = true
      ..ethereumAddress = action.address
      ..ethereumPrivateKey = action.privateKey);
  }

  if (action is InitializingWallet) {
    return state.rebuild((b) => b..loading = true);
  }

  if (action is UpdatingBalance) {
    return state.rebuild((b) => b..loading = true);
  }

  if (action is BalanceUpdated) {
    return state.rebuild((b) => b
      ..loading = false
      ..ethBalance = action.ethBalance
      ..tokensBalance = action.tokensBalance);
  }

  if (action is UpdatingWallet) {
    return state.rebuild((b) => b..loading = true);
  }

  if (action is WalletUpdated) {
    return state.rebuild((b) => b
      ..loading = false
      ..tokens = action.tokens
      ..l1Accounts = action.l1Accounts
      ..l2Accounts = action.l2Accounts
      ..payTransactions = action.payTransactions
      ..exits = action.exits
      ..pendingL2Txs = action.pendingL2Txs
      ..pendingL1Transfers = action.pendingL1Transfers
      ..pendingDeposits = action.pendingDeposits
      ..pendingWithdraws = action.pendingWithdraws
      ..pendingForceExits = action.pendingForceExits);
  }

  if (action is DefaultCurrencyUpdated) {
    return state.rebuild((b) => b..defaultCurrency = action.defaultCurrency);
  }

  if (action is DefaultFeeUpdated) {
    return state.rebuild((b) => b..defaultFee = action.defaultFee);
  }

  if (action is ExchangeRatioUpdated) {
    return state.rebuild((b) => b..exchangeRatio = action.exchangeRatio);
  }

  if (action is LevelUpdated) {
    return state.rebuild((b) => b..txLevel = action.txLevel);
  }

  if (action is TransactionStarted) {
    return state.rebuild((b) => b..loading = true);
  }

  if (action is TransactionFinished) {
    return state.rebuild((b) => b..loading = false);
  }

  return state;
}
