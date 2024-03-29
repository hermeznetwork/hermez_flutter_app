import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/context/setup/wallet_setup_handler.dart';
import 'package:hermez/context/setup/wallet_setup_state.dart';
import 'package:hermez/model/wallet_setup.dart';
import 'package:hermez/service/address_service.dart';
import 'package:provider/provider.dart';

import '../hook_provider.dart';

class WalletSetupProvider extends ContextProviderWidget<WalletSetupHandler> {
  WalletSetupProvider(
      {Widget child, HookWidgetBuilder<WalletSetupHandler> builder})
      : super(child: child, builder: builder);

  @override
  Widget build(BuildContext context) {
    final store = useReducer<WalletSetup, WalletSetupAction>(reducer,
        initialState: WalletSetup(), initialAction: null);

    final addressService = Provider.of<AddressService>(context);
    final handler = useMemoized(
      () => WalletSetupHandler(store, addressService),
      [addressService, store],
    );

    return provide(context, handler);
  }
}

WalletSetupHandler useWalletSetup(BuildContext context) {
  var handler = Provider.of<WalletSetupHandler>(context);

  return handler;
}
