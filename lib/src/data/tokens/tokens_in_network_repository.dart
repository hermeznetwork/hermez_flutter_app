import 'package:hermez/src/domain/tokens/token_repository.dart';
import 'package:hermez_sdk/api.dart' as api;
import 'package:hermez_sdk/model/token.dart';

class TokensInNetworkRepository implements TokenRepository {
  TokensInNetworkRepository();

  @override
  Future<List<Token>> getTokens([List<int> tokensIds]) async {
    final tokensResponse = await api.getTokens(
        tokenIds: tokensIds != null ? tokensIds : List.empty(), limit: 2049);
    return tokensResponse.tokens;
  }

  @override
  Future<Token> getTokenById(int tokenId) async {
    final tokenResponse = await api.getToken(tokenId);
    return tokenResponse;
  }
}
