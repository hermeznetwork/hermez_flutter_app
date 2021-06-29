class EarnedRewardRequest {
  // (mandatory) the ID of the AirDrop.
  final List<String> airdropID;
  // Equivalent value in USD to be hold using ether,
  // HEZ or other tokens within Hermez Network
  final String amountInUSD;
  // The Token ID of the ERC-20 Ethereum token accepted
  // within Hermez Network. To use ether the token ID is 0
  final String tokenID;
  // Ethereum account address of a valid
  // L2 account of Hermez Network
  final String ethAddr;
  // Account index of a valid L2 account of Hermez Network
  final String accountIndex;

  EarnedRewardRequest(
      {this.airdropID,
      this.amountInUSD,
      this.tokenID,
      this.ethAddr,
      this.accountIndex});

  factory EarnedRewardRequest.fromJson(Map<String, dynamic> json) {
    return EarnedRewardRequest(
      airdropID: json['airdropID'],
      amountInUSD: json['amountInUSD'],
      tokenID: json['tokenID'],
      ethAddr: json['ethAddr'],
      accountIndex: json['accountIndex'],
    );
  }

  Map<String, String> toQueryParams() => {
        //'airdropID': airdropID.forEach((airdropID) { }),
        'amountInUSD': amountInUSD,
        'tokenID': tokenID,
        'ethAddr': ethAddr,
        'accountIndex': accountIndex,
      };
}
