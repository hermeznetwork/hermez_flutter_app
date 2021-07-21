import 'airdrop.dart';

class AirdropInfo {
  final Airdrop airdrop;
  final double rewardPercentage;
  final bool eligible;
  final double earnedReward;

  AirdropInfo({
    this.airdrop,
    this.rewardPercentage,
    this.eligible,
    this.earnedReward,
  });

  factory AirdropInfo.fromJson(Map<String, dynamic> json) {
    return AirdropInfo(
      airdrop: Airdrop.fromJson(json['airdrop']),
      rewardPercentage: json['rewardPercentage'],
      eligible: json['eligible'],
      earnedReward: json['earnedReward'],
    );
  }

  Map<String, dynamic> toJson() => {
        'airdrop': airdrop.toJson(),
        'rewardPercentage': rewardPercentage,
        'eligible': eligible,
        'earnedReward': earnedReward,
      };
}
