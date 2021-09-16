import 'package:hermez/src/domain/prices/price_token.dart';

class TokensResponse {
  final List<PriceToken> tokens;

  TokensResponse({this.tokens});

  factory TokensResponse.fromJson(Map<String, dynamic> json) {
    List<PriceToken> priceTokens = (json['tokens'] as List)
        .map((item) => PriceToken.fromJson(item))
        .toList();
    return TokensResponse(
      tokens: priceTokens,
    );
  }

  Map<String, dynamic> toJson() => {
        'tokens': tokens,
      };
}
