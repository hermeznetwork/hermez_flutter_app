import 'package:flutter/widgets.dart';

abstract class QrcodeState {
  final OnboardingItemState onboardingItem;
  QrcodeState({@required this.onboardingItem});

  factory QrcodeState.init() => InitOnboardingState();

  factory QrcodeState.mnemonicCreated(OnboardingItemState onboardingItem) =>
      MnemonicCreatedState(onboardingItem: onboardingItem);

  factory QrcodeState.mnemonicConfirmed() => MnemonicConfirmedState();

  factory QrcodeState.error(String message) =>
      ErrorOnboardingState(message: message);
}

class InitOnboardingState extends QrcodeState {
  InitOnboardingState();
}

class MnemonicCreatedState extends QrcodeState {
  final OnboardingItemState onboardingItem;

  MnemonicCreatedState({@required this.onboardingItem});
}

class MnemonicConfirmedState extends QrcodeState {
  MnemonicConfirmedState();
}

class ErrorOnboardingState<T> extends QrcodeState {
  final String message;

  ErrorOnboardingState({@required this.message});
}

class OnboardingItemState {
  final String mnemonic;

  OnboardingItemState(this.mnemonic);
}
