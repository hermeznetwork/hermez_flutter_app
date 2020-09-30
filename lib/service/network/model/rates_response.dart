import 'dart:collection';

class RatesResponse {
  final LinkedHashMap<String, dynamic> rates;
  final String base;
  final String date;

  RatesResponse({this.rates, this.base, this.date});

  factory RatesResponse.fromJson(Map<String, dynamic> json) {
    return RatesResponse(
      rates: json['rates'],
      base: json['base'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() => {
        'rates': rates,
        'base': base,
        'date': date,
      };
}
