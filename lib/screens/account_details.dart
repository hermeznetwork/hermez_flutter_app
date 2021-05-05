import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hermez/components/wallet/activity.dart';
import 'package:hermez/screens/qrcode.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez/utils/eth_amount_formatter.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_plugin/addresses.dart';
import 'package:hermez_plugin/model/account.dart';
import 'package:intl/intl.dart';

import '../context/wallet/wallet_handler.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class AccountDetailsArguments {
  WalletHandler store;
  final Account account;
  BuildContext parentContext;

  AccountDetailsArguments(this.store, this.account, this.parentContext);
}

class AccountDetailsPage extends StatefulWidget {
  AccountDetailsPage({Key key, this.arguments}) : super(key: key);

  final AccountDetailsArguments arguments;

  @override
  _AccountDetailsPageState createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  GlobalKey<ActivityState> _myKey = GlobalKey();
  void _onRefresh() {
    _myKey.currentState.onRefresh();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(child: getActivity()),
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
      ),
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            floating: true,
            pinned: true,
            snap: false,
            collapsedHeight: kToolbarHeight,
            expandedHeight: 340.0,
            backgroundColor: HermezColors.lightOrange,
            elevation: 0,
            title: Container(
              padding: EdgeInsets.only(bottom: 20, top: 20),
              color: HermezColors.lightOrange,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(widget.arguments.account.token.name, // name
                          style: TextStyle(
                              fontFamily: 'ModernEra',
                              color: HermezColors.blackTwo,
                              fontWeight: FontWeight.w800,
                              fontSize: 20))
                    ],
                  )),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        color: HermezColors.steel),
                    padding: EdgeInsets.only(
                        left: 12.0, right: 12.0, top: 4, bottom: 4),
                    child: Text(
                      widget.arguments.store.state.txLevel ==
                              TransactionLevel.LEVEL1
                          ? "L1"
                          : "L2",
                      style: TextStyle(
                        color: HermezColors.lightOrange,
                        fontSize: 15,
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              // here the desired height*/
              background: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                      height: MediaQuery.of(context).padding.top +
                          kToolbarHeight +
                          40),
                  SizedBox(
                      width: double.infinity,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                                formatAmount(
                                    double.parse(
                                            widget.arguments.account.balance) /
                                        pow(
                                            10,
                                            widget.arguments.account.token
                                                .decimals),
                                    widget.arguments.account.token.symbol),
                                style: TextStyle(
                                    color: HermezColors.blackTwo,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 32)),
                          ])),
                  SizedBox(height: 10),
                  Text(accountBalance(),
                      style: TextStyle(
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w500,
                          color: HermezColors.steel,
                          fontSize: 18)),
                  SizedBox(height: 30),
                  buildButtonsRow(context),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ];
      },
    ));
  }

  buildButtonsRow(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(width: 20.0),
          Expanded(
            child:
                // takes in an object and color and returns a circle avatar with first letter and required color
                FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        widget.arguments.parentContext,
                        "/transaction_amount",
                        arguments: TransactionAmountArguments(
                            widget.arguments.store,
                            widget.arguments.store.state.txLevel,
                            TransactionType.SEND,
                            account: widget.arguments.account,
                            allowChangeLevel: false),
                      ).then((value) => _onRefresh());
                    },
                    padding: EdgeInsets.all(10.0),
                    color: Colors.transparent,
                    textColor: HermezColors.blackTwo,
                    child: Column(
                      children: <Widget>[
                        Image.asset("assets/send2.png"),
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
          ),
          Expanded(
            child:
                // takes in an object and color and returns a circle avatar with first letter and required color
                FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    onPressed: () {
                      widget.arguments.store.state.txLevel ==
                              TransactionLevel.LEVEL1
                          ? Navigator.of(widget.arguments.parentContext)
                              .pushNamed(
                                "/qrcode",
                                arguments: QRCodeArguments(
                                    qrCodeType: QRCodeType.ETHEREUM,
                                    code: widget
                                        .arguments.store.state.ethereumAddress,
                                    store: widget.arguments.store,
                                    isReceive: true),
                              )
                              .then((value) => _onRefresh())
                          : Navigator.of(widget.arguments.parentContext)
                              .pushNamed(
                                "/qrcode",
                                arguments: QRCodeArguments(
                                    qrCodeType: QRCodeType.HERMEZ,
                                    code: getHermezAddress(widget
                                        .arguments.store.state.ethereumAddress),
                                    store: widget.arguments.store,
                                    isReceive: true),
                              )
                              .then((value) => _onRefresh());
                    },
                    padding: EdgeInsets.all(10.0),
                    color: Colors.transparent,
                    textColor: HermezColors.blackTwo,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 5,
                        ),
                        Image.asset("assets/receive2.png"),
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
          Expanded(
            child:
                // takes in an object and color and returns a circle avatar with first letter and required color
                FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        widget.arguments.parentContext,
                        "/transaction_amount",
                        arguments: TransactionAmountArguments(
                            widget.arguments.store,
                            widget.arguments.store.state.txLevel,
                            widget.arguments.store.state.txLevel ==
                                    TransactionLevel.LEVEL1
                                ? TransactionType.DEPOSIT
                                : TransactionType.EXIT,
                            account: widget.arguments.account,
                            allowChangeLevel: false),
                      ).then((value) => _onRefresh());
                    },
                    padding: EdgeInsets.all(10.0),
                    color: Colors.transparent,
                    textColor: HermezColors.blackTwo,
                    child: Column(
                      children: <Widget>[
                        Image.asset("assets/move2.png"),
                        Text(
                          'Move',
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

  String formatAmount(double amount, String symbol) {
    double resultValue = 0;
    String result = "";
    String locale = "eu";
    bool isCurrency = false;
    if (symbol == "EUR") {
      locale = 'eu';
      symbol = '€';
      isCurrency = true;
    } else if (symbol == "CNY") {
      locale = 'en';
      symbol = '\¥';
      isCurrency = true;
    } else if (symbol == "USD") {
      locale = 'en';
      symbol = '\$';
      isCurrency = true;
    }
    if (amount != null) {
      double value = amount;
      resultValue += value;
    }
    resultValue =
        double.parse(EthAmountFormatter.removeDecimalZeroFormat(resultValue));
    result = NumberFormat.currency(
            locale: locale,
            symbol: symbol,
            decimalDigits: resultValue % 1 == 0
                ? 0
                : isCurrency
                    ? 2
                    : 6)
        .format(resultValue);
    return result;
  }

  String accountBalance() {
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
    if (widget.arguments.account.token.USD != null) {
      double value = widget.arguments.account.token.USD *
          double.parse(widget.arguments.account.balance);
      if (currency != "USD") {
        value *= widget.arguments.store.state.exchangeRatio;
      }
      resultValue = resultValue + value;
    }
    //result += (resultValue / pow(10, 18)).toStringAsFixed(2);
    result = NumberFormat.currency(locale: locale, symbol: symbol)
        .format(resultValue / pow(10, 18));
    return result;
  }

  void fetchState() {
    widget.arguments.store.getState();
  }

  Activity getActivity() {
    final String currency =
        widget.arguments.store.state.defaultCurrency.toString().split('.').last;
    return Activity(
      key: _myKey,
      arguments: ActivityArguments(
          widget.arguments.store,
          widget.arguments.account,
          widget.arguments.store.state.ethereumAddress,
          widget.arguments.account.token.symbol,
          currency == "USD"
              ? widget.arguments.account.token.USD
              : widget.arguments.account.token.USD *
                  widget.arguments.store.state.exchangeRatio,
          widget.arguments.store.state.defaultCurrency,
          widget.arguments.parentContext),
    );
  }
}
