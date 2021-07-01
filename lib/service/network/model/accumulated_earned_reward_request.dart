class AccumulatedEarnedRewardRequest {
  // (mandatory) the ID of the AirDrop.
  final List<int> airdropIDs;
  // Ethereum account address of a valid
  // L2 account of Hermez Network
  final String ethAddr;
  // Account index of a valid L2 account of Hermez Network
  final String accountIndex;
  // address of a valid L2 account of Hermez Network
  final String bjj;

  AccumulatedEarnedRewardRequest(
      {this.airdropIDs, this.ethAddr, this.accountIndex, this.bjj});

  factory AccumulatedEarnedRewardRequest.fromJson(Map<String, dynamic> json) {
    return AccumulatedEarnedRewardRequest(
      airdropIDs: json['airdropIDs'],
      ethAddr: json['ethAddr'],
      accountIndex: json['accountIndex'],
      bjj: json['bjj'],
    );
  }

  Map<String, String> toQueryParams() {
    var params = Map<String, String>();
    if (airdropIDs != null && airdropIDs.length > 0) {
      airdropIDs.forEach((airdropID) {
        params.addAll({'airdropID': airdropID.toString()});
      });
    }
    if (accountIndex != null && double.parse(accountIndex) > 0) {
      params.putIfAbsent('accountIndex', () => accountIndex);
    }
    if (ethAddr != null && ethAddr.isNotEmpty) {
      params.putIfAbsent('ethAddr', () => ethAddr);
    }
    if (bjj != null && bjj.isNotEmpty) {
      params.putIfAbsent('bjj', () => bjj);
    }
    return params;
  }
}
