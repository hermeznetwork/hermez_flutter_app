import 'package:hermez/src/domain/prices/price_repository.dart';
import 'package:hermez/src/domain/prices/price_token.dart';
import 'package:hermez/src/domain/tokens/token.dart';
import 'package:hermez/src/domain/tokens/token_repository.dart';
import 'package:hermez_sdk/model/token.dart' as hezToken;

class GetTokensUseCase {
  final TokenRepository _tokenRepository;
  final PriceRepository _priceRepository;

  GetTokensUseCase(this._tokenRepository, this._priceRepository);

  Future<List<Token>> execute([List<int> tokenIds]) async {
    if (tokenIds == null) {
      tokenIds = [];
    }
    List<hezToken.Token> hezTokens = await _tokenRepository.getTokens(tokenIds);
    List<PriceToken> priceTokens =
        await _priceRepository.getTokensPrices(tokenIds);

    List<Token> tokens = [];

    tokens.addAll(hezTokens.map((hezToken) {
      PriceToken priceToken =
          priceTokens.firstWhere((priceToken) => priceToken.id == hezToken.id);
      return Token(token: hezToken, price: priceToken);
    }));

    return tokens;
  }
}
