import 'package:hermez/service/network/model/airdrop.dart';

class ActiveAirdropsResponse {
  final List<Airdrop> airdrops;

  ActiveAirdropsResponse({this.airdrops});

  factory ActiveAirdropsResponse.fromJson(Map<String, dynamic> json) {
    return ActiveAirdropsResponse(
      airdrops: json['airdrops'],
    );
  }

  Map<String, dynamic> toJson() => {
        'airdrops': airdrops,
      };
}
