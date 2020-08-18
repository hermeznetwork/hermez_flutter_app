class AppConfig {
  AppConfig() {
    params['dev'] = AppConfigParams(
        "http://192.168.182.2:7546",
        "ws://192.168.182.2:7546",
        "0x59FFB6Ea7bb59DAa2aC480D862d375F49F73915d");

    params['ropsten'] = AppConfigParams(
        "https://ropsten.infura.io/v3/e2d8687b60b944d58adc96485cbab18c",
        "wss://ropsten.infura.io/ws/v3/e2d8687b60b944d58adc96485cbab18c",
        "0x5060b60cb8Bd1C94B7ADEF4134555CDa7B45c461");

    params['main'] = AppConfigParams(
        "https://mainnet.infura.io/v3/e2d8687b60b944d58adc96485cbab18c",
        "wss://mainnet.infura.io/ws/v3/e2d8687b60b944d58adc96485cbab18c",
        "0x5060b60cb8Bd1C94B7ADEF4134555CDa7B45c461");
  }

  Map<String, AppConfigParams> params = Map<String, AppConfigParams>();
}

class AppConfigParams {
  AppConfigParams(this.web3HttpUrl, this.web3RdpUrl, this.contractAddress);
  final String web3RdpUrl;
  final String web3HttpUrl;
  final String contractAddress;
}
