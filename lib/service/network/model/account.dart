

class Account {
  final int accountIdx;
  final int tokenId;
  final int nonce;
  final String balance;
  final String publicKey;
  final String ethAddr;

  Account({this.accountIdx, this.tokenId, this.nonce, this.balance, this.publicKey, this.ethAddr});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
        accountIdx: json['accountIdx'],
        tokenId: json['tokenId'],
        nonce: json['nonce'],
        balance: json['balance'],
        publicKey: json['publicKey'],
        ethAddr: json['ethAddr']);
  }

  Map<String, dynamic> toJson() => {
    'accountIdx': accountIdx,
    'tokenId': tokenId,
    'nonce': nonce,
    'balance': balance,
    'publicKey': publicKey,
    'ethAddr': ethAddr,
  };

}
