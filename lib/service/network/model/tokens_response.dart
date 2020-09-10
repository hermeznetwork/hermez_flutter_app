import 'package:hermez/service/network/model/pagination.dart';

import 'token.dart';

class TokensResponse {
  final List<Token> tokens;
  final Pagination pagination;

  TokensResponse({this.tokens, this.pagination});

  factory TokensResponse.fromJson(Map<String, dynamic> json) {
    return TokensResponse(
        tokens: json['tokens'],
        pagination: json['pagination']);
  }

  Map<String, dynamic> toJson() => {
    'tokens': tokens,
    'pagination': pagination
  };

}
