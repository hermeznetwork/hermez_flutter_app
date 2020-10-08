class AppConfig {
  AppConfig() {
    params['dev'] = AppConfigParams(
        "http://192.168.182.2:7546",
        "ws://192.168.182.2:7546",
        "167.71.59.190:4010",
        "api.exchangeratesapi.io",
        "http://api-ropsten.etherscan.io/api",
        "B697CBT5AUE1PUSUGFXZUIFVBFG8G7889D", {
      "0x6b175474e89094c44da98b954eedeac495271d0f", // DAI
      "0x5060b60cb8Bd1C94B7ADEF4134555CDa7B45c461" // TargaryenCoin
    });

    params['ropsten'] = AppConfigParams(
        "https://ropsten.infura.io/v3/e2d8687b60b944d58adc96485cbab18c",
        "wss://ropsten.infura.io/ws/v3/e2d8687b60b944d58adc96485cbab18c",
        "167.71.59.190:4010",
        "api.exchangeratesapi.io",
        "http://api-ropsten.etherscan.io/api",
        "B697CBT5AUE1PUSUGFXZUIFVBFG8G7889D", {
      "0x6b175474e89094c44da98b954eedeac495271d0f", // DAI
      "0x5060b60cb8Bd1C94B7ADEF4134555CDa7B45c461" // TargaryenCoin
    });

    params['main'] = AppConfigParams(
        "https://mainnet.infura.io/v3/e2d8687b60b944d58adc96485cbab18c",
        "wss://mainnet.infura.io/ws/v3/e2d8687b60b944d58adc96485cbab18c",
        "167.71.59.190:4010",
        "api.exchangeratesapi.io",
        "https://api.etherscan.io/api",
        "B697CBT5AUE1PUSUGFXZUIFVBFG8G7889D", {
      "0x6b175474e89094c44da98b954eedeac495271d0f", // DAI
      "0x5060b60cb8Bd1C94B7ADEF4134555CDa7B45c461" // TargaryenCoin
    });
  }

  Map<String, AppConfigParams> params = Map<String, AppConfigParams>();
}

class AppConfigParams {
  AppConfigParams(
      this.web3HttpUrl,
      this.web3RdpUrl,
      this.hermezHttpUrl,
      this.exchangeHttpUrl,
      this.etherscanHttpUrl,
      this.etherscanApiKey,
      this.tokenContractAddresses);
  final String web3HttpUrl;
  final String web3RdpUrl;
  final String hermezHttpUrl;
  final String exchangeHttpUrl;
  final String etherscanHttpUrl;
  final String etherscanApiKey;
  final Set<String> tokenContractAddresses;
}
