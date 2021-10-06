import 'package:flutter/widgets.dart';
import 'package:hermez/src/domain/tokens/token.dart';
import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez/src/domain/wallets/wallet.dart';
import 'package:local_auth/local_auth.dart';

abstract class SettingsState {
  SettingsState();

  factory SettingsState.init() => InitSettingsState();

  factory SettingsState.loading() => LoadingSettingsState();

  factory SettingsState.loaded(SettingsItemState settings) =>
      LoadedSettingsState(settings: settings);

  factory SettingsState.error(String message) =>
      ErrorSettingsState(message: message);
}

class InitSettingsState extends SettingsState {}

class LoadingSettingsState extends SettingsState {}

class LoadedSettingsState extends SettingsState {
  final SettingsItemState settings;

  LoadedSettingsState({@required this.settings});
}

class ErrorSettingsState<T> extends SettingsState {
  final String message;

  ErrorSettingsState({@required this.message});
}

class SettingsItemState {
  String hermezAddress;
  String ethereumAddress;
  WalletDefaultCurrency defaultCurrency;
  WalletDefaultFee defaultFee;
  //double exchangeRatio;
  TransactionLevel level;
  List<BiometricType> availableBiometrics;

  List<Token> tokens;

  SettingsItemState(
      this.hermezAddress,
      this.ethereumAddress,
      this.defaultCurrency,
      this.defaultFee,
      /*this.exchangeRatio,*/ this.level,
      this.availableBiometrics,
      this.tokens);
}
