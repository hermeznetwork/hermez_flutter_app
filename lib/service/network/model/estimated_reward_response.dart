class EstimatedRewardResponse {
  final String estimatedReward;

  EstimatedRewardResponse({this.estimatedReward});

  factory EstimatedRewardResponse.fromJson(Map<String, dynamic> json) {
    return EstimatedRewardResponse(
      estimatedReward: json['estimatedReward'],
    );
  }

  Map<String, dynamic> toJson() => {
        'estimatedReward': estimatedReward,
      };
}
