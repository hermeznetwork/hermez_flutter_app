
class AccountsRequest {
  final String ethAddr;
  final int tokenId;
  final int nextPage;
  final int limit;

  AccountsRequest({this.ethAddr, this.tokenId, this.nextPage, this.limit});

  factory AccountsRequest.fromJson(Map<String, dynamic> json) {
    return AccountsRequest(
        ethAddr: json['ethAddr'],
        tokenId: json['tokenId'],
        nextPage: json['nextPage'],
        limit: json['limit']
    );
  }

  Map<String, dynamic> toJson() => {
    'ethAddr': ethAddr,
    'tokenId': tokenId,
    'nextPage': nextPage,
    'limit': limit,
  };

  Map<String, String> toQueryParams() => {
    'tokenId': tokenId.toString(),
    'nextPage': nextPage.toString(),
    'limit': limit.toString(),
  };

}
