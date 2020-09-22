import 'package:hermez/service/network/model/pagination.dart';

import 'token.dart';

class TokensResponse {
  final List<Token> tokens;
  final Pagination pagination;

  TokensResponse({this.tokens, this.pagination});

  factory TokensResponse.fromJson(Map<String, dynamic> parsedJson) {
    var tokensFromJson = parsedJson['tokens'] as List;
    List<Token> tokensList =
        tokensFromJson.map((i) => Token.fromJson(i)).toList();
    final pagination = Pagination.fromJson(parsedJson['pagination']);
    return TokensResponse(tokens: tokensList, pagination: pagination);
  }

  Map<String, dynamic> toJson() => {'tokens': tokens, 'pagination': pagination};
}
