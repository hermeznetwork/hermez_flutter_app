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
  final String recipient;
  final String currency;
  final String account;
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
      this.recipient,
      this.currency,
      this.account,
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
        recipient: json['recipient'],
        currency: json['currency'],
        account: json['account'],
        confirmed: json['confirmed'],
        lastUpdate: json['lastUpdate']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = Map<String, dynamic>();
    if (itemId != null) {
      json['itemId'] = itemId;
    }
    if (provider != null) {
      json['provider'] = provider;
    }
    if (product != null) {
      json['product'] = product;
    }
    if (amount != null) {
      json['amount'] = amount;
    }
    if (price != null) {
      json['price'] = price;
    }
    if (completed != null) {
      json['completed'] = completed;
    }
    if (operationId != null) {
      json['operationId'] = operationId;
    }
    if (l2TxId != null) {
      json['l2TxId'] = l2TxId;
    }
    if (l1TxHash != null) {
      json['l1TxHash'] = l1TxHash;
    }
    if (instant != null) {
      json['instant'] = instant;
    }
    if (recipient != null) {
      json['recipient'] = recipient;
    }
    if (currency != null) {
      json['currency'] = currency;
    }
    if (account != null) {
      json['account'] = account;
    }
    if (confirmed != null) {
      json['confirmed'] = confirmed;
    }
    if (lastUpdate != null) {
      json['lastUpdate'] = lastUpdate;
    }
    return json;
  }
}
