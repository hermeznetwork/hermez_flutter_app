class AccumulatedEarnedRewardRequest {
  // (mandatory) the ID of the AirDrop.
  final String airdropID;
  // Ethereum account address of a valid
  // L2 account of Hermez Network
  final String ethAddr;
  // Account index of a valid L2 account of Hermez Network
  final String accountIndex;
  // address of a valid L2 account of Hermez Network
  final String bjj;

  AccumulatedEarnedRewardRequest(
      {this.airdropID, this.ethAddr, this.accountIndex, this.bjj});

  factory AccumulatedEarnedRewardRequest.fromJson(Map<String, dynamic> json) {
    return AccumulatedEarnedRewardRequest(
      airdropID: json['airdropID'],
      ethAddr: json['ethAddr'],
      accountIndex: json['accountIndex'],
      bjj: json['bjj'],
    );
  }

  Map<String, String> toQueryParams() => {
        'airdropID': airdropID,
        'ethAddr': ethAddr,
        'accountIndex': accountIndex,
        'bjj': bjj,
      };
}
