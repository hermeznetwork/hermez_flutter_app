class PurchaseItem {
  final String name;
  final int amount;
  final String price;

  PurchaseItem({this.name, this.amount, this.price});

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      name: json['name'],
      amount: json['amount'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = Map<String, dynamic>();
    if (name != null) {
      json['name'] = name;
    }
    if (amount != null) {
      json['amount'] = amount;
    }
    if (price != null) {
      json['price'] = price;
    }
    return json;
  }
}
