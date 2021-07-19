library api_testing_flutter_kata;

import 'dart:convert';
import 'dart:io';

import 'package:hermez/service/network/model/active_airdrops_response.dart';
import 'package:hermez/service/network/model/airdrop.dart';
import 'package:hermez/service/network/model/env_settings_response.dart';
import 'package:hermez/service/network/model/reward_percentage_response.dart';
import 'package:hermez/service/network/model/user_eligibility_response.dart';
import 'package:http/http.dart' as http2;

import 'api_airdrop_exceptions.dart';
import 'model/accumulated_earned_reward_request.dart';
import 'model/airdrop_response.dart';
import 'model/earned_reward_request.dart';
import 'model/earned_reward_response.dart';

class ApiAirdropClient {
  final String _baseAddress;

  final String ESTIMATED_REWARD_URL = "/airdrop/v1/estimated-reward";
  final String EARNED_REWARD_URL = "/airdrop/v1/earned-reward";
  final String ACCUMULATED_EARNED_REWARD_URL =
      "/airdrop/v1/accumulated-earned-reward";
  final String REWARD_PERCENTAGE_URL = "/airdrop/v1/reward-percentage";
  final String CHECK_USER_ELIGIBILITY_URL =
      "/airdrop/v1/check-user-eligibility";
  final String AIRDROPS_INFO_URL = "/airdrop/v1/airdrops/";
  final String AIRDROPS_ACTIVE_URL = "/airdrop/v1/airdrops/active";
  final String HEALTH_URL = "/airdrop/v1/health";
  final String ENV_SETTINGS_URL = "/airdrop/v1/env-settings";

  ApiAirdropClient(this._baseAddress);

  // AIRDROP

  // estimated-reward is used to get the estimated reward while an AirDrop
  // is happening (actual timestamp less than init_timestamp+duration)
  Future<EarnedRewardResponse> getEstimatedReward(
      EarnedRewardRequest request) async {
    final response = await _get(ESTIMATED_REWARD_URL, request.toQueryParams());
    final EarnedRewardResponse earnedRewardResponse =
        EarnedRewardResponse.fromJson(json.decode(response.body));
    return earnedRewardResponse;
  }

  // Earned-reward is used to get final reward calculated after
  // the AirDrop has finished.
  Future<EarnedRewardResponse> getEarnedReward(
      EarnedRewardRequest request) async {
    final response = await _get(EARNED_REWARD_URL, request.toQueryParams());
    final EarnedRewardResponse earnedRewardResponse =
        EarnedRewardResponse.fromJson(json.decode(response.body));
    return earnedRewardResponse;
  }

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

  // Is used to get percentage of the reward that will be distributed
  // today by the airdropID
  Future<String> getRewardPercentage(int airdropID) async {
    final response =
        await _get(REWARD_PERCENTAGE_URL, {"airdropID": airdropID.toString()});
    final RewardPercentageResponse rewardPercentageResponse =
        RewardPercentageResponse.fromJson(json.decode(response.body));
    return rewardPercentageResponse.percentage;
  }

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
    final response = await _get(CHECK_USER_ELIGIBILITY_URL, params);
    final UserEligibilityResponse userEligibilityResponse =
        UserEligibilityResponse.fromJson(json.decode(response.body));
    return userEligibilityResponse.isUserEligible;
  }

  // airdrops/{id} is used to get info about the airdrop by ID
  Future<Airdrop> getAirdropInfo(int airdropID) async {
    final response = await _get(AIRDROPS_INFO_URL + airdropID.toString(), null);
    final AirdropResponse airdropResponse =
        AirdropResponse.fromJson(json.decode(response.body));
    return airdropResponse.airdrop;
  }

  // Get all active airdrops, that are active at this moment
  Future<ActiveAirdropsResponse> getActiveAirdrops() async {
    final response = await _get(AIRDROPS_ACTIVE_URL, null);
    final ActiveAirdropsResponse activeAirdropsResponse =
        ActiveAirdropsResponse.fromJson(json.decode(response.body));
    return activeAirdropsResponse;
  }

  Future<bool> getEnvIsRunning() async {
    final response = await _get(HEALTH_URL, null);
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse['status'] == "UP";
  }

  // Is used to get env settings such as chain id and min reward to be eligible
  Future<EnvResponseResponse> getEnvSettings() async {
    final response = await _get(ENV_SETTINGS_URL, null);
    final EnvResponseResponse envResponseResponse =
        EnvResponseResponse.fromJson(json.decode(response.body));
    return envResponseResponse;
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
