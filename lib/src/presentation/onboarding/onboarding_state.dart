import 'package:flutter/widgets.dart';

abstract class OnboardingState {
  final OnboardingItemState onboardingItem;
  OnboardingState({@required this.onboardingItem});

  factory OnboardingState.init() => InitOnboardingState();

  factory OnboardingState.mnemonicCreated(OnboardingItemState onboardingItem) =>
      MnemonicCreatedState(onboardingItem: onboardingItem);

  factory OnboardingState.mnemonicConfirmed() => MnemonicConfirmedState();

  factory OnboardingState.error(String message) =>
      ErrorOnboardingState(message: message);
}

class InitOnboardingState extends OnboardingState {
  InitOnboardingState();
}

class MnemonicCreatedState extends OnboardingState {
  final OnboardingItemState onboardingItem;

  MnemonicCreatedState({@required this.onboardingItem});
}

class MnemonicConfirmedState extends OnboardingState {
  MnemonicConfirmedState();
}

class ErrorOnboardingState<T> extends OnboardingState {
  final String message;

  ErrorOnboardingState({@required this.message});
}

class OnboardingItemState {
  final String mnemonic;

  OnboardingItemState(this.mnemonic);
}
