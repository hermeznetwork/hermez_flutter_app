import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hermez/constants.dart';
import 'package:hermez/environment.dart';
import 'package:hermez/secrets/keys.dart';
import 'package:hermez/service/address_service.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/service/contract_service.dart';
import 'package:hermez/service/explorer_service.dart';
import 'package:hermez/service/hermez_service.dart';
import 'package:hermez/service/price_updater_service.dart';
import 'package:hermez/service/storage_service.dart';
import 'package:hermez_sdk/hermez_sdk.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<SingleChildWidget>> createProviders(EnvParams walletParams) async {
  final localStorage = await SharedPreferences.getInstance();
  final secureStorage = new FlutterSecureStorage();
  final storageService = StorageService(localStorage, secureStorage);
  final configurationService =
      ConfigurationService(localStorage, secureStorage, storageService);
  final addressService = AddressService(configurationService);
  final hermezService = HermezService(configurationService);
  final priceUpdaterService = PriceUpdaterService(
      walletParams.priceUpdaterApiUrl, walletParams.priceUpdaterApiKey);
  final client = HermezSDK.currentWeb3Client;
  final contractService = ContractService(
      client, configurationService, ETH_GAS_PRICE_URL, ETH_GAS_STATION_API_KEY);
  final explorerService =
      ExplorerService(walletParams.etherscanApiUrl, ETHERSCAN_API_KEY);

  return [
    Provider.value(value: addressService),
    Provider.value(value: contractService),
    Provider.value(value: explorerService),
    Provider.value(value: storageService),
    Provider.value(value: configurationService),
    Provider.value(value: hermezService),
    Provider.value(value: priceUpdaterService),
  ];
}
