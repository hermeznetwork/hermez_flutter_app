class AccessTokenResponse {
  final String accessToken;
  final String tokenType;
  final num expiresIn;

  AccessTokenResponse({this.accessToken, this.tokenType, this.expiresIn});

  factory AccessTokenResponse.fromJson(Map<String, dynamic> json) {
    return AccessTokenResponse(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      expiresIn: json['expires_in'],
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'token_type': tokenType,
        'expires_in': expiresIn,
      };
}
