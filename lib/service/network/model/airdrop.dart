class Airdrop {
  final int airdropId;
  final int initTimestamp;
  final int duration;
  final String reward;
  final int minTx;
  final String name;
  final bool isClosed;

  Airdrop({
    this.airdropId,
    this.initTimestamp,
    this.duration,
    this.reward,
    this.minTx,
    this.name,
    this.isClosed,
  });

  factory Airdrop.fromJson(Map<String, dynamic> json) {
    return Airdrop(
      airdropId: json['airdropId'],
      initTimestamp: json['initTimestamp'],
      duration: json['duration'],
      reward: json['reward'],
      minTx: json['minTx'],
      name: json['name'],
      isClosed: json['isClosed'],
    );
  }

  Map<String, dynamic> toJson() => {
        'airdropId': airdropId,
        'initTimestamp': initTimestamp,
        'duration': duration,
        'reward': reward,
        'minTx': minTx,
        'name': name,
        'isClosed': isClosed,
      };
}
