import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hermez/context/transfer/wallet_transfer_provider.dart';
import 'package:hermez/dependencies_provider.dart';
import 'package:hermez/model/tab_navigation_item.dart';
import 'package:hermez/src/presentation/accounts/widgets/account_details.dart';
import 'package:hermez/src/presentation/accounts/widgets/account_selector.dart';
import 'package:hermez/src/presentation/qrcode/widgets/qrcode_scanner.dart';
import 'package:hermez/src/presentation/settings/settings_bloc.dart';
import 'package:hermez/src/presentation/settings/settings_state.dart';
import 'package:hermez/src/presentation/settings/widgets/settings.dart';
import 'package:hermez/src/presentation/settings/widgets/settings_currency.dart';
import 'package:hermez/src/presentation/settings/widgets/settings_details.dart';
import 'package:hermez/src/presentation/transactions/widgets/transaction_details.dart';
import 'package:hermez/src/presentation/transfer/widgets/fee_selector.dart';
import 'package:hermez/src/presentation/wallets/wallets_bloc.dart';
import 'package:hermez/src/presentation/wallets/wallets_state.dart';
import 'package:hermez/src/presentation/wallets/widgets/wallet_details.dart';
import 'package:hermez/src/presentation/wallets/widgets/wallet_selector.dart';
import 'package:hermez/utils/hermez_colors.dart';

class HomeArguments {
  bool showHermezWallet;

  HomeArguments({this.showHermezWallet = false});
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

  List<TabNavigationItem> items;
  bool showHermezWallet = false;

  GlobalKey _scaffoldKey;

  final WalletsBloc _bloc;
  final SettingsBloc _settingsBloc;
  _HomePageState()
      : _bloc = getIt<WalletsBloc>(),
        _settingsBloc = getIt<SettingsBloc>() {
    if (_bloc.state is LoadingWalletsState) {
      _bloc.fetchData();
    }
    if (_settingsBloc.state is InitSettingsState) {
      _settingsBloc.init();
    }
  }

  @override
  void initState() {
    _currentIndex = ValueNotifier(0);
    showHermezWallet = widget.arguments.showHermezWallet;
    updateItems();
    children = [
      for (final tabItem in items)
        Navigator(onGenerateRoute: (settings) {
          Widget page = tabItem.page;
          if (settings.name == 'wallet_details') {
            _scaffoldKey = GlobalKey<ScaffoldState>();
            page = WalletDetailsPage(
              key: _scaffoldKey,
              arguments: settings.arguments,
            );
          } else if (settings.name == 'settings_details') {
            _scaffoldKey = GlobalKey<ScaffoldState>();
            page = SettingsDetailsPage(
              key: _scaffoldKey,
              arguments: settings.arguments,
            );
          } else if (settings.name == 'account_selector') {
            final AccountSelectorArguments args = settings.arguments;
            page = AccountSelectorPage(arguments: args);
          } else if (settings.name == 'currency_selector') {
            final SettingsBloc settingsBloc = settings.arguments;
            page = SettingsCurrencyPage(
              settingsBloc: settingsBloc,
            );
          } else if (settings.name == 'fee_selector') {
            final SettingsBloc settingsBloc = settings.arguments;
            page = FeeSelectorPage(
                arguments: FeeSelectorArguments(settingsBloc: settingsBloc));
          } else if (settings.name == 'account_details') {
            final AccountDetailsArguments args = settings.arguments;
            page = AccountDetailsPage(arguments: args);
          } else if (settings.name == 'transaction_details') {
            page =
                /*WalletTransferProvider(
              builder: (context, store) {
                return*/
                TransactionDetailsPage(arguments: settings.arguments);
            //},
            //);
          }

          return MaterialPageRoute(builder: (_) => page);
        }),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WalletsState>(
      initialData: _bloc.state,
      stream: _bloc.observableState,
      builder: (context, snapshot) {
        final state = snapshot.data;
        if (state is LoadingWalletsState) {
          return Container(
              color: HermezColors.lightOrange,
              child: Center(
                child: CircularProgressIndicator(color: HermezColors.orange),
              ));
        } else if (state is ErrorWalletsState) {
          return _renderErrorContent();
        } else {
          return _renderHomeContent(context, state);
        }
      },
    );
  }

  Widget _renderHomeContent(BuildContext context, LoadedWalletsState state) {
    updateItems(state);

    return WillPopScope(
        child: Scaffold(
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
                  BottomNavigationBarItem(
                      icon: tabItem.icon, label: tabItem.title)
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

  void onTabTapped(int index, BuildContext context) {
    if (index == 1) {
      Navigator.of(context).pushNamed(
        "/scanner",
        arguments: QRCodeScannerArguments(
          //store: widget.arguments.store,
          type: QRCodeScannerType.ALL,
          closeWhenScanned: false,
          onScanned: (value) async {
            /*List<String> scannedStrings = value.split(':');
            if (scannedStrings.length > 0) {
              if (isEthereumAddress(scannedStrings[0])) {
                if (scannedStrings.length > 1) {
                  bool accountFound = false;
                  List<Account> accounts =
                      await widget.arguments.store.getL1Accounts(true);
                  for (Account account in accounts) {
                    Token token = widget.arguments.store.state.tokens
                        .firstWhere((token) => token.id == account.tokenId);
                    PriceToken priceToken =
                        widget.arguments.store.state.priceTokens.firstWhere(
                            (priceToken) => priceToken.id == account.tokenId);
                    if (token.symbol == scannedStrings[1]) {
                      accountFound = true;
                      Navigator.pushReplacementNamed(
                          context, "/transaction_amount",
                          arguments: TransactionAmountArguments(
                              widget.arguments.store,
                              TransactionLevel.LEVEL1,
                              TransactionType.SEND,
                              account: account,
                              token: token,
                              priceToken: priceToken,
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
                    Token token = widget.arguments.store.state.tokens
                        .firstWhere((token) => token.id == account.tokenId);
                    PriceToken priceToken =
                        widget.arguments.store.state.priceTokens.firstWhere(
                            (priceToken) => priceToken.id == account.tokenId);
                    if (token.symbol == scannedStrings[2]) {
                      accountFound = true;
                      Navigator.pushReplacementNamed(
                          context, "/transaction_amount",
                          arguments: TransactionAmountArguments(
                              widget.arguments.store,
                              TransactionLevel.LEVEL2,
                              TransactionType.SEND,
                              account: account,
                              token: token,
                              priceToken: priceToken,
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
            }*/
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
                        arguments: WalletSelectorArguments(
                            _bloc, _settingsBloc, context,
                            showHermezWallet: showHermezWallet,
                            hermezWalletShown: () {
                      showHermezWallet = false;
                    }));
                  } else if (index == 2) {
                    page = settingsPage(context);
                  }
                  if (settings.name == 'wallet_details') {
                    _scaffoldKey = GlobalKey<ScaffoldState>();
                    page = WalletDetailsPage(
                      key: _scaffoldKey,
                      arguments: settings.arguments,
                    );
                  } else if (settings.name == 'settings_details') {
                    _scaffoldKey = GlobalKey<ScaffoldState>();
                    page = SettingsDetailsPage(
                        key: _scaffoldKey, arguments: settings.arguments);
                  } else if (settings.name == 'account_selector') {
                    final AccountSelectorArguments args = settings.arguments;
                    page = AccountSelectorPage(arguments: args);
                  } else if (settings.name == 'currency_selector') {
                    final SettingsBloc settingsBloc = settings.arguments;
                    page = SettingsCurrencyPage(
                      settingsBloc: settingsBloc,
                    );
                  } else if (settings.name == 'fee_selector') {
                    final SettingsBloc settingsBloc = settings.arguments;
                    page = FeeSelectorPage(
                        arguments:
                            FeeSelectorArguments(settingsBloc: settingsBloc));
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

  Widget settingsPage(BuildContext context) {
    return SettingsPage(_bloc, _settingsBloc, context, () {
      this.showHermezWallet = true;
      onTabTapped(0, context);
    });
  }

  updateItems([LoadedWalletsState state]) {
    items = [
      TabNavigationItem(
        page: WalletSelectorPage(
            arguments: WalletSelectorArguments(_bloc, _settingsBloc, context,
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
        page: settingsPage(context),
        icon: Stack(children: [
          SvgPicture.asset('assets/tab_settings.svg',
              color: _currentIndex.value == 2
                  ? HermezColors.blackTwo
                  : HermezColors.blueyGreyTwo),
          Positioned(
              bottom: -1,
              right: -1,
              child: Stack(
                children: [
                  state != null && state.wallets[0].isBackedUp
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

  Widget _renderErrorContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(34.0),
      child: Column(
        children: [
          Text(
            'There was an error loading \n\n this page.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: HermezColors.blueyGrey,
              fontSize: 16,
              fontFamily: 'ModernEra',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
