import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/model/wallet.dart';
import 'package:hermez/service/address_service.dart';
import 'package:hermez/service/airdrop_service.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/service/contract_service.dart';
import 'package:hermez/service/exchange_service.dart';
import 'package:hermez/service/explorer_service.dart';
import 'package:hermez/service/hermez_service.dart';
import 'package:hermez/service/storage_service.dart';
import 'package:provider/provider.dart';

import '../hook_provider.dart';
import 'wallet_handler.dart';
import 'wallet_state.dart';

class WalletProvider extends ContextProviderWidget<WalletHandler> {
  WalletProvider({Widget child, HookWidgetBuilder<WalletHandler> builder})
      : super(child: child, builder: builder);

  @override
  Widget build(BuildContext context) {
    final store =
        useReducer<Wallet, WalletAction>(reducer, initialState: Wallet());

    final addressService = Provider.of<AddressService>(context);
    final contractService = Provider.of<ContractService>(context);
    final explorerService = Provider.of<ExplorerService>(context);
    final configurationService = Provider.of<ConfigurationService>(context);
    final storageService = Provider.of<StorageService>(context);
    final hermezService = Provider.of<HermezService>(context);
    final exchangeService = Provider.of<ExchangeService>(context);
    final airdropService = Provider.of<AirdropService>(context);
    final handler = useMemoized(
      () => WalletHandler(
          store,
          addressService,
          contractService,
          explorerService,
          configurationService,
          storageService,
          hermezService,
          exchangeService,
          airdropService),
      [addressService, store],
    );

    return provide(context, handler);
  }
}

WalletHandler useWallet(BuildContext context) {
  var handler = Provider.of<WalletHandler>(context);

  return handler;
}
