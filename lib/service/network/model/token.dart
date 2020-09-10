class Token {
  final int id;
  final String ethereumAddress;
  final String name;
  final String symbol;
  final int decimals;
  final int ethereumBlockNum;
  final double USD;
  final int fiatUpdate;

  Token({this.id, this.ethereumAddress, this.name, this.symbol, this.decimals, this.ethereumBlockNum, this.USD, this.fiatUpdate});

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
        id: json['id'],
        ethereumAddress: json['ethereumAddress'],
        name: json['name'],
        symbol: json['symbol'],
        decimals: json['decimals'],
        ethereumBlockNum: json['ethereumBlockNum'],
        USD: json['USD'],
        fiatUpdate: json['fiatUpdate']
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ethereumAddress': ethereumAddress,
    'name': name,
    'symbol': symbol,
    'decimals': decimals,
    'ethereumBlockNum': ethereumBlockNum,
    'USD': USD,
    'fiatUpdate': fiatUpdate
  };

}
