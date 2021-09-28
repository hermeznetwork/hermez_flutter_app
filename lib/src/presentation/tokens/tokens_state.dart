import 'package:flutter/widgets.dart';
import 'package:hermez/src/domain/tokens/token.dart';

abstract class TokensState {
  final TokensItemState tokensItem;
  TokensState({@required this.tokensItem});

  factory TokensState.loading() => LoadingTokensState();

  factory TokensState.loaded(TokensItemState tokensItem) =>
      LoadedTokensState(tokensItem: tokensItem);

  factory TokensState.error(String message) =>
      ErrorTokensState(message: message);
}

class LoadingTokensState extends TokensState {
  LoadingTokensState();
}

class LoadedTokensState extends TokensState {
  final TokensItemState tokensItem;

  LoadedTokensState({@required this.tokensItem});
}

class ErrorTokensState<T> extends TokensState {
  final String message;

  ErrorTokensState({@required this.message});
}

class TokensItemState {
  final List<Token> tokens;

  TokensItemState(this.tokens);
}
