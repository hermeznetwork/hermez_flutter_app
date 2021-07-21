import 'package:hermez/service/network/model/reward.dart';

class RewardsResponse {
  final List<Reward> rewards;

  RewardsResponse({this.rewards});

  factory RewardsResponse.fromJson(Map<String, dynamic> json) {
    List<Reward> rewards =
        (json as List).map((item) => Reward.fromJson(item)).toList();
    return RewardsResponse(
      rewards: rewards,
    );
  }

  Map<String, dynamic> toJson() => {
        'rewards': rewards,
      };
}
