class GasPriceResponse {
  final int fast;
  final int fastest;
  final int safeLow;
  final int average;
  //final BigInt block_time;
  final int blockNum;
  //final BigInt speed;
  //final BigInt safeLowWait;
  //final BigInt avgWait;
  //final BigInt fastWait;
  //final BigInt fastestWait;

  GasPriceResponse({
    this.fast,
    this.fastest,
    this.safeLow,
    this.average,
    //this.block_time,
    this.blockNum,
    //this.speed,
    //this.safeLowWait,
    //this.avgWait,
    //this.fastWait,
    /*this.fastestWait*/
  });

  factory GasPriceResponse.fromJson(Map<String, dynamic> json) {
    return GasPriceResponse(
      fast: json['fast'],
      fastest: json['fastest'],
      safeLow: json['safeLow'],
      average: json['average'],
      //block_time: json['block_time'],
      blockNum: json['blockNum'],
      //speed: json['speed'],
      //safeLowWait: json['safeLowWait'],
      //avgWait: json['avgWait'],
      //fastWait: json['fastWait'],
      //fastestWait: json['fastestWait'],
    );
  }

  Map<String, dynamic> toJson() => {
        'fast': fast,
        'fastest': fastest,
        'safeLow': safeLow,
        'average': average,
        //'block_time': block_time,
        'blockNum': blockNum,
        //'speed': speed,
        //'safeLowWait': safeLowWait,
        //'avgWait': avgWait,
        //'fastWait': fastWait,
        //'fastestWait': fastestWait,
      };
}
