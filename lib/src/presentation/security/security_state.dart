import 'package:flutter/widgets.dart';

abstract class SecurityState {
  final OnboardingItemState onboardingItem;
  SecurityState({@required this.onboardingItem});

  factory SecurityState.init() => InitOnboardingState();

  factory SecurityState.mnemonicCreated(OnboardingItemState onboardingItem) =>
      MnemonicCreatedState(onboardingItem: onboardingItem);

  factory SecurityState.mnemonicConfirmed() => MnemonicConfirmedState();

  factory SecurityState.error(String message) =>
      ErrorOnboardingState(message: message);
}

class InitOnboardingState extends SecurityState {
  InitOnboardingState();
}

class MnemonicCreatedState extends SecurityState {
  final OnboardingItemState onboardingItem;

  MnemonicCreatedState({@required this.onboardingItem});
}

class MnemonicConfirmedState extends SecurityState {
  MnemonicConfirmedState();
}

class ErrorOnboardingState<T> extends SecurityState {
  final String message;

  ErrorOnboardingState({@required this.message});
}

class OnboardingItemState {
  final String mnemonic;

  OnboardingItemState(this.mnemonic);
}
