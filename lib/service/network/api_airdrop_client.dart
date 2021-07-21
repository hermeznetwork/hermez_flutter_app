library api_testing_flutter_kata;

import 'dart:convert';
import 'dart:io';

import 'package:hermez/service/network/model/airdrop.dart';
import 'package:hermez/service/network/model/env_settings_response.dart';
import 'package:hermez/service/network/model/reward_percentage_response.dart';
import 'package:hermez/service/network/model/rewards_response.dart';
import 'package:hermez/service/network/model/user_eligibility_response.dart';
import 'package:http/http.dart' as http2;

import 'api_airdrop_exceptions.dart';
import 'model/accumulated_earned_reward_request.dart';
import 'model/block_rewards_response.dart';
import 'model/earned_reward_request.dart';
import 'model/earned_reward_response.dart';
import 'model/estimated_reward_response.dart';
import 'model/reward.dart';

class ApiAirdropClient {
  final String _baseAddress;

  //final String ESTIMATED_REWARD_URL = "/airdrop/v1/estimated-reward";
  //final String EARNED_REWARD_URL = "/airdrop/v1/earned-reward";
  //final String ACCUMULATED_EARNED_REWARD_URL =
  //   "/airdrop/v1/accumulated-earned-reward";
  //final String REWARD_PERCENTAGE_URL = "/airdrop/v1/reward-percentage";
  final String CHECK_USER_ELIGIBILITY_URL =
      "/airdrop/v1/check-user-eligibility";
  //final String AIRDROPS_INFO_URL = "/airdrop/v1/airdrops/";
  //final String AIRDROPS_ACTIVE_URL = "/airdrop/v1/airdrops/active";
  //final String HEALTH_URL = "/airdrop/v1/health";
  //final String ENV_SETTINGS_URL = "/airdrop/v1/env-settings";

  final String HEALTH_URL = "/v1/health";
  final String ENV_SETTINGS_URL = "/v1/env-settings";
  final String AIRDROPS_URL = "/v1/airdrops";
  final String AIRDROPS_INFO_URL = "/v1/airdrops/";
  final String AIRDROPS_BLOCKS_URL = "/blocks/";
  final String AIRDROPS_REWARDS_URL = "/rewards";
  final String AIRDROPS_ACTIVE_URL = "/active";
  final String ESTIMATED_REWARD_URL = "/v1/estimated-reward";
  final String EARNED_REWARD_URL = "/v1/earned-reward";
  final String ACCUMULATED_EARNED_REWARD_URL = "/v1/accumulated-earned-reward";
  final String REWARD_PERCENTAGE_URL = "/v1/reward-percentage";

  ApiAirdropClient(this._baseAddress);

  // AIRDROP

  // Health
  Future<bool> getEnvIsRunning() async {
    final response = await _get(HEALTH_URL, null);
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse['noSQL'] != null &&
        jsonResponse['noSQL'] == true &&
        jsonResponse['sql'] != null &&
        jsonResponse['sql'] == true;
  }

  // EnvSettings
  // NOTE: Currently not returning anything
  // Is used to get env settings such as chain id and min reward to be eligible
  Future<EnvResponseResponse> getEnvSettings() async {
    final response = await _get(ENV_SETTINGS_URL, null);
    final EnvResponseResponse envResponseResponse =
        EnvResponseResponse.fromJson(json.decode(response.body));
    return envResponseResponse;
  }

  // GetAllAirdrops
  Future<List<Airdrop>> getAllAirdrops() async {
    final response = await _get(AIRDROPS_URL, null);
    List<Airdrop> airdrops = (json.decode(response.body) as List)
        .map((item) => Airdrop.fromJson(item))
        .toList();
    return airdrops;
  }

  // GetActiveAirdrops
  //
  // Get all airdrops that are active at this moment
  Future<List<Airdrop>> getActiveAirdrops() async {
    final response = await _get(AIRDROPS_URL + AIRDROPS_ACTIVE_URL, null);
    List<Airdrop> activeAirdrops = (json.decode(response.body) as List)
        .map((item) => Airdrop.fromJson(item))
        .toList();
    return activeAirdrops;
  }

  // GetAirdrop
  //
  // airdrops/{id} is used to get info about the airdrop by ID
  Future<Airdrop> getAirdrop(int airdropID) async {
    final response = await _get(AIRDROPS_INFO_URL + airdropID.toString(), null);
    final Airdrop airdrop = Airdrop.fromJson(json.decode(response.body));
    return airdrop;
  }

  // GetAirdropRewards
  Future<List<Reward>> getAirdropRewards(int airdropID) async {
    final response = await _get(
        AIRDROPS_INFO_URL + airdropID.toString() + AIRDROPS_REWARDS_URL, null);
    final RewardsResponse rewardsResponse =
        RewardsResponse.fromJson(json.decode(response.body));
    return rewardsResponse.rewards;
  }

  // GetAirdropBlockRewards
  //
  // Returns the information of the computed rewards
  // for an specific airdrop and block
  Future<BlockRewardsResponse> getAirdropBlockRewards(
      int airdropID, int blockNumber) async {
    final response = await _get(
        AIRDROPS_INFO_URL +
            airdropID.toString() +
            AIRDROPS_BLOCKS_URL +
            blockNumber.toString() +
            AIRDROPS_REWARDS_URL,
        null);
    final BlockRewardsResponse blockRewardsResponse =
        BlockRewardsResponse.fromJson(json.decode(response.body));
    return blockRewardsResponse;
  }

  // EstimatedReward
  //
  // estimated-reward is used to get the estimated reward while an AirDrop
  // is happening (actual timestamp less than init_timestamp+duration)
  Future<EstimatedRewardResponse> getEstimatedReward(
      EarnedRewardRequest request) async {
    final response = await _get(ESTIMATED_REWARD_URL, request.toQueryParams());
    final EstimatedRewardResponse estimatedRewardResponse =
        EstimatedRewardResponse.fromJson(json.decode(response.body));
    return estimatedRewardResponse;
  }

  // EarnedReward
  //
  // Earned-reward is used to get final reward calculated after
  // the AirDrop has finished.
  Future<EarnedRewardResponse> getEarnedReward(
      EarnedRewardRequest request) async {
    final response = await _get(EARNED_REWARD_URL, request.toQueryParams());
    final EarnedRewardResponse earnedRewardResponse =
        EarnedRewardResponse.fromJson(json.decode(response.body));
    return earnedRewardResponse;
  }

  // AccumulatedEarnedReward
  //
  // accumulated-earned-reward is used to get final reward
  // calculated after the AirDrop has finished.
  Future<EarnedRewardResponse> getAccumulatedEarnedReward(
      AccumulatedEarnedRewardRequest request) async {
    final response =
        await _get(ACCUMULATED_EARNED_REWARD_URL, request.toQueryParams());
    final EarnedRewardResponse accumulatedEarnedRewardResponse =
        EarnedRewardResponse.fromJson(json.decode(response.body));
    return accumulatedEarnedRewardResponse;
  }

  // RewardPercentage
  // Is used to get percentage of the reward that will be distributed
  // today by the airdropID
  Future<double> getRewardPercentage(int airdropID) async {
    final response =
        await _get(REWARD_PERCENTAGE_URL, {"airdropID": airdropID.toString()});
    final RewardPercentageResponse rewardPercentageResponse =
        RewardPercentageResponse.fromJson(json.decode(response.body));
    return rewardPercentageResponse.percentage;
  }

  // CheckUserEligibility
  //
  // Is used to get info if user is eligible to get a reward
  // for the airdrop or not by the accountIndex and airdropID
  Future<bool> checkUserEligibility(int airdropID,
      {String ethereumAddress, int accountIndex = -1}) async {
    var params = {
      "airdropID": airdropID.toString(),
    };
    if (accountIndex != null && accountIndex != -1) {
      params.putIfAbsent('accountIndex', () => accountIndex.toString());
    }
    if (ethereumAddress != null && ethereumAddress.isNotEmpty) {
      params.putIfAbsent('ethAddr', () => ethereumAddress);
    }
    try {
      final response = await _get(CHECK_USER_ELIGIBILITY_URL, params);
      final UserEligibilityResponse userEligibilityResponse =
          UserEligibilityResponse.fromJson(json.decode(response.body));
      return userEligibilityResponse.isUserEligible;
    } catch (e) {
      return false;
    }
  }

  Future<http2.Response> _get(
      String endpoint, Map<String, String> queryParameters) async {
    try {
      Uri uri;
      if (queryParameters != null) {
        uri = Uri.https(_baseAddress, endpoint, queryParameters);
      } else {
        uri = Uri.https(_baseAddress, endpoint);
      }
      final response = await http2.get(
        uri,
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
        },
      );

      return returnResponseOrThrowException(response);
    } on IOException catch (e) {
      print(e.toString());
      throw NetworkException();
    }
  }

  Future<http2.Response> _post(
      String endpoint, Map<String, dynamic> body) async {
    try {
      var url = Uri.parse('$_baseAddress$endpoint');
      final response = await http2.post(
        url,
        body: json.encode(body),
        headers: {
          HttpHeaders.acceptHeader: '*/*',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );

      return returnResponseOrThrowException(response);
    } on IOException {
      throw NetworkException();
    }
  }

  Future<http2.Response> _put(dynamic task) async {
    try {
      var url = Uri.parse('$_baseAddress/todos/${task.id}');
      final response = await http2.put(
        url,
        body: json.encode(task.toJson()),
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );

      return returnResponseOrThrowException(response);
    } on IOException {
      throw NetworkException();
    }
  }

  Future<http2.Response> _delete(String id) async {
    try {
      var url = Uri.parse('$_baseAddress/todos/$id');
      final response = await http2.delete(
        url,
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
        },
      );

      return returnResponseOrThrowException(response);
    } on IOException {
      throw NetworkException();
    }
  }

  http2.Response returnResponseOrThrowException(http2.Response response) {
    if (response.statusCode == 301) {
      // airdrop with id 2 already ended, so estimated reward is zero
      throw AirdropAlreadyEndedException();
    } else if (response.statusCode == 401) {
      // Not found
      throw AirdropNotFoundException();
    } else if (response.statusCode == 402) {
      // Not found
      throw LatestEthBlockNotFoundException();
    } else if (response.statusCode == 403) {
      // Not found
      throw HezTokenNotFoundException();
    } else if (response.statusCode == 404) {
      // Not found
      throw AccountNotFoundByAccountIndexException();
    } else if (response.statusCode == 405) {
      // Not found
      throw AccountNotFoundByEthAddrOrBjjException();
    } else if (response.statusCode == 406) {
      // Not found
      throw AccountBalanceNotFoundException();
    } else if (response.statusCode == 407) {
      // Not found
      throw CurrentPriceNotFoundException();
    } else if (response.statusCode == 408) {
      // Not found
      throw WeightNotFoundException();
    } else if (response.statusCode == 409) {
      // Not found
      throw TokenNotFoundException();
    } else if (response.statusCode == 410) {
      // Not found
      throw AirdropStateNotFoundException();
    } else if (response.statusCode == 411) {
      // Not found
      throw TokenStateNotFoundException();
    } else if (response.statusCode == 510) {
      // Not found
      throw FailedToCreateDecimalFromStringException();
    } else if (response.statusCode == 500) {
      throw InternalServerErrorException();
    } else if (response.statusCode > 400) {
      throw UnknownApiException(response.statusCode);
    } else {
      return response;
    }
  }
}
