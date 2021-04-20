import 'package:flutter/material.dart';
import 'package:hermez/components/wallet/home_balance.dart';
import 'package:hermez/context/transfer/wallet_transfer_provider.dart';
import 'package:hermez/model/tab_navigation_item.dart';
import 'package:hermez/screens/scanner.dart';
import 'package:hermez/screens/settings.dart';
import 'package:hermez/screens/settings_currency.dart';
import 'package:hermez/screens/settings_details.dart';
import 'package:hermez/screens/wallet_selector.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:provider/provider.dart';

import '../context/wallet/wallet_handler.dart';
import '../wallet_account_details_page.dart';
import '../wallet_transaction_details_page.dart';

class HomePage extends StatefulWidget {
  HomePage(this.store);

  final WalletHandler store;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ValueNotifier _currentIndex;
  List<Widget> children;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<TabNavigationItem> items;

  @override
  void initState() {
    widget.store.initialise();
    _currentIndex = ValueNotifier(0);
    items = [
      TabNavigationItem(
        page: WalletSelectorPage(widget.store, context),
        icon: ImageIcon(
          AssetImage('assets/home_tab_item.png'),
        ),
        title: "Home",
      ),
      TabNavigationItem(
        page: Container(),
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
    children = [
      for (final tabItem in items)
        Navigator(onGenerateRoute: (settings) {
          Widget page = tabItem.page;
          if (settings.name == 'home') {
            page = HomeBalance(
              arguments: settings.arguments,
            );
          } else if (settings.name == 'settings_details') {
            var configurationService =
                Provider.of<ConfigurationService>(context, listen: false);
            page = SettingsDetailsPage(
                arguments: settings.arguments,
                configurationService: configurationService);
          } else if (settings.name == 'currency_selector') {
            page = SettingsCurrencyPage(store: widget.store);
          } else if (settings.name == 'account_details') {
            final WalletAccountDetailsArguments args = settings.arguments;
            page = WalletAccountDetailsPage(args);
          } else if (settings.name == 'transaction_details') {
            page = WalletTransferProvider(
              builder: (context, store) {
                return TransactionDetailsPage(arguments: settings.arguments);
              },
            );
          }
          return MaterialPageRoute(builder: (_) => page);
        }),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // store = useWallet(context);
    //useState(0);

    /*useEffect(() {
      store.initialise();
      return null;
    }, [store]);*/

    return Scaffold(
      key: _scaffoldKey,
      body: IndexedStack(
        index: _currentIndex.value,
        children: children,
      ),
      extendBody: true,
      bottomNavigationBar: BottomNavigationBar(
          elevation: 0,
          selectedItemColor: HermezColors.blackTwo,
          unselectedItemColor: HermezColors.blueyGreyTwo,
          backgroundColor: Colors.transparent, // transparent
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: _currentIndex.value,
          onTap: (int index) => onTabTapped(index, context),
          items: [
            for (final tabItem in items)
              BottomNavigationBarItem(icon: tabItem.icon, label: tabItem.title)
          ]),
    );
  }

  void onTabTapped(int index, BuildContext context) {
    if (index == 1) {
      Navigator.of(context).pushNamed(
        "/scanner",
        arguments: QRCodeScannerArguments(
          store: widget.store,
          type: QRCodeScannerType.ALL,
          onScanned: (value) async {
            /*List<String> clipboardWords =
            value.replaceAll(RegExp("\\s+"), " ").split(" ");
            setState(
                  () {
                int maxLength =
                min(clipboardWords.length, words.length);
                for (int i = 0; i < maxLength; i++) {
                  words[i] = clipboardWords[i];
                  textEditingControllers[i].text = clipboardWords[i];
                }
                checkEnabledButton();
              },
            );*/
          },
        ),
      );
    } else {
      setState(() {
        //widget.store.initialise();
        children.removeAt(index);
        children.insert(
            index,
            Navigator(
                key: GlobalKey(),
                onGenerateRoute: (settings) {
                  Widget page;
                  if (index == 0) {
                    page = WalletSelectorPage(widget.store, context);
                  } else if (index == 2) {
                    page = settingsPage(context);
                  }
                  if (settings.name == 'home') {
                    page = HomeBalance(
                      arguments: settings.arguments,
                    );
                  } else if (settings.name == 'settings_details') {
                    var configurationService =
                        Provider.of<ConfigurationService>(context,
                            listen: false);
                    page = SettingsDetailsPage(
                        arguments: settings.arguments,
                        configurationService: configurationService);
                  } else if (settings.name == 'currency_selector') {
                    page = SettingsCurrencyPage(store: widget.store);
                  } else if (settings.name == 'account_details') {
                    final WalletAccountDetailsArguments args =
                        settings.arguments;
                    page = WalletAccountDetailsPage(args);
                  } else if (settings.name == 'transaction_details') {
                    page = WalletTransferProvider(
                      builder: (context, store) {
                        return TransactionDetailsPage(
                            arguments: settings.arguments);
                      },
                    );
                  }
                  return MaterialPageRoute(builder: (_) => page);
                }));
        _currentIndex.value = index;
      });
    }
  }

  Widget settingsPage(dynamic context) {
    var configurationService =
        Provider.of<ConfigurationService>(context, listen: false);
    /*if (configurationService.didSetupWallet())
      return WalletProvider(builder: (context, store) {*/
    return SettingsPage(widget.store, configurationService, context);
    //});
  }
}
