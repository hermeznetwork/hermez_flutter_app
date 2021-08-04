import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hermez/context/transfer/wallet_transfer_provider.dart';
import 'package:hermez/model/tab_navigation_item.dart';
import 'package:hermez/screens/account_selector.dart';
import 'package:hermez/screens/qrcode_scanner.dart';
import 'package:hermez/screens/settings.dart';
import 'package:hermez/screens/settings_currency.dart';
import 'package:hermez/screens/settings_details.dart';
import 'package:hermez/screens/store_selector.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez/screens/wallet_details.dart';
import 'package:hermez/screens/wallet_selector.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_sdk/addresses.dart';
import 'package:hermez_sdk/model/account.dart';
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
  GlobalKey _scaffoldKey;

  @override
  void initState() {
    //widget.arguments.store.initialise();
    initialize();
    showHermezWallet = widget.arguments.showHermezWallet;
    _currentIndex = ValueNotifier(0);
    updateItems();
    children = [
      for (final tabItem in items)
        Navigator(onGenerateRoute: (settings) {
          _context = context;
          Widget page = tabItem.page;
          if (settings.name == 'wallet_details') {
            _scaffoldKey = GlobalKey<ScaffoldState>();
            page = WalletDetailsPage(
              key: _scaffoldKey,
              arguments: settings.arguments,
            );
          } else if (settings.name == 'settings_details') {
            _scaffoldKey = GlobalKey<ScaffoldState>();
            var configurationService =
                Provider.of<ConfigurationService>(context, listen: false);
            page = SettingsDetailsPage(
                key: _scaffoldKey,
                arguments: settings.arguments,
                configurationService: configurationService);
          } else if (settings.name == 'account_selector') {
            final AccountSelectorArguments args = settings.arguments;
            page = AccountSelectorPage(/*key: _scaffoldKey,*/ arguments: args);
          } else if (settings.name == 'currency_selector') {
            page = SettingsCurrencyPage(store: widget.arguments.store);
          } else if (settings.name == 'fee_selector') {
            page = FeeSelectorPage(
                /*key: _scaffoldKey,*/
                arguments: FeeSelectorArguments(widget.arguments.store));
          } else if (settings.name == 'account_details') {
            final AccountDetailsArguments args = settings.arguments;
            page = AccountDetailsPage(/*key: _scaffoldKey,*/ arguments: args);
          } else if (settings.name == 'transaction_details') {
            page = WalletTransferProvider(
              builder: (context, store) {
                return TransactionDetailsPage(
                    /*key: _scaffoldKey,*/ arguments: settings.arguments);
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
    updateItems();
    /*return FutureBuilder(
        future: initialize(),
        builder: (context, snapshot) {*/
    if (widget.arguments.store.state.ethereumAddress == null) {
      return Container(
          color: HermezColors.lightOrange,
          child: Center(
            child: CircularProgressIndicator(color: HermezColors.orange),
          ));
    } else {
      return WillPopScope(
          child: Scaffold(
            body: IndexedStack(
              index: _currentIndex.value,
              children: children,
            ),
            extendBody: true,
            bottomNavigationBar: BottomNavigationBar(
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: HermezColors.blackTwo,
                unselectedItemColor: HermezColors.blueyGreyTwo,
                backgroundColor: Colors.transparent, // transparent
                showSelectedLabels: false,
                showUnselectedLabels: false,
                currentIndex: _currentIndex.value,
                onTap: (int index) => onTabTapped(index, context),
                items: [
                  for (final tabItem in items)
                    BottomNavigationBarItem(
                        backgroundColor: HermezColors.transparent,
                        icon: tabItem.icon,
                        label: tabItem.title)
                ]),
          ),
          onWillPop: () async {
            try {
              if (Navigator.of(_scaffoldKey.currentContext).canPop()) {
                Navigator.of(_scaffoldKey.currentContext).pop();
                return false;
              } else {
                return true;
              }
            } catch (e) {
              print(e.toString());
              return true;
            }
          });
    }
    //});
  }

  Future<void> initialize() async {
    if (widget.arguments.store.state.walletInitialized == false &&
        widget.arguments.store.state.loading == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Add Your Code here.
        widget.arguments.store.initialise();
      });
    }
    return;
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
                      await widget.arguments.store.getL2Accounts();
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
                    page = StoreSelectorPage(
                        arguments: StoreSelectorArguments(context));
                  } else if (index == 3) {
                    page = settingsPage(context);
                  }
                  if (settings.name == 'wallet_details') {
                    _scaffoldKey = GlobalKey<ScaffoldState>();
                    page = WalletDetailsPage(
                      key: _scaffoldKey,
                      arguments: settings.arguments,
                    );
                  } else if (settings.name == 'settings_details') {
                    var configurationService =
                        Provider.of<ConfigurationService>(context,
                            listen: false);
                    _scaffoldKey = GlobalKey<ScaffoldState>();
                    page = SettingsDetailsPage(
                        key: _scaffoldKey,
                        arguments: settings.arguments,
                        configurationService: configurationService);
                  } else if (settings.name == 'account_selector') {
                    final AccountSelectorArguments args = settings.arguments;
                    page = AccountSelectorPage(arguments: args);
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
                            /*key: _scaffoldKey,*/ arguments:
                                settings.arguments);
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
    return SettingsPage(widget.arguments.store, configurationService, context,
        () {
      this.showHermezWallet = true;
      onTabTapped(0, context);
    });
  }

  updateItems() {
    items = [
      TabNavigationItem(
        page: WalletSelectorPage(
            arguments: WalletSelectorArguments(widget.arguments.store, context,
                showHermezWallet: showHermezWallet, hermezWalletShown: () {
          showHermezWallet = false;
        })),
        icon: SvgPicture.asset('assets/tab_home.svg',
            color: _currentIndex.value == 0
                ? HermezColors.blackTwo
                : HermezColors.blueyGreyTwo),
        title: "Home",
      ),
      TabNavigationItem(
        page: Container(),
        icon: SvgPicture.asset('assets/tab_scan.svg',
            color: _currentIndex.value == 1
                ? HermezColors.blackTwo
                : HermezColors.blueyGreyTwo),
        title: "QR Scan",
      ),
      TabNavigationItem(
        page: StoreSelectorPage(arguments: StoreSelectorArguments(context)),
        icon: Image.asset('assets/tab_store.png',
            height: 26,
            color: _currentIndex.value == 2
                ? HermezColors.blackTwo
                : HermezColors.blueyGreyTwo),
        title: "Store",
      ),
      TabNavigationItem(
        page: settingsPage(context),
        icon: Stack(children: [
          SvgPicture.asset('assets/tab_settings.svg',
              color: _currentIndex.value == 3
                  ? HermezColors.blackTwo
                  : HermezColors.blueyGreyTwo),
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
  }
}
