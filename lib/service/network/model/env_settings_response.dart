class EnvResponseResponse {
  final int chainId;
  final int minReward;

  EnvResponseResponse({this.chainId, this.minReward});

  factory EnvResponseResponse.fromJson(Map<String, dynamic> json) {
    return EnvResponseResponse(
      chainId: json['chainId'],
      minReward: json['minReward'],
    );
  }

  Map<String, dynamic> toJson() => {
        'chainId': chainId,
        'minReward': minReward,
      };
}
