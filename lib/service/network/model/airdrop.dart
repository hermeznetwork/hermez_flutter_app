enum AirdropStatus { IN_PROGRESS, CLOSED, PAID }

class Airdrop {
  final int id;
  final String budget;
  final int initialEthereumBlock;
  final int finalEthereumBlock;
  final String status;

  Airdrop({
    this.id,
    this.budget,
    this.initialEthereumBlock,
    this.finalEthereumBlock,
    this.status,
  });

  factory Airdrop.fromJson(Map<String, dynamic> json) {
    return Airdrop(
      id: json['id'],
      budget: json['budget'],
      initialEthereumBlock: json['initialEthereumBlock'],
      finalEthereumBlock: json['finalEthereumBlock'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'budget': budget,
        'initialEthereumBlock': initialEthereumBlock,
        'finalEthereumBlock': finalEthereumBlock,
        'status': status,
      };
}
