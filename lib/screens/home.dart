import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/components/wallet/home_balance.dart';
import 'package:hermez/model/tab_navigation_item.dart';
import 'package:hermez/screens/scanner.dart';
import 'package:hermez/screens/settings.dart';
import 'package:hermez/screens/wallet_selector.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';
import 'package:provider/provider.dart';

import '../context/wallet/wallet_handler.dart';
import '../context/wallet/wallet_provider.dart';

class HomePage extends HookWidget {
  WalletHandler store;

  ValueNotifier _currentIndex;

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

    List<TabNavigationItem> items = [
      TabNavigationItem(
        page: WalletSelectorPage(
          store: store,
        ) /*HomeBalance(
          arguments: HomeBalanceArguments(
            store,
            null,
            _scaffoldKey,
          ),
        )*/
        ,
        icon: ImageIcon(
          AssetImage('assets/home_tab_item.png'),
        ),
        title: "Home",
      ),
      TabNavigationItem(
        page: QRCodeScannerPage(
          arguments: QRCodeScannerArguments(
              store: store,
              type: QRCodeScannerType.ALL,
              onScanned: ModalRoute.of(context).settings.arguments),
        ),
        icon: ImageIcon(
          AssetImage('assets/scan.png'),
        ),
        title: "QR Scan",
      ),
      TabNavigationItem(
        page: settingsPage(context),
        icon: ImageIcon(
          AssetImage('assets/settings2.png'),
        ),
        title: "Settings",
      ),
    ];

    return Scaffold(
      key: _scaffoldKey,
      body: Navigator(onGenerateRoute: (settings) {
        Widget page = WalletSelectorPage(
          store: store,
        );
        if (settings.name == 'home')
          page = HomeBalance(
            arguments: HomeBalanceArguments(
              store,
              null,
              _scaffoldKey,
            ),
          );
        return MaterialPageRoute(builder: (_) => page);
      }),
      /* IndexedStack(
        index: _currentIndex.value,
        children: [
          for (final tabItem in items) tabItem.page,
        ],
      ),*/
      bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: HermezColors.blackTwo,
          unselectedItemColor: HermezColors.blueyGreyTwo,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: _currentIndex.value,
          onTap: (int index) => onTabTapped(index),
          items: [
            for (final tabItem in items)
              BottomNavigationBarItem(icon: tabItem.icon, label: tabItem.title)
          ]),
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
    return SettingsPage(store, configurationService);
    //});
  }
}
