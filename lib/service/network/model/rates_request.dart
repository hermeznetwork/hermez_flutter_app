class RatesRequest {
  final String base;
  final List<String> symbols;
  final String accessKey;

  RatesRequest({this.base, this.symbols, this.accessKey});

  factory RatesRequest.fromJson(Map<String, dynamic> json) {
    return RatesRequest(
      base: json['base'],
      symbols: json['symbols'],
      accessKey: json['access_key'],
    );
  }

  Map<String, String> toQueryParams() => {
        'base': base,
        'symbols': symbols.join(','),
        'access_key': accessKey,
      };
}
