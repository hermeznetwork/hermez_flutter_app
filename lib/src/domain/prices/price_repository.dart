import 'package:hermez/src/domain/prices/currency.dart';
import 'package:hermez/src/domain/prices/price_token.dart';

abstract class PriceRepository {
  Future<List<PriceToken>> getTokensPrices([List<int> tokenIds]);

  Future<PriceToken> getTokenPrice(int tokenId);

  Future<List<Currency>> getCurrenciesPrices();

  Future<Currency> getCurrencyPrice(String currency);
}
