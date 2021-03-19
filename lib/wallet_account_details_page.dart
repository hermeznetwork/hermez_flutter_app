import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/components/wallet/activity.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/wallet_account_selector_page.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';
import 'package:hermez_plugin/model/account.dart';
import 'package:intl/intl.dart';

import 'context/wallet/wallet_handler.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class WalletAccountDetailsArguments {
  final Account element;
  WalletHandler store;

  WalletAccountDetailsArguments(this.element, this.store);
}

class WalletAccountDetailsPage extends HookWidget {
  WalletAccountDetailsPage(this.arguments);
  final WalletAccountDetailsArguments arguments;

  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();

    final String currency =
        arguments.store.state.defaultCurrency.toString().split('.').last;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          title: Row(
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
                    color: Color.fromRGBO(51, 51, 51, 1.0),
                    border: Border.all(
                      color: Color.fromRGBO(51, 51, 51, 1.0),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                padding:
                    EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 5),
                child: Text(
                    arguments.store.state.txLevel == TransactionLevel.LEVEL1
                        ? "L1"
                        : "L2",
                    style: TextStyle(
                        fontFamily: 'ModernEra',
                        color: HermezColors.lightOrange,
                        backgroundColor: Color.fromRGBO(51, 51, 51, 1.0),
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
              )
            ],
          ),
          backgroundColor: HermezColors.lightOrange,
          elevation: 0),
      body: Container(
        color: HermezColors.lightOrange,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 40),
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
            SizedBox(height: 20),
            buildButtonsRow(context),
            SizedBox(height: 20),
            Expanded(
              child: Activity(
                arguments: ActivityArguments(
                  arguments.store,
                  arguments.element,
                  arguments.store.state.ethereumAddress,
                  arguments.element.token.symbol,
                  currency == "USD"
                      ? arguments.element.token.USD
                      : arguments.element.token.USD *
                          arguments.store.state.exchangeRatio,
                  arguments.store.state.defaultCurrency,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                      Navigator.of(context).pushNamed("/account_selector",
                          arguments: AccountSelectorArguments(
                            //widget.arguments.store.state.txLevel,
                            TransactionType.SEND,
                            arguments.store,
                          ));
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
                      arguments.store.state.txLevel == TransactionLevel.LEVEL1
                          ? Navigator.of(context)
                              .pushNamed("/qrcode", arguments: arguments.store)
                          : Navigator.of(context).pushNamed("/account_selector",
                              arguments: AccountSelectorArguments(
                                //widget.arguments.store.state.txLevel,
                                TransactionType.DEPOSIT,
                                arguments.store,
                              ));
                    },
                    padding: EdgeInsets.all(10.0),
                    color: Colors.transparent,
                    textColor: HermezColors.blackTwo,
                    child: Column(
                      children: <Widget>[
                        Image.asset("assets/deposit2.png"),
                        Text(
                          'Deposit',
                          style: TextStyle(
                            color: HermezColors.blackTwo,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )),
          ),
          arguments.store.state.txLevel == TransactionLevel.LEVEL1
              ? Container()
              : Expanded(
                  child:
                      // takes in an object and color and returns a circle avatar with first letter and required color
                      FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed("/account_selector",
                                arguments: TransactionType.WITHDRAW);
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
        arguments.store.state.defaultCurrency.toString().split('.').last;
    if (currency == "EUR") {
      locale = 'eu';
      symbol = '€';
    } else /* if (currency == "USD")*/ {
      locale = 'en';
      symbol = '\$';
    }
    if (arguments.element.token.USD != null) {
      double value =
          arguments.element.token.USD * double.parse(arguments.element.balance);
      if (currency == "EUR") {
        value *= arguments.store.state.exchangeRatio;
      }
      resultValue = resultValue + value;
    }
    //result += (resultValue / pow(10, 18)).toStringAsFixed(2);
    result = NumberFormat.currency(locale: locale, symbol: symbol)
        .format(resultValue / pow(10, 18));
    return result;
  }
}
