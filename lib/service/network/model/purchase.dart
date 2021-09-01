class Purchase {
  final int itemId;
  final String provider;
  final String product;
  final int amount;
  final String price;
  final bool completed;
  final int operationId;
  final String l2TxId;
  final String l1TxHash;
  final bool instant;
  final bool confirmed;
  final String lastUpdate;

  Purchase(
      {this.itemId,
      this.provider,
      this.product,
      this.amount,
      this.price,
      this.completed,
      this.operationId,
      this.l2TxId,
      this.l1TxHash,
      this.instant,
      this.confirmed,
      this.lastUpdate});

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
        itemId: json['itemId'],
        provider: json['provider'],
        product: json['product'],
        amount: json['amount'],
        price: json['price'],
        completed: json['completed'],
        operationId: json['operationId'],
        l2TxId: json['l2TxId'],
        l1TxHash: json['l1TxHash'],
        instant: json['instant'],
        confirmed: json['confirmed'],
        lastUpdate: json['lastUpdate']);
  }

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'provider': provider,
        'product': product,
        'amount': amount,
        'price': price,
        'completed': completed,
        'operationId': operationId,
        'l2TxId': l2TxId,
        'l1TxHash': l1TxHash,
        'instant': instant,
        'confirmed': confirmed,
        'lastUpdate': lastUpdate,
      };
}
