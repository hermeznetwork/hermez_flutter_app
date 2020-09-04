
import 'package:hermez/service/network/model/account.dart';

class AccountsResponse {
  final List<Account> accounts;
  final int nextPage;

  AccountsResponse({this.accounts, this.nextPage});

  factory AccountsResponse.fromJson(Map<String, dynamic> json) {
    return AccountsResponse(
        accounts: json['accounts'],
        nextPage: json['nextPage']);
  }

  Map<String, dynamic> toJson() => {
    'accounts': accounts,
    'nextPage': nextPage,
  };

}
