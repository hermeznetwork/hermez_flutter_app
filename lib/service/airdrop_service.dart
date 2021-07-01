import 'dart:async';

import 'package:hermez/service/network/api_airdrop_client.dart';
import 'package:hermez/service/network/model/active_airdrops_response.dart';

import 'network/model/accumulated_earned_reward_request.dart';
import 'network/model/airdrop.dart';

abstract class IAirdropService {
  Future<List<Airdrop>> getActiveAirdrops();
  Future<double> getRewardPercentage(int airdropID);
  Future<bool> checkUserEligibility(int airdropID,
      {String ethereumAddress = "", int accountIndex = -1});
}

class AirdropService implements IAirdropService {
  String _baseUrl;
  AirdropService(this._baseUrl);

  ApiAirdropClient _apiAirdropClient() => ApiAirdropClient(_baseUrl);

  @override
  Future<List<Airdrop>> getActiveAirdrops() async {
    bool isRunning = await _apiAirdropClient().getEnvIsRunning();
    if (isRunning) {
      ActiveAirdropsResponse response =
          await _apiAirdropClient().getActiveAirdrops();
      return response.airdrops;
    } else {
      return null;
    }
  }

  Future<double> getRewardPercentage(int airdropID) async {
    String percentage =
        await _apiAirdropClient().getRewardPercentage(airdropID);
    return double.tryParse(percentage) ?? 0.0;
  }

  Future<bool> checkUserEligibility(int airdropID,
      {String ethereumAddress = "", int accountIndex = -1}) async {
    return await _apiAirdropClient().checkUserEligibility(airdropID,
        ethereumAddress: ethereumAddress, accountIndex: accountIndex);
  }

  Future<double> getEarnedReward(List<int> airdropIDs,
      {String ethereumAddress = "", int accountIndex = -1}) async {
    final accumulatedEarnedRequest = AccumulatedEarnedRewardRequest(
        airdropIDs: airdropIDs,
        ethAddr: ethereumAddress,
        accountIndex: accountIndex.toString());
    final earnedRewardResponse = await _apiAirdropClient()
        .getAccumulatedEarnedReward(accumulatedEarnedRequest);
    return double.tryParse(earnedRewardResponse.earnedReward) ?? 0;
    /*EarnedRewardRequest(
        ethAddr: ethereumAddress, accountIndex: accountIndex.toString());*/
    /*return await _apiAirdropClient().getEarnedReward(airdropID,
        ethereumAddress: ethereumAddress, accountIndex: accountIndex);*/
  }
}
