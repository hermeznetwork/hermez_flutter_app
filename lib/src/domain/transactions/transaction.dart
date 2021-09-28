enum TransactionLevel { LEVEL1, LEVEL2 }

enum TransactionType { DEPOSIT, SEND, RECEIVE, WITHDRAW, EXIT, FORCEEXIT }

enum TransactionStatus { DRAFT, PENDING, CONFIRMED, INVALID }

class Transaction {
  final String currency;
  final String baseCurrency;
  final num price;
  final String lastUpdate;

  final TransactionLevel level;
  final TransactionStatus status;
  final TransactionType type;

  Transaction(
      {this.currency,
      this.baseCurrency,
      this.price,
      this.lastUpdate,
      this.level,
      this.status,
      this.type});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      currency: json['currency'],
      baseCurrency: json['baseCurrency'],
      price: json['price'],
      lastUpdate: json['lastUpdate'],
    );
  }

  Map<String, dynamic> toJson() => {
        'currency': currency,
        'baseCurrency': baseCurrency,
        'price': price,
        'lastUpdate': lastUpdate,
      };
}
