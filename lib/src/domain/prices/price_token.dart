class PriceToken {
  /*final int itemId;*/
  final int id;
  /*final int ethereumBlockNum;
  final String ethereumAddress;
  final String name;
  final String symbol;
  final int decimals;*/
  final num USD;
  final String usdUpdate;

  PriceToken(
      {/*this.itemId,*/
      this.id,
      /*this.ethereumBlockNum,
      this.ethereumAddress,
      this.name,
      this.symbol,
      this.decimals,*/
      this.USD,
      this.usdUpdate});

  factory PriceToken.fromJson(Map<String, dynamic> json) {
    return PriceToken(
      /*itemId: json['itemId'],*/
      id: json['id'],
      /*ethereumBlockNum: json['ethereumBlockNum'],
      ethereumAddress: json['ethereumAddress'],
      name: json['name'],
      symbol: json['symbol'],
      decimals: json['decimals'],*/
      USD: json['USD'],
      usdUpdate: json['usdUpdate'],
    );
  }

  Map<String, dynamic> toJson() => {
        /*'itemId': itemId,*/
        'id': id,
        /*'ethereumBlockNum': ethereumBlockNum,
        'ethereumAddress': ethereumAddress,
        'name': name,
        'symbol': symbol,
        'decimals': decimals,*/
        'USD': USD,
        'usdUpdate': usdUpdate
      };
}
