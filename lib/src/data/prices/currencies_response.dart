import 'package:hermez/src/domain/prices/currency.dart';

class CurrenciesResponse {
  final List<Currency> currencies;

  CurrenciesResponse({this.currencies});

  factory CurrenciesResponse.fromJson(Map<String, dynamic> json) {
    List<Currency> currencies = (json['currencies'] as List)
        .map((item) => Currency.fromJson(item))
        .toList();
    return CurrenciesResponse(
      currencies: currencies,
    );
  }

  Map<String, dynamic> toJson() => {
        'currencies': currencies,
      };
}
