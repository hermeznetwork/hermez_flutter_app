import 'package:hermez/src/common/bloc/bloc.dart';
import 'package:hermez/src/domain/tokens/usecases/tokens_use_case.dart';
import 'package:hermez/src/presentation/tokens/tokens_state.dart';

class TokensBloc extends Bloc<TokensState> {
  final TokensUseCase _getTokensUseCase;

  TokensBloc(this._getTokensUseCase) {
    changeState(TokensState.loading());
  }

  void getTokens() {
    _getTokensUseCase.getTokens().then((tokens) {
      changeState(TokensState.loaded(TokensItemState(tokens)));
    }).catchError((error) {
      changeState(TokensState.error('A network error has occurred'));
    });
  }
}
