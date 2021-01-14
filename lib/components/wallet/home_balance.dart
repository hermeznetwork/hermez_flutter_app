import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hermez/components/wallet/account_row.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/model/wallet.dart';
import 'package:hermez/service/network/model/L1_account.dart';
import 'package:hermez/service/network/model/account.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/wallet_account_details_page.dart';
import 'package:hermez/wallet_account_selector_page.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';

class HomeBalanceArguments {
  final String address;
  final BigInt ethBalance;
  final Map<String, BigInt> tokensBalance;
  final WalletDefaultCurrency defaultCurrency;
  final WalletHandler store;
  final PageController controller;
  final List<L1Account> cryptoList;
  final scaffoldKey;

  HomeBalanceArguments(
      this.controller,
      this.address,
      this.ethBalance,
      this.tokensBalance,
      this.defaultCurrency,
      this.store,
      this.cryptoList,
      this.scaffoldKey);
}

class HomeBalance extends StatefulWidget {
  HomeBalance({Key key, this.arguments}) : super(key: key);

  final HomeBalanceArguments arguments;

  @override
  _HomeBalanceState createState() => _HomeBalanceState();
}

class _HomeBalanceState extends State<HomeBalance> {
  List<Account> _elements;

  Future<void> _onRefresh() async {
    setState(() {});
  }

  Future<List<Account>> fetchAccounts() async {
    return widget.arguments.store.state.txLevel == TransactionLevel.LEVEL2
        ? widget.arguments.store.getAccounts()
        : _elements = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(249, 244, 235, 1.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: ImageIcon(
                  AssetImage('assets/account.png'),
                ),
                onPressed: () {
                  widget.arguments.controller.animateToPage(
                    0,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.linear,
                  );
                  //Navigator.of(context).pushNamed("/settings");
                },
              ),
              Expanded(
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
                      selectedColor: Color.fromRGBO(249, 244, 235, 1.0),
                      borderRadius: BorderRadius.circular(8.0),
                      borderColor: Color.fromRGBO(51, 51, 51, 1.0),
                      selectedBorderColor: Color.fromRGBO(51, 51, 51, 1.0),
                      borderWidth: 2,
                      isSelected: [
                        widget.arguments.store.state.txLevel ==
                            TransactionLevel.LEVEL1,
                        widget.arguments.store.state.txLevel ==
                            TransactionLevel.LEVEL2
                      ],
                      onPressed: (int index) {
                        setState(() {
                          widget.arguments.store.updateLevel(index == 1
                              ? TransactionLevel.LEVEL2
                              : TransactionLevel.LEVEL1);
                          //index == 1 ? _elements = [] : fetchAccounts();
                        });
                      },
                    )
                  ],
                ),
              ),
              IconButton(
                icon: ImageIcon(
                  AssetImage('assets/scan.png'),
                ),
                onPressed: () {
                  widget.arguments.controller.animateToPage(
                    2,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.linear,
                  );
                  //Navigator.of(context).pushNamed("/settings");
                },
              )
            ],
          ),
          SizedBox(height: 30),
          Container(
            margin: EdgeInsets.only(left: 40, right: 40),
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                  side: BorderSide(color: Color(0xfff6e9d3))),
              onPressed: () {
                Clipboard.setData(ClipboardData(
                    text: widget.arguments.store.state.txLevel ==
                            TransactionLevel.LEVEL1
                        ? widget.arguments.address
                        : "hez:" + widget.arguments.address));
                widget.arguments.scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Text("Copied"),
                ));
              },
              padding: EdgeInsets.all(20.0),
              color: HermezColors.mediumOrange,
              textColor: Color(0xff7a7c89),
              child: Text(
                  widget != null &&
                          widget.arguments != null &&
                          widget.arguments.address != null
                      ? (widget.arguments.store.state.txLevel ==
                              TransactionLevel.LEVEL1
                          ? widget.arguments.address
                          : "hez:" + widget.arguments.address)
                      : "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xff7a7c89),
                    fontSize: 16,
                    fontFamily: 'ModernEra',
                    fontWeight: FontWeight.w500,
                  )),
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
                            ? totalL1Balance(widget.arguments.cryptoList)
                            : widget.arguments.store.state.defaultCurrency
                                        .toString()
                                        .split('.')
                                        .last ==
                                    "EUR"
                                ? "€0.00"
                                : "\$0.00",
                        //"\$${EthAmountFormatter(tokenBalance).format()}",
                        style: TextStyle(
                          color: HermezColors.black,
                          fontSize: 32,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w800,
                        )),
                  ])),
          SizedBox(height: 16),
          buildButtonsRow(context),
          SizedBox(height: 20),
          Expanded(
            child: Container(
                color: Colors.white,
                child: FutureBuilder(
                    future: fetchAccounts(),
                    builder: (buildContext, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        if (snapshot.hasError) {
                          // while data is loading:
                          return Container(
                            color: Colors.white,
                            child: Center(
                              child: Text('There was an error:' +
                                  snapshot.error.toString()),
                            ),
                          );
                        } else {
                          if (snapshot.hasData) {
                            // data loaded:
                            _elements = snapshot.data;
                            buildAccountsList();
                          } else {
                            return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(34.0),
                                child: Text(
                                  widget.arguments.store.state.txLevel ==
                                          TransactionLevel.LEVEL1
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
                    })),
          ),
          //),
        ],
      ),
    );
  }

  buildButtonsRow(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _elements != null && _elements.length > 0
              ? SizedBox(width: 20.0)
              : Container(),
          widget.arguments.store.state.txLevel == TransactionLevel.LEVEL1 &&
                  _elements != null &&
                  _elements.length > 0
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
                                  TransactionType.SEND,
                                  widget.arguments.store,
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
                        Navigator.of(context).pushNamed("/qrcode",
                            arguments: widget.arguments.store);
                      } else {
                        Navigator.of(context).pushNamed("/account_selector",
                            arguments: AccountSelectorArguments(
                              //widget.arguments.store.state.txLevel,
                              TransactionType.DEPOSIT,
                              widget.arguments.store,
                            ));
                      }
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
          SizedBox(width: 20.0),
          /*Expanded(
            child:
            // takes in an object and color and returns a circle avatar with first letter and required color
            FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),),
                onPressed: () {
                  Navigator.of(context).pushNamed("/account_selector", arguments: TransactionType.WITHDRAW);
                },
                padding: EdgeInsets.all(10.0),
                color: Colors.transparent,
                textColor: Colors.black,
                child: Column(children: <Widget>[
                  CircleAvatar(
                      radius: 25,
                      backgroundColor: Color.fromRGBO(247, 222, 207, 1.0),
                      child: Image.asset("assets/withdraw.png",
                        width: 15,
                        height: 28,
                        fit:BoxFit.fill,
                        color: Color.fromRGBO(231, 90, 43, 1.0),)

                  ),
                  SizedBox(height: 10,),
                  Text("Withdraw",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      )),
                ],)
            ),
          ),
          SizedBox(width: 20.0),*/
        ]);
  }

  //widget that builds the list
  Widget buildAccountsList() {
    return Container(
      color: Colors.white,
      child: RefreshIndicator(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _elements.length,
          //set the item count so that index won't be out of range
          padding: const EdgeInsets.all(16.0),
          //add some padding to make it look good
          itemBuilder: (context, i) {
            //item builder returns a row for each index i=0,1,2,3,4
            // if (i.isOdd) return Divider(); //if index = 1,3,5 ... return a divider to make it visually appealing

            // final index = i ~/ 2; //get the actual index excluding dividers.
            final index = i;
            print(index);
            final Account account = _elements[index];

            final String currency = widget.arguments.store.state.defaultCurrency
                .toString()
                .split('.')
                .last;
            //final Color color = _colors[index %
            //    _colors.length];
            return AccountRow(
                //account.,
                account.bjj,
                account.token.symbol,
                currency == "EUR"
                    ? account.token.USD *
                        widget.arguments.store.state.exchangeRatio
                    : account.token.USD,
                currency,
                double.parse(account.balance) / pow(10, 18),
                false,
                true, (token, amount) async {
              Navigator.of(context).pushNamed("/account_details",
                  arguments: WalletAccountDetailsArguments(
                      account, widget.arguments.store));
            }); //iterate through indexes and get the next colour
            //return _buildRow(context, element, color); //build the row widget
          },
        ),
        onRefresh: _onRefresh,
      ),
    );
    /*: Container(
                color: Colors.white,
                child: RefreshIndicator(
                  child: ListView.builder(
                    //shrinkWrap: true,
                    itemCount: _elements.length,
                    itemExtent: 100.0,
                    //set the item count so that index won't be out of range
                    padding: const EdgeInsets.all(16.0),
                    //add some padding to make it look good
                    itemBuilder: (context, i) {
                      //item builder returns a row for each index i=0,1,2,3,4
                      // if (i.isOdd) return Divider(); //if index = 1,3,5 ... return a divider to make it visually appealing

                      // final index = i ~/ 2; //get the actual index excluding dividers.
                      final index = i;
                      print(index);
                      final Account account = _elements[index];

                      final String currency = widget
                          .arguments.store.state.defaultCurrency
                          .toString()
                          .split('.')
                          .last;
                      //final Color color = _colors[index %
                      //    _colors.length];
                      return AccountRow(
                          //account.,
                          account.bjj,
                          account.token.symbol,
                          currency == "EUR"
                              ? account.token.USD *
                                  widget.arguments.store.state.exchangeRatio
                              : account.token.USD,
                          currency,
                          double.parse(account.balance) / pow(10, 18),
                          false,
                          true, (token, amount) async {
                        Navigator.of(context).pushNamed("/account_details",
                            arguments: WalletAccountDetailsArguments(
                                account, widget.arguments.store));
                      }); //iterate through indexes and get the next colour
                      //return _buildRow(context, element, color); //build the row widget
                    },
                  ),
                  onRefresh: _onRefresh,
                ),
              );*/
  }

  String totalL1Balance(List<L1Account> L1accounts) {
    double resultValue = 0;
    String result = "";
    final String currency =
        widget.arguments.store.state.defaultCurrency.toString().split('.').last;
    if (currency == "EUR") {
      result += '€';
    } else if (currency == "USD") {
      result += '\$';
    }
    for (L1Account account in L1accounts) {
      double value = account.USD * double.parse(account.balance);
      if (currency == "EUR") {
        value *= widget.arguments.store.state.exchangeRatio;
      }
      resultValue = resultValue + value;
    }
    result += (resultValue / pow(10, 18)).toStringAsFixed(2);
    return result;
  }
}
