import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hermez/components/wallet/account_row.dart';
import 'package:hermez/components/wallet/withdrawal_row.dart';
import 'package:hermez/constants.dart';
import 'package:hermez/dependencies_provider.dart';
import 'package:hermez/service/network/model/gas_price_response.dart';
import 'package:hermez/src/domain/accounts/account.dart';
import 'package:hermez/src/domain/prices/price_token.dart';
import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez/src/domain/wallets/wallet.dart';
import 'package:hermez/src/presentation/accounts/widgets/account_details.dart';
import 'package:hermez/src/presentation/qrcode/widgets/qrcode.dart';
import 'package:hermez/src/presentation/settings/settings_bloc.dart';
import 'package:hermez/src/presentation/tokens/widgets/token_row.dart';
import 'package:hermez/src/presentation/transactions/widgets/transaction_details.dart';
import 'package:hermez/src/presentation/transfer/transfer_bloc.dart';
import 'package:hermez/src/presentation/transfer/widgets/transaction_amount.dart';
import 'package:hermez/src/presentation/wallets/wallets_bloc.dart';
import 'package:hermez/utils/address_utils.dart';
import 'package:hermez/utils/balance_utils.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/utils/pop_result.dart';
import 'package:hermez_sdk/constants.dart';
import 'package:hermez_sdk/environment.dart';
import 'package:hermez_sdk/model/exit.dart';
import 'package:hermez_sdk/model/pool_transaction.dart';
import 'package:hermez_sdk/model/state_response.dart';
import 'package:hermez_sdk/model/token.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class WalletDetailsArguments {
  //final WalletHandler store;
  final TransactionLevel transactionLevel;
  final BuildContext parentContext;
  final bool needRefresh;

  WalletDetailsArguments(
      /*this.store,*/ this.transactionLevel,
      this.parentContext,
      this.needRefresh);
}

class WalletDetailsPage extends StatefulWidget {
  WalletDetailsPage({Key key, this.arguments}) : super(key: key);

  final WalletDetailsArguments arguments;

  @override
  _WalletDetailsPageState createState() => _WalletDetailsPageState();
}

class _WalletDetailsPageState extends State<WalletDetailsPage> {
  List<Account> _accounts;
  List<Token> _tokens;
  List<Exit> _exits = [];
  List<Exit> _filteredExits = [];
  List<bool> _allowedInstantWithdraws = [];
  List<dynamic> _pendingExits = [];
  List<dynamic> _pendingForceExits = [];
  List<dynamic> _pendingWithdraws = [];
  List<dynamic> _pendingDeposits = [];
  bool _isLoading = false;
  StateResponse _stateResponse;

  final WalletsBloc _bloc;
  _WalletDetailsPageState() : _bloc = getIt<WalletsBloc>();
  final SettingsBloc _settingsBloc = getIt<SettingsBloc>();
  final TransferBloc _transferBloc = getIt<TransferBloc>();

  /*@override
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
            return Center(child: Text(state.message));
          } else {
            return _renderWalletSelector(context, state);
          }
        });
  }

  Widget _renderWalletSelector(BuildContext context, LoadedWalletsState state) {*/

  @override
  void initState() {
    //fetchAccounts();
    super.initState();
    if (widget.arguments.needRefresh) {
      _onRefresh();
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });

    //await widget.arguments.store.getAccounts();
    setState(() {
      _isLoading = false;
    });
  }

  Future<List<Account>> fetchAccounts() async {
    _stateResponse = await getState();
    //await widget.arguments.store.getBlockAvgTime();
    await fetchPendingTransactions();
    if (_settingsBloc.state.settings.level == TransactionLevel.LEVEL2) {
      List<Account> accounts = null;
      //List.from(widget.arguments.store.state.l2Accounts);
      _pendingDeposits = fetchPendingDeposits();
      _pendingDeposits.forEach((pendingDeposit) {
        Account existingAccount = accounts.firstWhere(
            (account) =>
                (account.token.token.id == pendingDeposit['token']['id']),
            orElse: () => null);
        if (existingAccount == null) {
          Account pendingAccount = Account(
              balance: pendingDeposit['value'], token: pendingDeposit['token']);
          accounts.add(pendingAccount);
        }
      });
      return accounts;
    } else {
      List<Account> accounts;
      //List.from(widget.arguments.store.state.l1Accounts);
      return accounts;
    }
  }

  Future<void> fetchPendingTransactions() async {
    _pendingExits = fetchPendingExits();
    _exits = fetchExits();
    _filteredExits = _exits.toList();
    _pendingForceExits = fetchPendingForceExits(_exits, _pendingExits);
    _pendingWithdraws = fetchPendingWithdraws();
    _filteredExits.removeWhere((Exit exit) {
      for (dynamic pendingWithdraw in _pendingWithdraws) {
        if (pendingWithdraw["id"] ==
                (exit.accountIndex + exit.batchNum.toString()) ||
            (pendingWithdraw['instant'] == false &&
                exit.delayedWithdrawRequest != null &&
                Token.fromJson(pendingWithdraw['token']).id == exit.tokenId)) {
          return true;
        }
      }
      return false;
    });
    _allowedInstantWithdraws = [];
    for (int i = 0; i < _filteredExits.length; i++) {
      Exit exit = _filteredExits[i];
      final Token token = null;
      /*widget.arguments.store.state.tokens
          .firstWhere((token) => token.id == exit.tokenId);*/
      bool isAllowed = await _transferBloc.isInstantWithdrawalAllowed(
          double.parse(exit.balance), token);
      _allowedInstantWithdraws.add(isAllowed);
    }
  }

  List<PoolTransaction> fetchPendingExits() {
    /*List<PoolTransaction> poolTxs = widget.arguments.store.state.pendingL2Txs;
    poolTxs.removeWhere((transaction) => transaction.type != 'Exit');
    return poolTxs;*/
  }

  List<dynamic> fetchPendingForceExits(
      List<Exit> exits, List<PoolTransaction> pendingExits) {
    /*final accountPendingForceExits =
        widget.arguments.store.state.pendingForceExits;*/

    /*exits.forEach((exit) {
      var pendingExit = pendingExits.firstWhere(
          (pendingExit) => pendingExit.fromAccountIndex == exit.accountIndex,
          orElse: () => null);
      if (pendingExit == null) {
        var pendingForceExit = accountPendingForceExits.firstWhere(
            (pendingForceExit) =>
                pendingForceExit['amount'].toString() == exit.balance,
            orElse: null);
        if (pendingForceExit != null) {
          accountPendingForceExits.remove(pendingForceExit);
        }
      }
    });*/

    //return accountPendingForceExits;
  }

  List<Exit> fetchExits() {
    //return List.from(widget.arguments.store.state.exits);
  }

  List<dynamic> fetchPendingWithdraws() {
    //return List.from(widget.arguments.store.state.pendingWithdraws);
  }

  List<dynamic> fetchPendingDeposits() {
    //return List.from(widget.arguments.store.state.pendingDeposits);
  }

  Future<StateResponse> getState() async {
    //return await widget.arguments.store.getState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HermezColors.lightOrange,
      child: FutureBuilder(
        future: fetchAccounts(),
        builder: (buildContext, snapshot) {
          return Scaffold(
            body: NestedScrollView(
              body: handleAccountsList(snapshot),
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    snap: false,
                    collapsedHeight: kToolbarHeight,
                    expandedHeight: 340.0,
                    title: Container(
                      padding: EdgeInsets.all(20),
                      color: HermezColors.lightOrange,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'assets/' +
                                (_settingsBloc.state.settings.level ==
                                        TransactionLevel.LEVEL1
                                    ? "ethereum_logo"
                                    : "hermez_logo") +
                                '.png',
                            width: 30,
                            height: 30,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          new Text(
                              _settingsBloc.state.settings.level ==
                                      TransactionLevel.LEVEL1
                                  ? "Ethereum Wallet"
                                  : "Hermez Wallet",
                              style: TextStyle(
                                  fontFamily: 'ModernEra',
                                  color: HermezColors.blackTwo,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20)),
                          SizedBox(
                            width: 60,
                          ),
                        ],
                      ),
                    ),
                    centerTitle: true,
                    elevation: 0.0,
                    flexibleSpace: FlexibleSpaceBar(
                      // here the desired height*/
                      background: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).padding.top +
                                  kToolbarHeight +
                                  20),
                          Container(
                            margin: EdgeInsets.only(left: 40, right: 40),
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(56.0),
                                  side: BorderSide(
                                      color: HermezColors.mediumOrange)),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                    text: _settingsBloc.state.settings.level ==
                                            TransactionLevel.LEVEL1
                                        ? _settingsBloc
                                            .state.settings.ethereumAddress
                                        : _settingsBloc
                                            .state.settings.hermezAddress));
                                Flushbar(
                                  messageText: Text(
                                    'Copied',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: HermezColors.blackTwo,
                                      fontSize: 16,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  boxShadows: [
                                    BoxShadow(
                                      color: HermezColors.blueyGreyTwo
                                          .withAlpha(64),
                                      offset: Offset(0, 4),
                                      blurRadius: 16,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                  borderColor:
                                      HermezColors.blueyGreyTwo.withAlpha(64),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                  backgroundColor: Colors.white,
                                  margin: EdgeInsets.all(16.0),
                                  duration: Duration(
                                      seconds: FLUSHBAR_AUTO_HIDE_DURATION),
                                ).show(context);
                              },
                              padding: EdgeInsets.only(
                                  left: 20.0,
                                  right: 10.0,
                                  top: 10.0,
                                  bottom: 10.0),
                              color: HermezColors.mediumOrange,
                              textColor: HermezColors.steel,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget != null && widget.arguments != null && _settingsBloc.state.settings.ethereumAddress != null
                                        ? (_settingsBloc.state.settings.level == TransactionLevel.LEVEL1
                                            ? "0x" +
                                                    AddressUtils.strip0x(_settingsBloc.state.settings.ethereumAddress.substring(0, 6))
                                                        .toUpperCase() +
                                                    " ･･･ " +
                                                    _settingsBloc.state.settings.ethereumAddress
                                                        .substring(
                                                            _settingsBloc
                                                                    .state
                                                                    .settings
                                                                    .ethereumAddress
                                                                    .length -
                                                                4,
                                                            _settingsBloc
                                                                .state
                                                                .settings
                                                                .ethereumAddress
                                                                .length)
                                                        .toUpperCase() ??
                                                ""
                                            : "hez:" +
                                                    "0x" +
                                                    AddressUtils.strip0x(_settingsBloc.state.settings.ethereumAddress.substring(0, 6))
                                                        .toUpperCase() +
                                                    " ･･･ " +
                                                    _settingsBloc.state.settings
                                                        .ethereumAddress
                                                        .substring(_settingsBloc.state.settings.ethereumAddress.length - 4, _settingsBloc.state.settings.ethereumAddress.length)
                                                        .toUpperCase() ??
                                                "")
                                        : "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: HermezColors.steel,
                                      fontSize: 16,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        color: HermezColors.steel),
                                    padding: EdgeInsets.only(
                                        left: 12.0,
                                        right: 12.0,
                                        top: 4,
                                        bottom: 4),
                                    child: Text(
                                      _settingsBloc.state.settings.level ==
                                              TransactionLevel.LEVEL1
                                          ? "L1"
                                          : "L2",
                                      style: TextStyle(
                                        color: HermezColors.mediumOrange,
                                        fontSize: 15,
                                        fontFamily: 'ModernEra',
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          SizedBox(
                              width: double.infinity,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                        totalBalance(
                                            widget.arguments.transactionLevel,
                                            snapshot),
                                        style: TextStyle(
                                          color: HermezColors.black,
                                          fontSize: 32,
                                          fontFamily: 'ModernEra',
                                          fontWeight: FontWeight.w800,
                                        )),
                                  ])),
                          SizedBox(height: 16),
                          buildButtonsRow(context, snapshot),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                    backgroundColor: HermezColors.lightOrange,
                  ),
                ];
              },
            ),
          );
        },
      ),
    );
  }

  buildButtonsRow(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      // data loaded:
      _accounts = snapshot.data;
    }
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <
        Widget>[
      _accounts != null && _accounts.length > 0
          ? SizedBox(width: 20.0)
          : Container(),
      _accounts != null && _accounts.length > 0
          ? Expanded(
              child: FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  onPressed: () async {
                    List<Account> accounts = _accounts
                        .takeWhile(
                            (account) => double.parse(account.balance) > 0)
                        .toList();
                    Account account;
                    Token token;
                    PriceToken priceToken;
                    if (accounts.length == 1) {
                      account = accounts[0];
                      token = account.token.token;
                      /*widget.arguments.store.state.tokens
                          .firstWhere((token) => token.id == account.tokenId);*/
                      priceToken = account.token.price;
                      /*widget.arguments.store.state.priceTokens
                          .firstWhere(
                              (priceToken) => priceToken.id == account.tokenId);*/
                    }
                    var results = await Navigator.pushNamed(
                        widget.arguments.parentContext, "/transaction_amount",
                        arguments: TransactionAmountArguments(
                          //widget.arguments.store,
                          _settingsBloc.state.settings.level,
                          TransactionType.SEND,
                          account: account,
                          //token: token,
                          //priceToken: priceToken,
                        ));
                    if (results is PopWithResults) {
                      PopWithResults popResult = results;
                      if (popResult.toPage == "/home") {
                        _onRefresh();
                      } else {
                        Navigator.of(context).pop(results);
                      }
                    }
                  },
                  padding: EdgeInsets.all(10.0),
                  color: Colors.transparent,
                  textColor: HermezColors.blackTwo,
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 80,
                        height: 80,
                        child: SvgPicture.asset(
                          "assets/bt_send.svg",
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text(
                        'Send',
                        style: TextStyle(
                          color: HermezColors.blackTwo,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )),
            )
          : Container(),
      SizedBox(width: 20.0),
      Expanded(
        child:
            // takes in an object and color and returns a circle avatar with first letter and required color
            FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onPressed: () {
                  if (_settingsBloc.state.settings.level ==
                      TransactionLevel.LEVEL1) {
                    Navigator.of(widget.arguments.parentContext).pushNamed(
                      "/qrcode",
                      arguments: QRCodeArguments(
                          qrCodeType: QRCodeType.ETHEREUM,
                          code: _settingsBloc.state.settings.ethereumAddress,
                          //store: widget.arguments.store,
                          isReceive: true),
                    );
                  } else {
                    Navigator.of(widget.arguments.parentContext).pushNamed(
                      "/qrcode",
                      arguments: QRCodeArguments(
                          qrCodeType: QRCodeType.HERMEZ,
                          code: _settingsBloc.state.settings.hermezAddress,
                          //store: widget.arguments.store,
                          isReceive: true),
                    );
                  }
                },
                padding: EdgeInsets.all(10.0),
                color: Colors.transparent,
                textColor: HermezColors.blackTwo,
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 80,
                      height: 80,
                      child: SvgPicture.asset(
                        "assets/bt_receive.svg",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(
                      'Receive',
                      style: TextStyle(
                        color: HermezColors.blackTwo,
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )),
      ),
      SizedBox(width: 20.0),
    ]);
  }

  Widget handleAccountsList(AsyncSnapshot snapshot) {
    if (snapshot.connectionState != ConnectionState.done || _isLoading) {
      return Container(
        color: Colors.white,
        child: Center(
          child: CircularProgressIndicator(color: HermezColors.orange),
        ),
      );
    } else {
      if (snapshot.hasError) {
        // while data is loading:
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(34.0),
            child: Column(children: [
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
              SizedBox(height: 24),
              Center(
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    padding: EdgeInsets.only(
                        left: 23, right: 23, bottom: 16, top: 16),
                    backgroundColor: Color(0xfff3f3f8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    _onRefresh();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset('assets/reload.svg',
                          color: HermezColors.blueyGreyTwo,
                          semanticsLabel: 'reload'),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Reload',
                        style: TextStyle(
                          color: HermezColors.blueyGreyTwo,
                          fontSize: 16,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ]));
      } else {
        if (snapshot.hasData && (snapshot.data as List).length > 0) {
          // data loaded:
          _accounts = snapshot.data;
          return Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: buildAccountsList(),
                ),
                SafeArea(
                  top: false,
                  bottom: true,
                  child: Container(
                    //height: kBottomNavigationBarHeight,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(34.0),
              child: Column(children: [
                Text(
                  _settingsBloc.state.settings.level == TransactionLevel.LEVEL1
                      ? 'Transfer tokens to your \n\n Ethereum wallet.'
                      : 'Transfer tokens to your \n\n Hermez wallet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: HermezColors.blueyGrey,
                    fontSize: 16,
                    fontFamily: 'ModernEra',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 24),
                Center(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      padding: EdgeInsets.only(
                          left: 23, right: 23, bottom: 16, top: 16),
                      backgroundColor: Color(0xfff3f3f8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {
                      showBarModalBottomSheet(
                        context: widget.arguments.parentContext,
                        builder: (context) => Scaffold(
                          body: FutureBuilder(
                              future: fetchTokens(),
                              builder: (buildContext, snapshot) {
                                return handleTokensList(
                                    snapshot, widget.arguments.parentContext);
                              }),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'See supported tokens',
                          style: TextStyle(
                            color: HermezColors.blueyGreyTwo,
                            fontSize: 16,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ]));
        }
      }
    }
  }

  Future<List<Token>> fetchTokens() async {
    //return widget.arguments.store.getTokens();
  }

  Widget handleTokensList(AsyncSnapshot snapshot, BuildContext context) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
        child: CircularProgressIndicator(color: HermezColors.orange),
      );
    } else {
      if (snapshot.hasError) {
        // while data is loading:
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(34.0),
            child: Column(children: [
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
            ]));
      } else {
        if (snapshot.hasData && (snapshot.data as List).length > 0) {
          _tokens = snapshot.data;
          return buildTokensList(context);
        }
      }
    }
  }

  //widget that builds the list
  Widget buildTokensList(BuildContext parentContext) {
    return Column(
      children: [
        SizedBox(
          height: 30,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Supported tokens in Hermez',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: HermezColors.blackTwo,
                fontSize: 18,
                fontFamily: 'ModernEra',
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 16,
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.white,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _tokens.length,
              padding: const EdgeInsets.all(16.0),
              itemBuilder: (context, i) {
                final index = i;
                final String currency = _settingsBloc
                    .state.settings.defaultCurrency
                    .toString()
                    .split('.')
                    .last;
                final Token token = _tokens[index];
                /*final PriceToken priceToken = widget
                    .arguments.store.state.priceTokens
                    .firstWhere((priceToken) => priceToken.id == token.id);*/
                return TokenRow(
                    null, //token,
                    token.name,
                    token.symbol,
                    /*currency != "USD"
                        ? priceToken.USD *
                            widget.arguments.store.state.exchangeRatio
                        : priceToken.USD,*/
                    1,
                    currency,
                    0,
                    false,
                    true,
                    false,
                    null);
              },
            ),
          ),
        ),
      ],
    );
  }

  //widget that builds the list
  Widget buildAccountsList() {
    return Container(
      color: Colors.white,
      child: RefreshIndicator(
        color: HermezColors.orange,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _accounts.length +
              _pendingExits.length +
              _pendingForceExits.length +
              _filteredExits.length +
              _pendingWithdraws
                  .length /* + (_isLoading
                  ? 1
                  : 0)*/
          ,
          //set the item count so that index won't be out of range
          padding: const EdgeInsets.all(16.0),
          //add some padding to make it look good
          itemBuilder: (context, i) {
            if ((_pendingExits.length > 0 || _pendingForceExits.length > 0) &&
                i < _pendingExits.length + _pendingForceExits.length) {
              var index = i;
              Exit exit;
              if (i >= _pendingExits.length) {
                index = i - _pendingExits.length;
                var transaction = _pendingForceExits[index];
                exit = Exit.fromL1Transaction(transaction);
              } else {
                final PoolTransaction transaction = _pendingExits[index];
                exit = Exit.fromTransaction(transaction);
              }

              final String currency = _settingsBloc
                  .state.settings.defaultCurrency
                  .toString()
                  .split('.')
                  .last;

              /*final Token token = widget.arguments.store.state.tokens
                  .firstWhere((token) => token.id == exit.tokenId);
              final PriceToken priceToken = widget
                  .arguments.store.state.priceTokens
                  .firstWhere((priceToken) => priceToken.id == exit.tokenId);*/

              return WithdrawalRow(
                  exit,
                  null,
                  null,
                  /*token,
                  priceToken,*/
                  1,
                  currency,
                  1, //widget.arguments.store.state.exchangeRatio,
                  (bool completeDelayedWithdraw,
                      bool isInstantWithdraw) async {},
                  _settingsBloc.state.settings.level,
                  _stateResponse);
            } else if (_filteredExits.length > 0 &&
                i <
                    _filteredExits.length +
                        _pendingExits.length +
                        _pendingForceExits.length) {
              final index =
                  i - _pendingExits.length - _pendingForceExits.length;
              final Exit exit = _filteredExits[index];
              final bool isAllowed = _allowedInstantWithdraws[index];

              final String currency = _settingsBloc
                  .state.settings.defaultCurrency
                  .toString()
                  .split('.')
                  .last;

              /*final Token token = widget.arguments.store.state.tokens
                  .firstWhere((token) => token.id == exit.tokenId);
              final PriceToken priceToken = widget
                  .arguments.store.state.priceTokens
                  .firstWhere((priceToken) => priceToken.id == exit.tokenId);*/

              return WithdrawalRow(
                exit,
                null, null,
                /*token,
                priceToken,*/
                2,
                currency,
                1, //widget.arguments.store.state.exchangeRatio,
                (bool completeDelayedWithdraw,
                    bool instantWithdrawAllowed) async {
                  BigInt gasPrice = BigInt.one;
                  GasPriceResponse gasPriceResponse =
                      await _transferBloc.getGasPrice();
                  switch (_settingsBloc.state.settings.defaultFee) {
                    case WalletDefaultFee.SLOW:
                      int gasPriceFloor = gasPriceResponse.safeLow * pow(10, 8);
                      gasPrice = BigInt.from(gasPriceFloor);
                      break;
                    case WalletDefaultFee.AVERAGE:
                      int gasPriceFloor = gasPriceResponse.average * pow(10, 8);
                      gasPrice = BigInt.from(gasPriceFloor);
                      break;
                    case WalletDefaultFee.FAST:
                      int gasPriceFloor = gasPriceResponse.fast * pow(10, 8);
                      gasPrice = BigInt.from(gasPriceFloor);
                      break;
                  }
                  String addressFrom = exit.hezEthereumAddress;
                  String addressTo =
                      getCurrentEnvironment().contracts[ContractName.hermez];
                  final amountWithdraw = double.parse(exit.balance);
                  BigInt gasLimit = await _transferBloc.withdrawGasLimit(
                      amountWithdraw, exit,
                      completeDelayedWithdrawal: completeDelayedWithdraw,
                      instantWithdrawal: instantWithdrawAllowed);

                  var results =
                      await Navigator.of(widget.arguments.parentContext)
                          .pushNamed("/transaction_details",
                              arguments: TransactionDetailsArguments(
                                  //store: widget.arguments.store,
                                  transactionType: TransactionType.WITHDRAW,
                                  transactionLevel: TransactionLevel.LEVEL1,
                                  status: TransactionStatus.DRAFT,
                                  //token: token,
                                  //priceToken: priceToken,
                                  exit: exit,
                                  amount: amountWithdraw.toDouble() /
                                      pow(10, 18), //token.decimals),
                                  addressFrom: addressFrom,
                                  addressTo: addressTo,
                                  gasLimit: gasLimit.toInt(),
                                  gasPrice: gasPrice.toInt(),
                                  completeDelayedWithdrawal:
                                      completeDelayedWithdraw,
                                  instantWithdrawal: instantWithdrawAllowed));
                  if (results is PopWithResults) {
                    PopWithResults popResult = results;
                    if (popResult.toPage == "/home") {
                      // TODO do stuff
                      _onRefresh();
                    } else {
                      Navigator.of(context).pop(results);
                    }
                  }
                },
                _settingsBloc.state.settings.level,
                _stateResponse,
                instantWithdrawAllowed: isAllowed,
                completeDelayedWithdraw: false,
              );
            } else if (_pendingWithdraws.length > 0 &&
                i <
                    _pendingWithdraws.length +
                        _filteredExits.length +
                        _pendingExits.length +
                        _pendingForceExits.length) {
              final index = i -
                  _filteredExits.length -
                  _pendingExits.length -
                  _pendingForceExits.length;
              final pendingWithdraw = _pendingWithdraws[index];
              final int tokenId = pendingWithdraw['token']['id'];

              final Exit exit = _exits.firstWhere(
                  (exit) => exit.itemId == pendingWithdraw['itemId'],
                  orElse: () => Exit(
                      hezEthereumAddress:
                          pendingWithdraw['hermezEthereumAddress'],
                      delayedWithdrawRequest:
                          pendingWithdraw['instant'] == false
                              ? pendingWithdraw['blockNum']
                              : null,
                      tokenId: tokenId,
                      balance: pendingWithdraw['amount']
                          .toString()
                          .replaceAll('.0', '')));

              final bool isAllowed = pendingWithdraw['instant'];

              if (isAllowed == false) {
                if (exit.delayedWithdrawRequest == null) {
                  exit.delayedWithdrawRequest = pendingWithdraw['blockNum'];
                }
                exit.balance =
                    pendingWithdraw['amount'].toString().replaceAll('.0', '');
              }

              final String currency = _settingsBloc
                  .state.settings.defaultCurrency
                  .toString()
                  .split('.')
                  .last;

              int step = 2;
              if ((isAllowed == true &&
                      pendingWithdraw['status'] == 'pending') ||
                  (isAllowed == false &&
                      pendingWithdraw['status'] == 'completed')) {
                step = 3;
              } else if (pendingWithdraw['status'] == 'fail') {
                step = 2;
              }

              /*final Token token = widget.arguments.store.state.tokens
                  .firstWhere((token) => token.id == exit.tokenId);
              final PriceToken priceToken = widget
                  .arguments.store.state.priceTokens
                  .firstWhere((priceToken) => priceToken.id == exit.tokenId);*/

              return WithdrawalRow(
                exit,
                null, null,
                /*token,
                priceToken,*/
                step,
                currency,
                1, //widget.arguments.store.state.exchangeRatio,
                step == 2
                    ? (bool completeDelayedWithdraw,
                        bool instantWithdrawAllowed) async {
                        BigInt gasPrice = BigInt.one;
                        GasPriceResponse gasPriceResponse =
                            await _transferBloc.getGasPrice();
                        switch (_settingsBloc.state.settings.defaultFee) {
                          case WalletDefaultFee.SLOW:
                            int gasPriceFloor =
                                gasPriceResponse.safeLow * pow(10, 8);
                            gasPrice = BigInt.from(gasPriceFloor);
                            break;
                          case WalletDefaultFee.AVERAGE:
                            int gasPriceFloor =
                                gasPriceResponse.average * pow(10, 8);
                            gasPrice = BigInt.from(gasPriceFloor);
                            break;
                          case WalletDefaultFee.FAST:
                            int gasPriceFloor =
                                gasPriceResponse.fast * pow(10, 8);
                            gasPrice = BigInt.from(gasPriceFloor);
                            break;
                        }

                        String addressFrom = exit.hezEthereumAddress;
                        String addressTo = getCurrentEnvironment()
                            .contracts[ContractName.hermez];

                        BigInt gasLimit = BigInt.from(GAS_LIMIT_HIGH);
                        final amountWithdraw = double.parse(exit.balance);
                        try {
                          gasLimit = await _transferBloc.withdrawGasLimit(
                              amountWithdraw, exit,
                              completeDelayedWithdrawal:
                                  completeDelayedWithdraw,
                              instantWithdrawal: instantWithdrawAllowed);
                        } catch (e) {
                          // default withdraw gas: 230K + STANDARD ERC20 TRANSFER + (siblings.length * 31K)
                          gasLimit = BigInt.from(GAS_LIMIT_WITHDRAW_DEFAULT);
                          exit.merkleProof.siblings.forEach((element) {
                            gasLimit += BigInt.from(GAS_LIMIT_WITHDRAW_SIBLING);
                          });
                          if (exit.tokenId != 0) {
                            gasLimit +=
                                BigInt.from(GAS_LIMIT_WITHDRAW_ERC20_TX);
                          }
                        }

                        var results = await Navigator.of(
                                widget.arguments.parentContext)
                            .pushNamed("/transaction_details",
                                arguments: TransactionDetailsArguments(
                                    //store: widget.arguments.store,
                                    transactionType: TransactionType.WITHDRAW,
                                    transactionLevel: TransactionLevel.LEVEL1,
                                    status: TransactionStatus.DRAFT,
                                    //token: token,
                                    //priceToken: priceToken,
                                    exit: exit,
                                    amount: amountWithdraw.toDouble() /
                                        pow(10, 18), //token.decimals),
                                    addressFrom: addressFrom,
                                    addressTo: addressTo,
                                    gasLimit: gasLimit.toInt(),
                                    gasPrice: gasPrice.toInt(),
                                    instantWithdrawal: instantWithdrawAllowed,
                                    completeDelayedWithdrawal:
                                        completeDelayedWithdraw));
                        if (results is PopWithResults) {
                          PopWithResults popResult = results;
                          if (popResult.toPage == "/home") {
                            _onRefresh();
                          } else {
                            Navigator.of(context).pop(results);
                          }
                        }
                      }
                    : (bool completeDelayedWithdraw,
                        bool instantWithdrawAllowed) {},
                _settingsBloc.state.settings.level,
                _stateResponse,
                retry: pendingWithdraw['status'] == 'fail',
                instantWithdrawAllowed: isAllowed == true,
                completeDelayedWithdraw: isAllowed == false,
              );
            } // final index = i ~/ 2; //get the actual index excluding dividers.
            else {
              final index = i -
                  _pendingExits.length -
                  _pendingForceExits.length -
                  _filteredExits.length -
                  _pendingWithdraws.length;
              final Account account = _accounts[index];
              final Token token = account.token.token;
              /*widget.arguments.store.state.tokens
                  .firstWhere((token) => token.id == account.tokenId);*/
              final PriceToken priceToken = account.token.price;
              /* widget
                  .arguments.store.state.priceTokens
                  .firstWhere((priceToken) => priceToken.id == account.tokenId);*/

              final String currency = _settingsBloc
                  .state.settings.defaultCurrency
                  .toString()
                  .split('.')
                  .last;

              var isPendingDeposit = false;
              if (account.accountIndex == null) {
                isPendingDeposit = true;
              }
              _pendingDeposits.forEach((pendingDeposit) {
                if (account.token.token.id == (pendingDeposit['token'])['id']) {
                  isPendingDeposit = true;
                }
              });

              return AccountRow(
                  account,
                  //token,
                  token.name,
                  token.symbol,
                  /*currency != "USD"
                      ? priceToken.USD *
                          widget.arguments.store.state.exchangeRatio
                      :*/
                  priceToken.USD,
                  currency,
                  BalanceUtils.calculatePendingBalance(
                        widget.arguments.transactionLevel,
                        account,
                        token.symbol,
                        /*widget.arguments.store*/
                      ) /
                      pow(10, token.decimals),
                  false,
                  true,
                  isPendingDeposit,
                  false, (Account account, tokenId, amount) async {
                if (account.accountIndex == null) {
                  Flushbar(
                    messageText: Text(
                      'This account is being created',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: HermezColors.blackTwo,
                        fontSize: 16,
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    boxShadows: [
                      BoxShadow(
                        color: HermezColors.blueyGreyTwo.withAlpha(64),
                        offset: Offset(0, 4),
                        blurRadius: 16,
                        spreadRadius: 0,
                      ),
                    ],
                    borderColor: HermezColors.blueyGreyTwo.withAlpha(64),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    backgroundColor: Colors.white,
                    margin: EdgeInsets.all(16.0),
                    duration: Duration(seconds: FLUSHBAR_AUTO_HIDE_DURATION),
                  ).show(context);
                } else {
                  var needRefresh =
                      await Navigator.of(context).pushNamed("account_details",
                          arguments: AccountDetailsArguments(
                              //widget.arguments.store,
                              widget.arguments.transactionLevel,
                              account,
                              //token,
                              //priceToken,
                              widget.arguments.parentContext));
                  if (needRefresh != null && needRefresh == true) {
                    _onRefresh();
                  } else {
                    setState(() {});
                  }
                }
              }); //iterate through indexes and get the next colour
            }
          },
        ),
        onRefresh: _onRefresh,
      ),
      /*),*/
    );
  }

  String totalBalance(TransactionLevel txLevel, AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      // data loaded:
      _accounts = snapshot.data;
    }
    double resultValue = 0;
    String result = "";
    String locale = "";
    String symbol = "";
    final String currency =
        _settingsBloc.state.settings.defaultCurrency.toString().split('.').last;
    if (currency == "EUR") {
      locale = 'eu';
      symbol = '€';
    } else if (currency == "CNY") {
      locale = 'en';
      symbol = '\¥';
    } else if (currency == "JPY") {
      locale = 'en';
      symbol = "\¥";
    } else if (currency == "GBP") {
      locale = 'en';
      symbol = "\£";
    } else {
      locale = 'en';
      symbol = '\$';
    }

    result = BalanceUtils.balanceOfAccounts(
        txLevel,
        _accounts,
        //widget.arguments.store,
        currency,
        1, //widget.arguments.store.state.exchangeRatio,
        [], // pendingWithdraws
        []); //widget.arguments.store.state.pendingDeposits);
    /*if (_accounts != null && _accounts.length > 0) {
      for (Account account in _accounts) {
        if (account.token.USD != null) {
          double value = account.token.USD * double.parse(account.balance);
          if (currency != "USD") {
            value *= widget.arguments.store.state.exchangeRatio;
          }
          resultValue += value;
        }
      }
    }
    //result += (resultValue / pow(10, 18)).toStringAsFixed(2);
    result = NumberFormat.currency(locale: locale, symbol: symbol)
        .format(resultValue / pow(10, 18));*/
    return result;
  }
}