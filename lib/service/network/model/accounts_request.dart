
class AccountsRequest {
  final String hermezEthereumAddress;
  final List<int> tokenIds;
  final int offset;
  final int limit;

  AccountsRequest({this.hermezEthereumAddress, this.tokenIds, this.offset, this.limit});

  factory AccountsRequest.fromJson(Map<String, dynamic> json) {
    return AccountsRequest(
        hermezEthereumAddress: json['hermezEthereumAddress'],
        tokenIds: json['tokenIds'],
        offset: json['offset'],
        limit: json['limit']
    );
  }

  Map<String, dynamic> toJson() => {
    'hermezEthereumAddress': hermezEthereumAddress,
    'tokenIds': tokenIds,
    'offset': offset,
    'limit': limit,
  };

  Map<String, String> toQueryParams() => {
    'tokenIds': tokenIds.toString(),
    'offset': offset.toString(),
    'limit': limit.toString(),
  };

}
