import 'package:hermez/src/domain/prices/price_repository.dart';
import 'package:hermez/src/domain/prices/price_token.dart';

class GetPricesUseCase {
  final PriceRepository _priceRepository;

  GetPricesUseCase(this._priceRepository);

  Future<List<PriceToken>> execute() {
    return _priceRepository.getTokensPrices();
  }
}
