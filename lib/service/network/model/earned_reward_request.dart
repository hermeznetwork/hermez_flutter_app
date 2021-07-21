class EarnedRewardRequest {
  // (mandatory) the ID of the AirDrop.
  final String airdropID;
  // Account index of a valid L2 account of Hermez Network
  final String accountIndex;
  // Ethereum account address of a valid
  // L2 account of Hermez Network
  final String ethAddr;
  // bjj address of a valid L2 account of Hermez Network
  final String bjj;

  EarnedRewardRequest({
    this.airdropID,
    this.accountIndex,
    this.ethAddr,
    this.bjj,
  });

  factory EarnedRewardRequest.fromJson(Map<String, dynamic> json) {
    return EarnedRewardRequest(
      airdropID: json['airdropID'],
      accountIndex: json['accountIndex'],
      ethAddr: json['ethAddr'],
      bjj: json['bjj'],
    );
  }

  Map<String, String> toQueryParams() => {
        'airdropID': airdropID,
        'accountIndex': accountIndex,
        'ethAddr': ethAddr,
        'bjj': bjj,
      };
}
