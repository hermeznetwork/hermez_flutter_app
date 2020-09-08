
import 'package:hermez/service/network/model/account.dart';
import 'package:hermez/service/network/model/pagination.dart';

class AccountsResponse {
  final List<Account> accounts;
  final Pagination pagination;

  AccountsResponse({this.accounts, this.pagination});

  factory AccountsResponse.fromJson(Map<String, dynamic> json) {
    return AccountsResponse(
        accounts: json['accounts'],
        pagination: json['pagination']);
  }

  Map<String, dynamic> toJson() => {
    'accounts': accounts,
    'pagination': pagination,
  };

}
