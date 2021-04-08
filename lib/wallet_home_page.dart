import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/components/wallet/home_balance.dart';
import 'package:hermez/screens/account_settings.dart';
import 'package:hermez/screens/scanner.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';
import 'package:provider/provider.dart';

import 'context/wallet/wallet_handler.dart';
import 'context/wallet/wallet_provider.dart';

class WalletHomePage extends HookWidget {
  WalletHomePage(this.title);

  final String title;

  WalletHandler store;

  ValueNotifier _currentIndex;

  PageController controller = PageController(initialPage: 1);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    store = useWallet(context);
    _currentIndex = useState(0);

    useEffect(() {
      store.initialise();
      if (store.state.txLevel == TransactionLevel.LEVEL1) {
        store.fetchOwnL1Balance();
      } else {
        store.fetchOwnL2Balance();
      }
      return null;
    }, [store]);

    final _children = <Widget>[
      settingsPage(context),
      HomeBalance(
        arguments: HomeBalanceArguments(
          controller,
          store,
          null,
          _scaffoldKey,
        ),
      ),
      QRCodeScannerPage(
        title: "Scan QRCode",
        onScanned: ModalRoute.of(context).settings.arguments,
      ),
      /*Activity(
        address: store.state.address,
        defaultCurrency: store.state.defaultCurrency,
        cryptoList: store.state.cryptoList,
      ),*/
    ];

    return Scaffold(
      key: _scaffoldKey,
      /*appBar: AppBar(
        //title: Text(_currentIndex.value == 2 ? "Activity" : title),
        //backgroundColor: _currentIndex.value == 2 ? Colors.white : Color.fromRGBO(249, 244, 235, 1.0),
        elevation: 0,
        //actions: [
          /*Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.refresh),
              onPressed: !store.state.loading
                  ? () async {
                      await store.fetchOwnBalance();
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("Balance updated"),
                        duration: Duration(milliseconds: 800),
                      ));
                    }
                  : null,
            ),
          ),*/
          /*,
        ],*/
      ),*/
      body: PageView(
        controller: controller,
        children: _children,
        onPageChanged: (index) => {},
      ),
    );
  }

  void onTabTapped(int index) {
    //setState(() {
    _currentIndex.value = index;
    //});
  }

  Widget settingsPage(dynamic context) {
    var configurationService = Provider.of<ConfigurationService>(context);
    /*if (configurationService.didSetupWallet())
      return WalletProvider(builder: (context, store) {*/
    return AccountSettingsPage(store, configurationService);
    //});
  }
}
