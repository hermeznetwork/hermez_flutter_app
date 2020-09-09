
class ForgedTransactionsRequest {
  final int tokenId;
  final String ethereumAddress;
  final String accountIndex;
  final String batchNum;
  final int offset;
  final int limit;

  ForgedTransactionsRequest({this.tokenId, this.ethereumAddress, this.accountIndex, this.batchNum, this.offset, this.limit});

  factory ForgedTransactionsRequest.fromJson(Map<String, dynamic> json) {
    return ForgedTransactionsRequest(
        tokenId: json['tokenId'],
        ethereumAddress: json['ethereumAddress'],
        accountIndex: json['accountIndex'],
        batchNum: json['batchNum'],
        offset: json['offset'],
        limit: json['limit']
    );
  }

  Map<String, dynamic> toJson() => {
    'tokenId': tokenId,
    'ethereumAddress': ethereumAddress,
    'accountIndex': accountIndex,
    'batchNum': batchNum,
    'offset': offset,
    'limit': limit,
  };

}
