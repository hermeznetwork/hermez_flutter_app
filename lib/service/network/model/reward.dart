class Reward {
  final String amount;
  final String ethAddr;

  Reward({
    this.amount,
    this.ethAddr,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      amount: json['amount'],
      ethAddr: json['ethAddr'],
    );
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'ethAddr': ethAddr,
      };
}
