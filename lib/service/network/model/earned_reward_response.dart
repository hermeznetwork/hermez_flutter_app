class EarnedRewardResponse {
  final String earnedRewards;

  EarnedRewardResponse({this.earnedRewards});

  factory EarnedRewardResponse.fromJson(Map<String, dynamic> json) {
    return EarnedRewardResponse(
      earnedRewards: json['earnedRewards'],
    );
  }

  Map<String, dynamic> toJson() => {
        'earnedRewards': earnedRewards,
      };
}
