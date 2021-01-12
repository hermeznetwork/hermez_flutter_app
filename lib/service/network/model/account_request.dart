class AccountRequest {
  final String accountIndex;

  AccountRequest({this.accountIndex});

  factory AccountRequest.fromJson(Map<String, dynamic> json) {
    return AccountRequest(accountIndex: json['accountIndex']);
  }

  Map<String, dynamic> toJson() => {
        'accountIndex': accountIndex,
      };
}
