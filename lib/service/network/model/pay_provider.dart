class PayProvider {
  final int id;
  final String name;
  final String ethAddress;

  PayProvider({this.id, this.name, this.ethAddress});

  factory PayProvider.fromJson(Map<String, dynamic> json) {
    return PayProvider(
      id: json['id'],
      name: json['name'],
      ethAddress: json['ethAddress'],
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
    if (ethAddress != null) {
      json['ethAddress'] = ethAddress;
    }
    return json;
  }
}
