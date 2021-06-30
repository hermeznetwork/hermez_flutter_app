class UnknownApiException implements Exception {
  int httpCode;

  UnknownApiException(this.httpCode);
}

class AirdropNotFoundException implements Exception {}

class LatestEthBlockNotFoundException implements Exception {}

class HezTokenNotFoundException implements Exception {}

class AccountNotFoundByAccountIndexException implements Exception {}

class AccountNotFoundByEthAddrOrBjjException implements Exception {}

class AccountBalanceNotFoundException implements Exception {}

class CurrentPriceNotFoundException implements Exception {}

class WeightNotFoundException implements Exception {}

class TokenNotFoundException implements Exception {}

class AirdropStateNotFoundException implements Exception {}

class TokenStateNotFoundException implements Exception {}

class FailedToCreateDecimalFromStringException implements Exception {}

class AirdropAlreadyEndedException implements Exception {}

class InternalServerErrorException implements Exception {}

class NetworkException implements Exception {}
