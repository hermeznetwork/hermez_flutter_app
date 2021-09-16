import 'package:hermez/src/domain/tokens/token_repository.dart';
import 'package:hermez_sdk/model/token.dart';

class GetTokensUseCase {
  final TokenRepository _tokenRepository;

  GetTokensUseCase(this._tokenRepository);

  Future<List<Token>> execute() {
    return _tokenRepository.getTokens();
  }
}
