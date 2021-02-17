import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hermez/app_config.dart';
import 'package:hermez/service/address_service.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/service/contract_service.dart';
import 'package:hermez/service/explorer_service.dart';
import 'package:hermez/service/hermez_service.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

Future<List<SingleChildCloneableWidget>> createProviders(
    AppConfigParams params) async {
  final client = Web3Client(params.web3HttpUrl, Client(),
      enableBackgroundIsolate: true, socketConnector: () {
    return IOWebSocketChannel.connect(params.web3RdpUrl).cast<String>();
  });

  final sharedPrefs = await SharedPreferences.getInstance();
  final secureStorage = new FlutterSecureStorage();
  final configurationService = ConfigurationService(sharedPrefs, secureStorage);
  final addressService = AddressService(configurationService);
  final hermezService = HermezService(params.hermezHttpUrl, client,
      params.exchangeHttpUrl, configurationService);
  final contractService =
      ContractService(client, configurationService, params.ethGasPriceHttpUrl);
  final explorerService =
      ExplorerService(params.etherscanHttpUrl, params.etherscanApiKey);
  //final tokens = await hermezService.getTokens();

  /*List<ContractService> contractServices = [];
  for (Token tokenContractAddress in tokens) {
    final contract = await ContractParser.fromAssets(
        'partialERC20ABI.json', tokenContractAddress);
    final contractService = ContractService(client, contract);
    contractServices.add(contractService);
  }*/

  return [
    Provider.value(value: addressService),
    Provider.value(value: contractService),
    Provider.value(value: explorerService),
    Provider.value(value: configurationService),
    Provider.value(value: hermezService)
  ];
}
