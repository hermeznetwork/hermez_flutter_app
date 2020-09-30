import 'dart:collection';

class RatesRequest {
  final String base;
  final LinkedHashSet<String> symbols;

  RatesRequest({this.base, this.symbols});

  factory RatesRequest.fromJson(Map<String, dynamic> json) {
    return RatesRequest(
      base: json['base'],
      symbols: json['symbols'],
    );
  }

  Map<String, String> toQueryParams() => {
        'base': base.toString(),
        'symbols': symbols.first,
      };
}
