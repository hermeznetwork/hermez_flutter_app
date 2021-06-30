import 'package:hermez/service/network/model/airdrop.dart';

class ActiveAirdropsResponse {
  final List<Airdrop> airdrops;

  ActiveAirdropsResponse({this.airdrops});

  factory ActiveAirdropsResponse.fromJson(Map<String, dynamic> json) {
    List<Airdrop> airdrops = (json['airdrops'] as List)
        .map((item) => Airdrop.fromJson(item))
        .toList();
    return ActiveAirdropsResponse(
      airdrops: airdrops,
    );
  }

  Map<String, dynamic> toJson() => {
        'airdrops': airdrops,
      };
}
