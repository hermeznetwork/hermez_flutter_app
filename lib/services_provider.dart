import 'package:hermez/app_config.dart';
import 'package:hermez/service/address_service.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/service/contract_service.dart';
import 'package:hermez/service/rollup_service.dart';
import 'package:hermez/utils/contract_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

Future<List<SingleChildCloneableWidget>> createProviders(
    AppConfigParams params) async {
  final client = Web3Client(params.web3HttpUrl, Client(), socketConnector: () {
    return IOWebSocketChannel.connect(params.web3RdpUrl).cast<String>();
  });

  final sharedPrefs = await SharedPreferences.getInstance();
  final secureStorage = new FlutterSecureStorage();
  final configurationService = ConfigurationService(sharedPrefs, secureStorage);
  final addressService = AddressService(configurationService);
  final rollupService = RollupService(configurationService);
  final contract = await ContractParser.fromAssets(
      'TargaryenCoin.json', params.contractAddress);

  final contractService = ContractService(client, contract);

  return [
    Provider.value(value: addressService),
    Provider.value(value: contractService),
    Provider.value(value: configurationService),
    Provider.value(value: rollupService)
  ];
}
