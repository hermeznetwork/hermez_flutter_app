import 'package:hermez/service/network/model/airdrop.dart';

class AirdropResponse {
  final Airdrop airdrop;

  AirdropResponse({this.airdrop});

  factory AirdropResponse.fromJson(Map<String, dynamic> json) {
    return AirdropResponse(
      airdrop: json['airdrop'],
    );
  }

  Map<String, dynamic> toJson() => {
        'airdrop': airdrop,
      };
}
