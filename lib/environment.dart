import 'package:hermez/secrets/keys.dart';
import 'package:hermez_sdk/hermez_sdk.dart';

EnvParams params = Env().params['local'];

class Env {
  Env() {
    params['mainnet'] = EnvParams(
      "https://etherscan.io",
      "http://api.etherscan.io/api",
      ETHERSCAN_API_KEY,
      "priceupdater.hermez.io",
      PRICE_UPDATER_API_KEY_MAINNET,
    );

    params['rinkeby'] = EnvParams(
      "https://rinkeby.etherscan.io",
      "http://api-rinkeby.etherscan.io/api",
      ETHERSCAN_API_KEY,
      "priceupdater.testnet.hermez.io",
      PRICE_UPDATER_API_KEY_RINKEBY,
    );

    params['goerli'] = EnvParams(
      "https://goerli.etherscan.io",
      "http://api-goerli.etherscan.io/api",
      ETHERSCAN_API_KEY,
      "priceupdater.internaltestnet.hermez.io",
      PRICE_UPDATER_API_KEY_GOERLI,
    );

    params['local'] = EnvParams(
      "https://etherscan.io",
      "http://api-goerli.etherscan.io/api",
      ETHERSCAN_API_KEY,
      "priceupdater.internaltestnet.hermez.io",
      PRICE_UPDATER_API_KEY_GOERLI,
    );
  }

  Map<String, EnvParams> params = Map<String, EnvParams>();

  static final Set<String> supportedEnvironments = {
    "mainnet",
    "rinkeby",
    "goerli",
    "local",
    "custom"
  };
}

class EnvParams {
  EnvParams(this.etherscanUrl, this.etherscanApiUrl, this.etherscanApiKey,
      this.priceUpdaterApiUrl, this.priceUpdaterApiKey);
  final String etherscanUrl;
  final String etherscanApiUrl;
  final String etherscanApiKey;
  final String priceUpdaterApiUrl;
  final String priceUpdaterApiKey;
}

/// Gets the current supported environments
/// @returns {Object[]} Supported environments
Set<String> getSupportedEnvironments() {
  return Env.supportedEnvironments;
}

/// Sets an environment from a chain id or from a custom environment object
/// @param {Object|Number} env - Chain id or a custom environment object
void setEnvironment(String env) {
  if (env == null) {
    throw new ArgumentError('A environment is required');
  }

  if (!getSupportedEnvironments().contains(env)) {
    throw new ArgumentError('Environment not supported');
  }

  params = Env().params[env];

  HermezSDK.init(env, web3ApiKey: INFURA_API_KEY);
}

/// Returns the current environment
/// @returns {Object} Contains contract addresses, Hermez API and Batch Explorer urls
/// and the Etherscan URL por the provider
EnvParams getCurrentEnvironment() {
  return params;
}
