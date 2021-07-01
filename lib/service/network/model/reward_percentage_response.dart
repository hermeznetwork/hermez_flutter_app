class RewardPercentageResponse {
  final String percentage;

  RewardPercentageResponse({this.percentage});

  factory RewardPercentageResponse.fromJson(Map<String, dynamic> json) {
    return RewardPercentageResponse(
      percentage: json['percentage'],
    );
  }

  Map<String, dynamic> toJson() => {
        'percentage': percentage,
      };
}
