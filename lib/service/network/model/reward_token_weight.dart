class RewardTokenWeight {
  final int tokenID;
  final int balance;
  final String minBalance;
  final String maxBalance;
  final int transfer;
  final String minTransfer;
  final String maxTransfer;

  RewardTokenWeight(
      {this.tokenID,
      this.balance,
      this.minBalance,
      this.maxBalance,
      this.transfer,
      this.minTransfer,
      this.maxTransfer});

  factory RewardTokenWeight.fromJson(Map<String, dynamic> json) {
    return RewardTokenWeight(
      tokenID: json['tokenID'],
      balance: json['balance'],
      minBalance: json['minBalance'],
      maxBalance: json['maxBalance'],
      transfer: json['transfer'],
      minTransfer: json['minTransfer'],
      maxTransfer: json['maxTransfer'],
    );
  }

  Map<String, dynamic> toJson() => {
        'tokenID': tokenID,
        'balance': balance,
        'minBalance': minBalance,
        'maxBalance': maxBalance,
        'transfer': transfer,
        'minTransfer': minTransfer,
        'maxTransfer': maxTransfer,
      };
}
