import 'package:hermez/src/domain/prices/price_token.dart';
import 'package:hermez_sdk/model/token.dart' as hezToken;

class Token {
  final hezToken.Token token;
  final PriceToken price;

  Token({this.token, this.price});

  factory Token.createEmpty() {
    return Token();
  }

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      token: json['token'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'price': price,
      };
}
