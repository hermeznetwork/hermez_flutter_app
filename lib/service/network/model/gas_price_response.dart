class GasPriceResponse {
  final int
      fast; // Recommended fast(expected to be mined in < 2 minutes) gas price in x10 Gwei(divide by 10 to convert it to gwei)
  final int
      fastest; // Recommended fastest(expected to be mined in < 30 seconds) gas price in x10 Gwei(divite by 10 to convert it to gwei)
  final int
      safeLow; // Recommended safe(expected to be mined in < 30 minutes) gas price in x10 Gwei(divite by 10 to convert it to gwei)
  final int
      average; // Recommended average(expected to be mined in < 5 minutes) gas price in x10 Gwei(divite by 10 to convert it to gwei)
  final double block_time; // Average time(in seconds) to mine one single block
  final int blockNum; // Latest block number
  final double
      speed; // Smallest value of (gasUsed / gaslimit) from last 10 blocks
  final double safeLowWait; // Waiting time(in minutes) for safeLow gas price
  final double avgWait; // Waiting time(in minutes) for average gas price
  final double fastWait; // Waiting time(in minutes) for fast gas price
  final double fastestWait; // Waiting time(in minutes) for fastest gas price

  GasPriceResponse(
      {this.fast,
      this.fastest,
      this.safeLow,
      this.average,
      this.block_time,
      this.blockNum,
      this.speed,
      this.safeLowWait,
      this.avgWait,
      this.fastWait,
      this.fastestWait});

  factory GasPriceResponse.fromJson(Map<String, dynamic> json) {
    return GasPriceResponse(
      fast: json['fast'],
      fastest: json['fastest'],
      safeLow: json['safeLow'],
      average: json['average'],
      block_time: json['block_time'],
      blockNum: json['blockNum'],
      speed: json['speed'],
      safeLowWait: json['safeLowWait'],
      avgWait: json['avgWait'],
      fastWait: json['fastWait'],
      fastestWait: json['fastestWait'],
    );
  }

  Map<String, dynamic> toJson() => {
        'fast': fast,
        'fastest': fastest,
        'safeLow': safeLow,
        'average': average,
        'block_time': block_time,
        'blockNum': blockNum,
        'speed': speed,
        'safeLowWait': safeLowWait,
        'avgWait': avgWait,
        'fastWait': fastWait,
        'fastestWait': fastestWait,
      };
}
