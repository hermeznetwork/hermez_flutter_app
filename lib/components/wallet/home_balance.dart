import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hermez/components/wallet/account_row.dart';
import 'package:hermez/components/wallet/withdrawal_row.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/screens/settings_qrcode.dart';
import 'package:hermez/utils/address_utils.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/wallet_account_details_page.dart';
import 'package:hermez/wallet_account_selector_page.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';
import 'package:hermez_plugin/addresses.dart';
import 'package:hermez_plugin/model/account.dart';
import 'package:hermez_plugin/model/exit.dart';
import 'package:hermez_plugin/model/pool_transaction.dart';
import 'package:hermez_plugin/model/token.dart';
import 'package:intl/intl.dart';

import '../../wallet_transaction_details_page.dart';

class HomeBalanceArguments {
  final WalletHandler store;
  final TransactionLevel transactionLevel;
  final BuildContext parentContext;

  HomeBalanceArguments(this.store, this.transactionLevel, this.parentContext);
}

class HomeBalance extends StatefulWidget {
  HomeBalance({Key key, this.arguments}) : super(key: key);

  final HomeBalanceArguments arguments;

  @override
  _HomeBalanceState createState() => _HomeBalanceState();
}

class _HomeBalanceState extends State<HomeBalance> {
  List<Account> _accounts;
  List<Exit> _exits = [];
  List<dynamic> _poolTxs = [];
  List<dynamic> _pendingWithdraws = [];
  List<dynamic> _pendingDeposits = [];

  @override
  void initState() {
    //fetchAccounts();
    super.initState();
  }

  Future<void> _onRefresh() async {
    setState(() {});
  }

  Future<List<Account>> fetchAccounts() async {
    if (widget.arguments.store.state.txLevel == TransactionLevel.LEVEL2) {
      /*const accountPendingDeposits = storage.getItemsByHermezAddress(
          pendingDeposits,
          ethereumNetworkTask.data.chainId,
          wallet.hermezEthereumAddress
      )*/

      /*const accountPendingDelayedWithdraws = storage.getItemsByHermezAddress(
          pendingDelayedWithdraws,
          ethereumNetworkTask.data.chainId,
          wallet.hermezEthereumAddress
      )
      const pendingOnTopDeposits = accountPendingDeposits
          .filter(deposit => deposit.type === TxType.Deposit)
      const pendingCreateAccountDeposits = accountPendingDeposits
          .filter(deposit => deposit.type === TxType.CreateAccountDeposit)*/

      try {
        _poolTxs = await fetchPendingExits();
      } catch (e) {}
      _exits = await fetchExits();
      _pendingWithdraws = await fetchPendingWithdraws();
      _pendingDeposits = await fetchPendingDeposits();

      return widget.arguments.store.getAccounts();
    } else {
      return widget.arguments.store.getL1Accounts();
    }
  }

  Future<List<dynamic>> fetchPendingExits() async {
    List<PoolTransaction> poolTxs =
        await widget.arguments.store.getPoolTransactions();
    poolTxs.removeWhere((transaction) => transaction.type != 'Exit');
    return poolTxs;
  }

  Future<List<Exit>> fetchExits() {
    return widget.arguments.store.getExits(); // TODO : only pending withdraws?
  }

  Future<List<dynamic>> fetchPendingWithdraws() {
    return widget.arguments.store.getPendingWithdraws();
  }

  Future<List<dynamic>> fetchPendingDeposits() {
    return widget.arguments.store.getPendingDeposits();
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
                              (widget.arguments.store.state.txLevel ==
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
                            widget.arguments.store.state.txLevel ==
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
                  /*Container(
                    color: HermezColors.lightOrange,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        /*Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ToggleButtons(
                                children: <Widget>[
                                  Text(
                                    "L1",
                                    style: TextStyle(
                                        fontFamily: 'ModernEra',
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20),
                                  ),
                                  Text(
                                    "L2",
                                    style: TextStyle(
                                        fontFamily: 'ModernEra',
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20),
                                  ),
                                ],
                                fillColor: Color.fromRGBO(51, 51, 51, 1.0),
                                selectedColor:
                                    Color.fromRGBO(249, 244, 235, 1.0),
                                borderRadius: BorderRadius.circular(8.0),
                                borderColor: Color.fromRGBO(51, 51, 51, 1.0),
                                selectedBorderColor:
                                    Color.fromRGBO(51, 51, 51, 1.0),
                                borderWidth: 2,
                                isSelected: [
                                  widget.arguments.store.state.txLevel ==
                                      TransactionLevel.LEVEL1,
                                  widget.arguments.store.state.txLevel ==
                                      TransactionLevel.LEVEL2
                                ],
                                onPressed: (int index) {
                                  setState(() {
                                    widget.arguments.store.updateLevel(
                                        index == 1
                                            ? TransactionLevel.LEVEL2
                                            : TransactionLevel.LEVEL1);
                                    //index == 1 ? _accounts = [] : fetchAccounts();
                                  });
                                },
                              )
                            ],
                          ),
                        ),*/
                      ],
                    ),
                  ),*/
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
                                  text: widget.arguments.store.state.txLevel ==
                                          TransactionLevel.LEVEL1
                                      ? widget
                                          .arguments.store.state.ethereumAddress
                                      : "hez:" +
                                          widget.arguments.store.state
                                              .ethereumAddress));
                              final snackBar =
                                  SnackBar(content: Text('Copied'));
                              ScaffoldMessenger.of(
                                      widget.arguments.parentContext)
                                  .showSnackBar(snackBar);
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
                                  widget != null && widget.arguments != null && widget.arguments.store.state.ethereumAddress != null
                                      ? (widget.arguments.store.state.txLevel == TransactionLevel.LEVEL1
                                          ? "0x" +
                                                  AddressUtils.strip0x(widget.arguments.store.state.ethereumAddress.substring(0, 6))
                                                      .toUpperCase() +
                                                  " ･･･ " +
                                                  widget.arguments.store.state.ethereumAddress
                                                      .substring(
                                                          widget
                                                                  .arguments
                                                                  .store
                                                                  .state
                                                                  .ethereumAddress
                                                                  .length -
                                                              5,
                                                          widget
                                                              .arguments
                                                              .store
                                                              .state
                                                              .ethereumAddress
                                                              .length)
                                                      .toUpperCase() ??
                                              ""
                                          : "hez:" +
                                                  "0x" +
                                                  AddressUtils.strip0x(widget.arguments.store.state.ethereumAddress.substring(0, 6))
                                                      .toUpperCase() +
                                                  " ･･･ " +
                                                  widget.arguments.store.state.ethereumAddress
                                                      .substring(widget.arguments.store.state.ethereumAddress.length - 5, widget.arguments.store.state.ethereumAddress.length)
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
                                      borderRadius: BorderRadius.circular(16.0),
                                      color: HermezColors.steel),
                                  padding: EdgeInsets.only(
                                      left: 12.0,
                                      right: 12.0,
                                      top: 4,
                                      bottom: 4),
                                  child: Text(
                                    widget.arguments.store.state.txLevel ==
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
                                      widget.arguments.store.state.txLevel ==
                                              TransactionLevel.LEVEL1
                                          ? totalBalance(snapshot)
                                          : totalBalance(snapshot),
                                      //"\$${EthAmountFormatter(tokenBalance).format()}",
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

                  //collapsedHeight: 100.0,
                  /*flexibleSpace: FlexibleSpaceBar(
                  title: Text('Collapsing Header'),
                ),*/
                  backgroundColor: HermezColors.lightOrange,
                ),
              ];
            },
          ));
        },
      ),
    );
  }

  buildButtonsRow(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      // data loaded:
      _accounts = snapshot.data;
    }
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _accounts != null && _accounts.length > 0
              ? SizedBox(width: 20.0)
              : Container(),
          _accounts != null && _accounts.length > 0
              ? Expanded(
                  child:
                      // takes in an object and color and returns a circle avatar with first letter and required color
                      FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          onPressed: () async {
                            if (_accounts.length > 1) {
                              Navigator.of(widget.arguments.parentContext)
                                  .pushNamed("/account_selector",
                                      arguments: AccountSelectorArguments(
                                        widget.arguments.store.state.txLevel,
                                        TransactionType.SEND,
                                        widget.arguments.store,
                                      ));
                            } else {
                              Navigator.pushNamed(
                                  widget.arguments.parentContext,
                                  "/transfer_amount",
                                  arguments: AmountArguments(
                                      widget.arguments.store,
                                      widget.arguments.store.state.txLevel,
                                      TransactionType.SEND,
                                      _accounts[0]));
                            }
                          },
                          padding: EdgeInsets.all(10.0),
                          color: Colors.transparent,
                          textColor: HermezColors.blackTwo,
                          child: Column(
                            children: <Widget>[
                              Image.asset(
                                "assets/send2.png",
                                width: 80,
                                height: 80,
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
                      if (widget.arguments.store.state.txLevel ==
                          TransactionLevel.LEVEL1) {
                        Navigator.of(widget.arguments.parentContext).pushNamed(
                            "/settings_qrcode",
                            arguments: SettingsQRCodeArguments(
                                message: widget
                                    .arguments.store.state.ethereumAddress,
                                store: widget.arguments.store,
                                fromHomeScreen: false));
                      } else {
                        Navigator.of(widget.arguments.parentContext).pushNamed(
                            "/settings_qrcode",
                            arguments: SettingsQRCodeArguments(
                                message: getHermezAddress(widget
                                    .arguments.store.state.ethereumAddress),
                                store: widget.arguments.store,
                                fromHomeScreen: false));
                        /*Navigator.of(widget.arguments.parentContext)
                            .pushNamed("/account_selector",
                                arguments: AccountSelectorArguments(
                                  //widget.arguments.store.state.txLevel,
                                  TransactionType.DEPOSIT,
                                  widget.arguments.store,
                                ));*/
                      }
                    },
                    padding: EdgeInsets.all(10.0),
                    color: Colors.transparent,
                    textColor: HermezColors.blackTwo,
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          "assets/receive2.png",
                          width: 80,
                          height: 80,
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
          /*_accounts != null &&
                  _accounts.length > 0 &&
                  widget.arguments.store.state.txLevel ==
                      TransactionLevel.LEVEL2 &&
                  _exits.length == 0
              ? Expanded(
                  child:
                      // takes in an object and color and returns a circle avatar with first letter and required color
                      FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          onPressed: () async {
                            Navigator.of(context).pushNamed("/account_selector",
                                arguments: AccountSelectorArguments(
                                  //widget.arguments.store.state.txLevel,
                                  TransactionType.EXIT,
                                  widget.arguments.store,
                                ));
                          },
                          padding: EdgeInsets.all(10.0),
                          color: Colors.transparent,
                          textColor: HermezColors.blackTwo,
                          child: Column(
                            children: <Widget>[
                              Image.asset("assets/withdraw2.png"),
                              Text(
                                'Withdraw',
                                style: TextStyle(
                                  color: HermezColors.blackTwo,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )),
                )
              : Container(),*/
          /*_accounts != null &&
                  _accounts.length > 0 &&
                  widget.arguments.store.state.txLevel ==
                      TransactionLevel.LEVEL2 &&
                  _exits.length == 0
              ? SizedBox(width: 20.0)
              : Container(),*/
        ]);
  }

  Widget handleAccountsList(AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    } else {
      if (snapshot.hasError) {
        // while data is loading:
        return Container(
          color: Colors.white,
          child: Center(
            child: Text('There was an error:' + snapshot.error.toString()),
          ),
        );
      } else {
        if (snapshot.hasData && (snapshot.data as List).length > 0) {
          // data loaded:
          _accounts = snapshot.data;
          buildAccountsList();
        } else {
          return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(34.0),
              child: Text(
                widget.arguments.store.state.txLevel == TransactionLevel.LEVEL1
                    ? 'There are no tokens in this account. \n\n Please make a deposit.'
                    : 'Deposit tokens from your \n\n Ethereum account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: HermezColors.blueyGrey,
                  fontSize: 16,
                  fontFamily: 'ModernEra',
                  fontWeight: FontWeight.w500,
                ),
              ));
        }
      }
    }

    return buildAccountsList();
  }

  //widget that builds the list
  Widget buildAccountsList() {
    return Container(
      color: Colors.white,
      child: RefreshIndicator(
        child: ListView.builder(
          shrinkWrap: true,
          // To make listView scrollable
          // even if there is only a single item.
          //physics: const AlwaysScrollableScrollPhysics(),
          itemCount: (_poolTxs.isNotEmpty ||
                      _exits.isNotEmpty ||
                      _pendingWithdraws.isNotEmpty
                  ? 1
                  : 0) +
              _accounts.length,
          //set the item count so that index won't be out of range
          padding: const EdgeInsets.all(16.0),
          //add some padding to make it look good
          itemBuilder: (context, i) {
            //item builder returns a row for each index i=0,1,2,3,4
            // if (i.isOdd) return Divider(); //if index = 1,3,5 ... return a divider to make it visually appealing

            if (i == 0 && _pendingWithdraws.length > 0) {
              final index = i;
              final Token token =
                  Token.fromJson(_pendingWithdraws[index]['token']);

              final Exit exit = Exit(
                  hezEthereumAddress: _pendingWithdraws[index]
                      ['hermezEthereumAddress'],
                  token: token,
                  balance: _pendingWithdraws[index]['amount']
                      .toString()
                      .replaceAll('.0', ''));

              final String currency = widget
                  .arguments.store.state.defaultCurrency
                  .toString()
                  .split('.')
                  .last;

              return WithdrawalRow(exit, 3, currency,
                  widget.arguments.store.state.exchangeRatio, () {});
            } else if (i == 0 && _exits.length > 0) {
              final index = i;
              final Exit exit = _exits[index];

              final String currency = widget
                  .arguments.store.state.defaultCurrency
                  .toString()
                  .split('.')
                  .last;

              return WithdrawalRow(
                  exit, 2, currency, widget.arguments.store.state.exchangeRatio,
                  () async {
                Navigator.of(widget.arguments.parentContext)
                    .pushNamed("/transaction_details",
                        arguments: TransactionDetailsArguments(
                          wallet: widget.arguments.store,
                          transactionType: TransactionType.WITHDRAW,
                          status: TransactionStatus.DRAFT,
                          token: exit.token,
                          //account: widget.arguments.account,
                          exit: exit,
                          amount: double.parse(exit.balance) /
                              pow(10, exit.token.decimals),
                          addressFrom: exit.hezEthereumAddress,
                          //addressTo: address,
                        ));
              });
            } // final index = i ~/ 2; //get the actual index excluding dividers.
            else if (i == 0 && _poolTxs.length > 0 && i < _poolTxs.length) {
              final index = i;
              final PoolTransaction transaction = _poolTxs[index];

              final Exit exit = Exit.fromTransaction(transaction);

              final String currency = widget
                  .arguments.store.state.defaultCurrency
                  .toString()
                  .split('.')
                  .last;

              return WithdrawalRow(exit, 1, currency,
                  widget.arguments.store.state.exchangeRatio, () async {});
            } else {
              final index = i -
                  (_poolTxs.isNotEmpty ||
                          _exits.isNotEmpty ||
                          _pendingWithdraws.isNotEmpty
                      ? 1
                      : 0);
              final Account account = _accounts[index];

              final String currency = widget
                  .arguments.store.state.defaultCurrency
                  .toString()
                  .split('.')
                  .last;

              var isPendingDeposit = false;
              _pendingDeposits.forEach((pendingDeposit) {
                if (account.token.id == (pendingDeposit['token'])['id']) {
                  isPendingDeposit = true;
                }
              });

              return AccountRow(
                  account.token.name,
                  account.token.symbol,
                  currency != "USD"
                      ? account.token.USD *
                          widget.arguments.store.state.exchangeRatio
                      : account.token.USD,
                  currency,
                  double.parse(account.balance) /
                      pow(10, account.token.decimals),
                  false,
                  true,
                  isPendingDeposit, (token, amount) async {
                Navigator.of(context)
                    .pushNamed("account_details",
                        arguments: WalletAccountDetailsArguments(
                            account, widget.arguments.parentContext))
                    .then((value) => _onRefresh());
              }); //iterate through indexes and get the next colour
            }
            //return _buildRow(context, element, color); //build the row widget
          },
        ),
        onRefresh: _onRefresh,
      ),
      /*),*/
    );
  }

  String totalBalance(AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      // data loaded:
      _accounts = snapshot.data;
    }
    double resultValue = 0;
    String result = "";
    String locale = "";
    String symbol = "";
    final String currency =
        widget.arguments.store.state.defaultCurrency.toString().split('.').last;
    if (currency == "EUR") {
      locale = 'eu';
      symbol = '€';
    } else if (currency == "CNY") {
      locale = 'en';
      symbol = '\¥';
    } else {
      locale = 'en';
      symbol = '\$';
    }
    if (_accounts != null && _accounts.length > 0) {
      for (Account account in _accounts) {
        if (account.token.USD != null) {
          double value = account.token.USD * double.parse(account.balance);
          if (currency != "USD") {
            value *= widget.arguments.store.state.exchangeRatio;
          }
          resultValue = resultValue + value;
        }
      }
    }
    //result += (resultValue / pow(10, 18)).toStringAsFixed(2);
    result = NumberFormat.currency(locale: locale, symbol: symbol)
        .format(resultValue / pow(10, 18));
    return result;
  }
}
