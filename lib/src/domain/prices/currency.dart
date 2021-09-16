class Currency {
  final String currency;
  final String baseCurrency;
  final num price;
  final String lastUpdate;

  Currency({this.currency, this.baseCurrency, this.price, this.lastUpdate});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
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
