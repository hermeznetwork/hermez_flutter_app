import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hermez/context/transfer/wallet_transfer_provider.dart';
import 'package:hermez/model/tab_navigation_item.dart';
import 'package:hermez/screens/qrcode_scanner.dart';
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
import 'fee_selector.dart';
import 'transaction_details.dart';

class HomeArguments {
  bool showHermezWallet;
  final WalletHandler store;
  final ConfigurationService configurationService;

  HomeArguments(this.store, this.configurationService,
      {this.showHermezWallet = false});
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.arguments}) : super(key: key);

  final HomeArguments arguments;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ValueNotifier _currentIndex;
  List<Widget> children;
  Navigator navigator;
  BuildContext _context;

  //final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<TabNavigationItem> items;

  bool showHermezWallet = false;

  @override
  void initState() {
    widget.arguments.store.initialise();
    showHermezWallet = widget.arguments.showHermezWallet;
    _currentIndex = ValueNotifier(0);
    items = [
      TabNavigationItem(
        page: WalletSelectorPage(
            arguments: WalletSelectorArguments(widget.arguments.store, context,
                showHermezWallet: showHermezWallet, hermezWalletShown: () {
          showHermezWallet = false;
        })),
        icon: SvgPicture.asset('assets/tab_home.svg'),
        title: "Home",
      ),
      TabNavigationItem(
        page: Container(),
        icon: SvgPicture.asset('assets/tab_scan.svg'),
        title: "QR Scan",
      ),
      TabNavigationItem(
        page: settingsPage(context),
        icon: Stack(children: [
          SvgPicture.asset('assets/tab_settings.svg'),
          Positioned(
              bottom: -1,
              right: -1,
              child: Stack(
                children: [
                  widget.arguments.configurationService.didBackupWallet()
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
          _context = context;
          Widget page = tabItem.page;
          if (settings.name == 'wallet_details') {
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
            page = SettingsCurrencyPage(store: widget.arguments.store);
          } else if (settings.name == 'fee_selector') {
            page = FeeSelectorPage(
                arguments: FeeSelectorArguments(widget.arguments.store));
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
          store: widget.arguments.store,
          type: QRCodeScannerType.ALL,
          closeWhenScanned: false,
          onScanned: (value) async {
            List<String> scannedStrings = value.split(':');
            if (scannedStrings.length > 0) {
              if (isEthereumAddress(scannedStrings[0])) {
                if (scannedStrings.length > 1) {
                  bool accountFound = false;
                  List<Account> accounts =
                      await widget.arguments.store.getL1Accounts(true);
                  for (Account account in accounts) {
                    if (account.token.symbol == scannedStrings[1]) {
                      accountFound = true;
                      Navigator.pushReplacementNamed(
                          context, "/transaction_amount",
                          arguments: TransactionAmountArguments(
                              widget.arguments.store,
                              TransactionLevel.LEVEL1,
                              TransactionType.SEND,
                              account: account,
                              addressTo: scannedStrings[0],
                              amount: double.parse(scannedStrings[2]),
                              allowChangeLevel: false));
                      break;
                    }
                  }
                  if (accountFound == false) {
                    Navigator.pushReplacementNamed(
                        context, "/transaction_amount",
                        arguments: TransactionAmountArguments(
                            widget.arguments.store,
                            TransactionLevel.LEVEL1,
                            TransactionType.SEND,
                            addressTo: scannedStrings[0]));
                  }
                } else {
                  Navigator.pushReplacementNamed(context, "/transaction_amount",
                      arguments: TransactionAmountArguments(
                          widget.arguments.store,
                          TransactionLevel.LEVEL1,
                          TransactionType.SEND,
                          addressTo: scannedStrings[0]));
                }
              } else if (isHermezEthereumAddress(
                  scannedStrings[0] + ":" + scannedStrings[1])) {
                if (scannedStrings.length > 2) {
                  bool accountFound = false;
                  List<Account> accounts =
                      await widget.arguments.store.getAccounts();
                  for (Account account in accounts) {
                    if (account.token.symbol == scannedStrings[2]) {
                      accountFound = true;
                      Navigator.pushReplacementNamed(
                          context, "/transaction_amount",
                          arguments: TransactionAmountArguments(
                              widget.arguments.store,
                              TransactionLevel.LEVEL2,
                              TransactionType.SEND,
                              account: account,
                              addressTo:
                                  scannedStrings[0] + ":" + scannedStrings[1],
                              amount: double.parse(scannedStrings[3]),
                              allowChangeLevel: false));
                      break;
                    }
                  }
                  if (accountFound == false) {
                    Navigator.pushReplacementNamed(
                        context, "/transaction_amount",
                        arguments: TransactionAmountArguments(
                            widget.arguments.store,
                            TransactionLevel.LEVEL2,
                            TransactionType.SEND,
                            addressTo:
                                scannedStrings[0] + ":" + scannedStrings[1]));
                  }
                } else {
                  Navigator.pushReplacementNamed(context, "/transaction_amount",
                      arguments: TransactionAmountArguments(
                          widget.arguments.store,
                          TransactionLevel.LEVEL2,
                          TransactionType.SEND,
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
                  _context = context;
                  Widget page;
                  if (index == 0) {
                    page = WalletSelectorPage(
                        arguments: WalletSelectorArguments(
                            widget.arguments.store, context,
                            showHermezWallet: showHermezWallet,
                            hermezWalletShown: () {
                      showHermezWallet = false;
                    }));
                  } else if (index == 2) {
                    page = settingsPage(context);
                  }
                  if (settings.name == 'wallet_details') {
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
                    page = SettingsCurrencyPage(store: widget.arguments.store);
                  } else if (settings.name == 'fee_selector') {
                    page = FeeSelectorPage(
                        arguments:
                            FeeSelectorArguments(widget.arguments.store));
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
    return SettingsPage(widget.arguments.store, configurationService, context);
  }
}
