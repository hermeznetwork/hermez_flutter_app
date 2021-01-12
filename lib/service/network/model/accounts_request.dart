class AccountsRequest {
  final String hezEthereumAddress;
  final String BJJ;
  final List<int> tokenIds;
  final int fromItem;
  final OrderType order;
  final int limit;

  AccountsRequest(
      {this.hezEthereumAddress,
      this.BJJ,
      this.tokenIds,
      this.fromItem,
      this.order,
      this.limit});

  factory AccountsRequest.fromJson(Map<String, dynamic> json) {
    return AccountsRequest(
        hezEthereumAddress: json['hezEthereumAddress'],
        BJJ: json['BJJ'],
        tokenIds: json['tokenIds'],
        fromItem: json['fromItem'],
        order: json['order'],
        limit: json['limit']);
  }

  Map<String, dynamic> toJson() => {
        'hezEthereumAddress': hezEthereumAddress,
        'BJJ': BJJ,
        'tokenIds': tokenIds,
        'fromItem': fromItem,
        'order': _enumToString(order),
        'limit': limit,
      };
}

enum OrderType { ASC, DESC }

String _enumToString(dynamic enumValue) {
  final String enumString = enumValue.toString();
  return enumString.substring(enumString.indexOf('.') + 1);
}
