import 'dart:async';

import 'package:hermez/service/network/api_airdrop_client.dart';
import 'package:hermez/service/network/model/active_airdrops_response.dart';

import 'network/model/airdrop.dart';

abstract class IAirdropService {
  Future<List<Airdrop>> getActiveAirdrops();
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
}
