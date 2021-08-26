import 'dart:convert';

import 'package:hermez_sdk/http.dart' as http;
import 'package:visa/auth-data.dart';
import 'package:visa/engine/oauth.dart';
import 'package:visa/engine/simple-auth.dart';
import 'package:visa/engine/visa.dart';

class MarketAuth implements Visa {
  // OAuth base url.
  final baseUrl = 'https://discord.com/api';
  final authUrl = '/oauth2/authorize';

  // SimpleAuth instance
  SimpleAuth visa;

  // Constructor
  MarketAuth() {
    // initialize the SimpleAuth instance
    visa = SimpleAuth(
        // OAuth base url
        baseUrl: baseUrl,

        /// GetAuthData sends a request
        /// to the "user profile" api endpoint
        /// and returns an AuthData object.
        getAuthData: (Map<String, String> data) async {
          var token = data[OAuth.TOKEN_KEY];
          var baseProfileUrl = '/users/@me';
          var profileResponse =
              await http.get(baseUrl, baseProfileUrl, queryParameters: {
            'Authorization': 'Bearer $token',
          });
          var profileJson = json.decode(profileResponse.body);

          return authData(profileJson, data);
        });
  }

  /// This function combines information
  /// from the user [userJson] and auth response [responseData]
  /// to build an [AuthData] object.
  @override
  AuthData authData(
      Map<String, dynamic> userJson, Map<String, String> responseData) {
    final String accessToken = responseData[OAuth.TOKEN_KEY];
    final String userId = userJson['id'] as String;
    final String avatar = userJson['avatar'] as String;
    final String profileImgUrl = 'https://cdn.discordapp.com/'
        'avatars/$userId/$avatar.png';

    return AuthData(
        clientID: responseData['clientID'],
        accessToken: accessToken,
        userID: userId,
        email: userJson['email'] as String,
        profileImgUrl: profileImgUrl,
        response: responseData,
        userJson: userJson);
  }

  @override
  bool debugMode;

  @override
  set debug(bool debugMode) {
    this.debugMode = debugMode;
  }
}
