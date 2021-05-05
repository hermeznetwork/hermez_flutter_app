import 'package:flutter/material.dart';
import 'package:hermez/context/transfer/wallet_transfer_provider.dart';
import 'package:hermez/model/tab_navigation_item.dart';
import 'package:hermez/screens/scanner.dart';
import 'package:hermez/screens/settings.dart';
import 'package:hermez/screens/settings_currency.dart';
import 'package:hermez/screens/settings_details.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez/screens/wallet_details.dart';
import 'package:hermez/screens/wallet_selector.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_plugin/addresses.dart';
import 'package:hermez_plugin/model/account.dart';
import 'package:provider/provider.dart';

import '../context/wallet/wallet_handler.dart';
import 'account_details.dart';
import 'account_selector.dart';
import 'fee_selector.dart';
import 'transaction_details.dart';

class HomePage extends StatefulWidget {
  HomePage(this.store, this.configurationService);

  final WalletHandler store;
  final ConfigurationService configurationService;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ValueNotifier _currentIndex;
  List<Widget> children;

  //final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<TabNavigationItem> items;

  @override
  void initState() {
    widget.store.initialise();
    _currentIndex = ValueNotifier(0);
    items = [
      TabNavigationItem(
        page: WalletSelectorPage(store: widget.store, parentContext: context),
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
        icon: Stack(children: [
          ImageIcon(
            AssetImage('assets/settings2.png'),
          ),
          Positioned(
              bottom: -1,
              right: -1,
              child: Stack(
                children: [
                  widget.configurationService.didBackupWallet()
                      ? Container()
                      : Icon(Icons.brightness_1,
                          size: 8.0, color: HermezColors.darkOrange)
                ],
              ))
        ]),
        title: "Settings",
      ),
    ];
    children = [
      for (final tabItem in items)
        Navigator(onGenerateRoute: (settings) {
          Widget page = tabItem.page;
          if (settings.name == 'home') {
            page = WalletDetailsPage(
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
          } else if (settings.name == 'fee_selector') {
            page =
                FeeSelectorPage(arguments: FeeSelectorArguments(widget.store));
          } else if (settings.name == 'account_details') {
            final AccountDetailsArguments args = settings.arguments;
            page = AccountDetailsPage(arguments: args);
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
    return Scaffold(
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
          closeWhenScanned: false,
          onScanned: (value) async {
            List<String> scannedStrings = value.split(':');
            if (scannedStrings.length > 0) {
              if (isEthereumAddress(scannedStrings[0])) {
                if (scannedStrings.length > 1) {
                  bool accountFound = false;
                  List<Account> accounts =
                      await widget.store.getL1Accounts(true);
                  for (Account account in accounts) {
                    if (account.token.symbol == scannedStrings[1]) {
                      accountFound = true;
                      Navigator.pushReplacementNamed(
                          context, "/transaction_amount",
                          arguments: TransactionAmountArguments(widget.store,
                              TransactionLevel.LEVEL1, TransactionType.SEND,
                              account: account,
                              addressTo: scannedStrings[0],
                              amount: double.parse(scannedStrings[2]),
                              allowChangeLevel: false));
                      break;
                    }
                  }
                  if (accountFound == false) {
                    Navigator.pushReplacementNamed(context, "/account_selector",
                        arguments: AccountSelectorArguments(
                            TransactionLevel.LEVEL1,
                            TransactionType.SEND,
                            widget.store,
                            addressTo: scannedStrings[0]));
                  }
                } else {
                  Navigator.pushReplacementNamed(context, "/account_selector",
                      arguments: AccountSelectorArguments(
                          TransactionLevel.LEVEL1,
                          TransactionType.SEND,
                          widget.store,
                          addressTo: scannedStrings[0]));
                }
              } else if (isHermezEthereumAddress(
                  scannedStrings[0] + ":" + scannedStrings[1])) {
                if (scannedStrings.length > 2) {
                  bool accountFound = false;
                  List<Account> accounts = await widget.store.getAccounts();
                  for (Account account in accounts) {
                    if (account.token.symbol == scannedStrings[2]) {
                      accountFound = true;
                      Navigator.pushReplacementNamed(
                          context, "/transaction_amount",
                          arguments: TransactionAmountArguments(widget.store,
                              TransactionLevel.LEVEL2, TransactionType.SEND,
                              account: account,
                              addressTo:
                                  scannedStrings[0] + ":" + scannedStrings[1],
                              amount: double.parse(scannedStrings[3]),
                              allowChangeLevel: false));
                      break;
                    }
                  }
                  if (accountFound == false) {
                    Navigator.pushReplacementNamed(context, "/account_selector",
                        arguments: AccountSelectorArguments(
                            TransactionLevel.LEVEL2,
                            TransactionType.SEND,
                            widget.store,
                            addressTo:
                                scannedStrings[0] + ":" + scannedStrings[1]));
                  }
                } else {
                  Navigator.of(context).pushNamed("/account_selector",
                      arguments: AccountSelectorArguments(
                          TransactionLevel.LEVEL2,
                          TransactionType.SEND,
                          widget.store,
                          addressTo:
                              scannedStrings[0] + ":" + scannedStrings[1]));
                }
              }
            }
          },
        ),
      );
    } else {
      setState(() {
        children.removeAt(index);
        children.insert(
            index,
            Navigator(
                key: GlobalKey(),
                onGenerateRoute: (settings) {
                  Widget page;
                  if (index == 0) {
                    page = WalletSelectorPage(
                        store: widget.store, parentContext: context);
                  } else if (index == 2) {
                    page = settingsPage(context);
                  }
                  if (settings.name == 'home') {
                    page = WalletDetailsPage(
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
                  } else if (settings.name == 'fee_selector') {
                    page = FeeSelectorPage(
                        arguments: FeeSelectorArguments(widget.store));
                  } else if (settings.name == 'account_details') {
                    final AccountDetailsArguments args = settings.arguments;
                    page = AccountDetailsPage(arguments: args);
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
    return SettingsPage(widget.store, configurationService, context);
  }
}
