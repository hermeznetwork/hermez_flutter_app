import 'package:flutter/widgets.dart';

abstract class SecurityState {
  final PinItemState pinItem;
  SecurityState({@required this.pinItem});

  factory SecurityState.init() => InitPinState();

  factory SecurityState.pinCreated(PinItemState pinItem) =>
      PinCreatedState(pinItem: pinItem);

  factory SecurityState.pinConfirmed(PinItemState pinItem) =>
      PinConfirmedState(pinItem: pinItem);

  factory SecurityState.error(String message) =>
      ErrorPinState(message: message);
}

class InitPinState extends SecurityState {
  InitPinState();
}

class PinCreatedState extends SecurityState {
  final PinItemState pinItem;

  PinCreatedState({@required this.pinItem});
}

class PinConfirmedState extends SecurityState {
  final PinItemState pinItem;

  PinConfirmedState({@required this.pinItem});
}

class ErrorPinState<T> extends SecurityState {
  final String message;

  ErrorPinState({@required this.message});
}

class PinItemState {
  final String pin;

  PinItemState(this.pin);
}
