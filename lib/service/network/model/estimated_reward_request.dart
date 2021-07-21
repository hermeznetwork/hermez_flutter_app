class EstimatedRewardRequest {
  // (mandatory) the ID of the AirDrop.
  final String airdropID;
  // Account index of a valid L2 account of Hermez Network
  final String accountIndex;
  // Ethereum account address of a valid
  // L2 account of Hermez Network
  final String ethAddr;
  // bjj address of a valid L2 account of Hermez Network
  final String bjj;
  // Equivalent value in USD to be hold using ether,
  // HEZ or other tokens within Hermez Network
  final String amountInUSD;
  // The Token ID of the ERC-20 Ethereum token accepted
  // within Hermez Network. To use ether the token ID is 0
  final String tokenID;
  // Time in seconds the token is going to be hold within Hermez Network
  final String timeToHold;

  EstimatedRewardRequest({
    this.airdropID,
    this.accountIndex,
    this.ethAddr,
    this.bjj,
    this.amountInUSD,
    this.tokenID,
    this.timeToHold,
  });

  factory EstimatedRewardRequest.fromJson(Map<String, dynamic> json) {
    return EstimatedRewardRequest(
      airdropID: json['airdropID'],
      accountIndex: json['accountIndex'],
      ethAddr: json['ethAddr'],
      bjj: json['bjj'],
      amountInUSD: json['amountInUSD'],
      tokenID: json['tokenID'],
      timeToHold: json['timeToHold'],
    );
  }

  Map<String, String> toQueryParams() => {
        'airdropID': airdropID,
        'accountIndex': accountIndex,
        'ethAddr': ethAddr,
        'bjj': bjj,
        'amountInUSD': amountInUSD,
        'tokenID': tokenID,
        'timeToHold': timeToHold,
      };
}
