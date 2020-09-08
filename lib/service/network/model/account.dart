

class Account {
  final int accountIndex;
  final int tokenId;
  final String tokenSymbol;
  final int nonce;
  final String balance;
  final String publicKey;
  final String ethereumAddress;

  Account({this.accountIndex, this.tokenId, this.tokenSymbol, this.nonce, this.balance, this.publicKey, this.ethereumAddress});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
        accountIndex: json['accountIndex'],
        tokenId: json['tokenId'],
        tokenSymbol: json['tokenSymbol'],
        nonce: json['nonce'],
        balance: json['balance'],
        publicKey: json['publicKey'],
        ethereumAddress: json['ethereumAddress']);
  }

  Map<String, dynamic> toJson() => {
    'accountIndex': accountIndex,
    'tokenId': tokenId,
    'tokenSymbol': tokenSymbol,
    'nonce': nonce,
    'balance': balance,
    'publicKey': publicKey,
    'ethereumAddress': ethereumAddress,
  };

}
