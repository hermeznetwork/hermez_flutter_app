class UnknownApiException implements Exception {
  int httpCode;

  UnknownApiException(this.httpCode);
}

class AirdropNotFoundException implements Exception {}

class LatestEthBlockNotFoundException implements Exception {}

class NetworkException implements Exception {}
