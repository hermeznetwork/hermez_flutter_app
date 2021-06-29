class EarnedRewardResponse {
  final String earnedReward;

  EarnedRewardResponse({this.earnedReward});

  factory EarnedRewardResponse.fromJson(Map<String, dynamic> json) {
    return EarnedRewardResponse(
      earnedReward: json['earnedReward'],
    );
  }

  Map<String, dynamic> toJson() => {
        'earnedReward': earnedReward,
      };
}
