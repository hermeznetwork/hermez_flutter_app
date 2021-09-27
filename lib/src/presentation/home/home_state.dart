import 'package:flutter/widgets.dart';

abstract class HomeState {
  final HomeItemState onboardingItem;
  HomeState({@required this.onboardingItem});

  factory HomeState.init() => InitHomeState();

  factory HomeState.mnemonicCreated(HomeItemState homeItem) =>
      MnemonicCreatedState(homeItem: homeItem);

  factory HomeState.mnemonicConfirmed() => MnemonicConfirmedState();

  factory HomeState.error(String message) => ErrorHomeState(message: message);
}

class InitHomeState extends HomeState {
  InitHomeState();
}

class MnemonicCreatedState extends HomeState {
  final HomeItemState homeItem;

  MnemonicCreatedState({@required this.homeItem});
}

class MnemonicConfirmedState extends HomeState {
  MnemonicConfirmedState();
}

class ErrorHomeState<T> extends HomeState {
  final String message;

  ErrorHomeState({@required this.message});
}

class HomeItemState {
  final bool walletInitialized;

  HomeItemState(this.walletInitialized);
}
