import 'package:flutter/widgets.dart';
import 'package:hermez/src/domain/tokens/token.dart';
import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez/src/domain/wallets/wallet.dart';
import 'package:local_auth/local_auth.dart';

abstract class SettingsState {
  final SettingsItemState settings;

  SettingsState(this.settings);

  factory SettingsState.init() => LoadingSettingsState();

  factory SettingsState.loaded(SettingsItemState settings) =>
      LoadedSettingsState(settings: settings);

  factory SettingsState.error(SettingsItemState settings, String message) =>
      ErrorSettingsState(settings: settings, message: message);
}

//class UpdatingWallet extends SettingsState {}

class LoadingSettingsState extends SettingsState {
  LoadingSettingsState({SettingsItemState settings}) : super(settings);
}

class LoadedSettingsState extends SettingsState {
  LoadedSettingsState({SettingsItemState settings}) : super(settings);
}

class ErrorSettingsState<T> extends SettingsState {
  final String message;

  ErrorSettingsState(
      {@required SettingsItemState settings, @required this.message})
      : super(settings);
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
