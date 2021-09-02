class PayProduct {
  final int id;
  final String name;
  final int providerId;

  PayProduct({this.id, this.name, this.providerId});

  factory PayProduct.fromJson(Map<String, dynamic> json) {
    return PayProduct(
      id: json['id'],
      name: json['name'],
      providerId: json['providerId'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = Map<String, dynamic>();
    if (id != null) {
      json['id'] = id;
    }
    if (name != null) {
      json['name'] = name;
    }
    if (providerId != null) {
      json['providerId'] = providerId;
    }
    return json;
  }
}
