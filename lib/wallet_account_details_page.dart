import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/components/wallet/activity.dart';
import 'package:hermez/service/network/model/L1_account.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';

import 'context/wallet/wallet_handler.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class WalletAccountDetailsArguments {
  final L1Account element;
  WalletHandler store;
  //final Color color;

  WalletAccountDetailsArguments(this.element, this.store /*this.color*/);
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
                    Text(arguments.element.publicKey, // name
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
        body: FutureBuilder<List<dynamic>>(
            future: getTransactions(),
            builder:
                (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  color: Colors.white,
                  child: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: HermezColors.orange,
                    ),
                  ),
                );
              } else {
                if (snapshot.hasError) {
                  // while data is loading:
                  return Container(
                    color: Colors.white,
                    child: Center(
                      child: Text(
                          'There was an error:' + snapshot.error.toString()),
                    ),
                  );
                } else {
                  if (snapshot.hasData) {
                    // data loaded:
                    //supportedTokens = snapshot.data;

                    return Container(
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
                                        (currency == "USD" ? "\$" : "€") +
                                            ((currency == "USD"
                                                        ? arguments.element.USD
                                                        : arguments
                                                                .element.USD *
                                                            arguments
                                                                .store
                                                                .state
                                                                .exchangeRatio) *
                                                    (double.parse(arguments
                                                            .element.balance) /
                                                        pow(10, 18)))
                                                .toStringAsFixed(2),
                                        style: TextStyle(
                                            color: HermezColors.blackTwo,
                                            fontFamily: 'ModernEra',
                                            fontWeight: FontWeight.w800,
                                            fontSize: 32)),
                                  ])),
                          SizedBox(height: 10),
                          Text(
                              (double.parse(arguments.element.balance) /
                                          pow(10, 18))
                                      .toString() +
                                  " " +
                                  arguments.element.tokenSymbol,
                              style: TextStyle(
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w500,
                                  color: HermezColors.steel,
                                  fontSize: 18)),
                          SizedBox(height: 20),
                          buildButtonsRow(context),
                          SizedBox(height: 20),
                          /*Container(
                            color: Colors.white,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 30.0, top: 20.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: Text(
                                  "Activity",
                                  style: TextStyle(
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ),*/
                          Expanded(
                            child: Activity(
                              address: arguments.store.state.address,
                              symbol: arguments.element.tokenSymbol,
                              exchangeRate: currency == "USD"
                                  ? arguments.element.USD
                                  : arguments.element.USD *
                                      arguments.store.state.exchangeRatio,
                              defaultCurrency:
                                  arguments.store.state.defaultCurrency,
                              cryptoList: snapshot.data,
                            ),
                          )
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      color: Colors.white,
                      child: Center(
                        child: Text('There is no data'),
                      ),
                    );
                  }
                }
              }
            }));
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
                      Navigator.of(context).pushNamed("/token_selector",
                          arguments: TransactionType.SEND);
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
                      Navigator.of(context).pushNamed("/token_selector",
                          arguments: TransactionType.DEPOSIT);
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
          Expanded(
            child:
                // takes in an object and color and returns a circle avatar with first letter and required color
                FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed("/token_selector",
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

  Future<List<dynamic>> getTransactions() async {
    if (arguments.element.tokenSymbol == "ETH") {
      return await arguments.store
          .getTransactionsByAddress(arguments.store.state.address);
    } else {
      return await arguments.store
          .getTransferEventsByAddress(arguments.store.state.address);
    }
  }
}
