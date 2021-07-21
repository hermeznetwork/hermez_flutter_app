import 'package:hermez/service/network/model/reward.dart';
import 'package:hermez/service/network/model/reward_token_weight.dart';
import 'package:hermez_sdk/model/token.dart';

import 'airdrop.dart';

class BlockRewardsResponse {
  final int blockNumber;
  final Airdrop airdrop;
  final List<Token> tokens;
  final List<RewardTokenWeight> tokenWeights;
  final String totalParticipation;
  final String normalizationFactor;
  final List<Reward> rewards;

  BlockRewardsResponse(
      {this.blockNumber,
      this.airdrop,
      this.tokens,
      this.tokenWeights,
      this.totalParticipation,
      this.normalizationFactor,
      this.rewards});

  factory BlockRewardsResponse.fromJson(Map<String, dynamic> json) {
    Airdrop airdrop = Airdrop.fromJson(json['airdrop']);
    List<Token> tokens =
        (json['tokens'] as List).map((item) => Token.fromJson(item)).toList();
    List<RewardTokenWeight> tokenWeights = (json['tokenWeights'] as List)
        .map((item) => RewardTokenWeight.fromJson(item))
        .toList();
    List<Reward> rewards =
        (json['rewards'] as List).map((item) => Reward.fromJson(item)).toList();
    return BlockRewardsResponse(
      blockNumber: json['blockNumber'],
      airdrop: airdrop,
      tokens: tokens,
      tokenWeights: tokenWeights,
      totalParticipation: json['totalParticipation'],
      normalizationFactor: json['normalizationFactor'],
      rewards: rewards,
    );
  }

  Map<String, dynamic> toJson() => {
        'blockNumber': blockNumber,
        'airdrop': airdrop,
        'tokens': tokens,
        'tokenWeights': tokenWeights,
        'totalParticipation': totalParticipation,
        'normalizationFactor': normalizationFactor,
        'rewards': rewards,
      };
}
