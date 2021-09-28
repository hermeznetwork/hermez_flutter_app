import 'package:hermez_sdk/model/token.dart';

abstract class TokenRepository {
  Future<List<Token>> getTokens([List<int> tokensIds]);

  Future<Token> getTokenById(int tokenId);
/*@override
  Future<List<Token>> getTokens() async {
    final TokensRequest tokensRequest = null;
    final tokensResponse = await api.getTokens(
        tokenIds: tokensRequest != null ? tokensRequest.ids : List.empty(),
        limit: 2049);
    return tokensResponse.tokens;
  }

  @override
  Future<Token> getTokenById(int tokenId) async {
    final tokenResponse = await api.getToken(tokenId);
    return tokenResponse;
  }*/
}
