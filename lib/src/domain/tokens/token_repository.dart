import 'package:hermez_sdk/model/token.dart';

abstract class TokenRepository {
  Future<List<Token>> getTokens([List<int> tokensIds]);

  Future<Token> getTokenById(int tokenId);
}
