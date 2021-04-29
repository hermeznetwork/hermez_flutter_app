import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/components/wallet/activity.dart';
import 'package:hermez/screens/qrcode.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_plugin/addresses.dart';
import 'package:hermez_plugin/model/account.dart';
import 'package:intl/intl.dart';

import '../context/wallet/wallet_handler.dart';
import '../context/wallet/wallet_provider.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class AccountDetailsArguments {
  final Account element;
  BuildContext parentContext;
  //WalletHandler store;

  AccountDetailsArguments(this.element, this.parentContext
      /*this.store*/
      );
}

class AccountDetailsPage extends HookWidget {
  AccountDetailsPage(this.arguments);
  final AccountDetailsArguments arguments;

  WalletHandler store;

  @override
  Widget build(BuildContext context) {
    store = useWallet(context);

    useEffect(() {
      store.initialise();
      return null;
    }, [store]);

    final String currency =
        store.state.defaultCurrency.toString().split('.').last;
    return Scaffold(
        body: NestedScrollView(
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Activity(
                arguments: ActivityArguments(
                    store,
                    arguments.element,
                    store.state.ethereumAddress,
                    arguments.element.token.symbol,
                    currency == "USD"
                        ? arguments.element.token.USD
                        : arguments.element.token.USD *
                            store.state.exchangeRatio,
                    store.state.defaultCurrency,
                    arguments.parentContext),
              ),
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
                      Text(arguments.element.token.name, // name
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
                      store.state.txLevel == TransactionLevel.LEVEL1
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
                                    double.parse(arguments.element.balance) /
                                        pow(10, 18),
                                    arguments.element.token.symbol),
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
                        arguments.parentContext,
                        "/transaction_amount",
                        arguments: TransactionAmountArguments(
                            store, store.state.txLevel, TransactionType.SEND,
                            account: arguments.element,
                            allowChangeLevel: false),
                      );
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
                      store.state.txLevel == TransactionLevel.LEVEL1
                          ? Navigator.of(arguments.parentContext).pushNamed(
                              "/qrcode",
                              arguments: QRCodeArguments(
                                  qrCodeType: QRCodeType.ETHEREUM,
                                  code: store.state.ethereumAddress,
                                  store: store,
                                  isReceive: true),
                            )
                          : Navigator.of(arguments.parentContext).pushNamed(
                              "/qrcode",
                              arguments: QRCodeArguments(
                                  qrCodeType: QRCodeType.HERMEZ,
                                  code: getHermezAddress(
                                      store.state.ethereumAddress),
                                  store: store,
                                  isReceive: true),
                            );
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
                        arguments.parentContext,
                        "/transaction_amount",
                        arguments: TransactionAmountArguments(
                            store,
                            store.state.txLevel,
                            store.state.txLevel == TransactionLevel.LEVEL1
                                ? TransactionType.DEPOSIT
                                : TransactionType.EXIT,
                            account: arguments.element,
                            allowChangeLevel: false),
                      );
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
    String locale = "";
    locale = 'eu';
    if (amount != null) {
      double value = amount;
      resultValue = resultValue + value;
    }
    result =
        NumberFormat.currency(locale: locale, symbol: symbol).format(amount);
    return result;
  }

  String accountBalance() {
    double resultValue = 0;
    String result = "";
    String locale = "";
    String symbol = "";
    final String currency =
        store.state.defaultCurrency.toString().split('.').last;
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
    if (arguments.element.token.USD != null) {
      double value =
          arguments.element.token.USD * double.parse(arguments.element.balance);
      if (currency != "USD") {
        value *= store.state.exchangeRatio;
      }
      resultValue = resultValue + value;
    }
    //result += (resultValue / pow(10, 18)).toStringAsFixed(2);
    result = NumberFormat.currency(locale: locale, symbol: symbol)
        .format(resultValue / pow(10, 18));
    return result;
  }

  void fetchState() {
    store.getState();
  }
}
