

class Exit {
  final int batchNum;
  final String accountIndex;
  final String merkleProof;
  final String balance;
  final String nullifier;
  final int instantWithdrawn;
  final String delayedWithdrawRequest;
  final int delayedWithdrawn;

  Exit({this.batchNum, this.accountIndex, this.merkleProof, this.balance, this.nullifier, this.instantWithdrawn, this.delayedWithdrawRequest, this.delayedWithdrawn});

  factory Exit.fromJson(Map<String, dynamic> json) {
    return Exit(
        batchNum: json['batchNum'],
        accountIndex: json['accountIndex'],
        merkleProof: json['merkleProof'],
        balance: json['balance'],
        nullifier: json['nullifier'],
        instantWithdrawn: json['instantWithdrawn'],
        delayedWithdrawRequest: json['delayedWithdrawRequest'],
        delayedWithdrawn: json['delayedWithdrawn']
    );
  }

  Map<String, dynamic> toJson() => {
    'batchNum': batchNum,
    'accountIndex': accountIndex,
    'merkleProof': merkleProof,
    'balance': balance,
    'nullifier': nullifier,
    'instantWithdrawn': instantWithdrawn,
    'delayedWithdrawRequest': delayedWithdrawRequest,
    'delayedWithdrawn': delayedWithdrawn
  };

}
