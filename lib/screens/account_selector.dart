import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hermez/components/wallet/account_row.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/screens/qrcode.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_plugin/addresses.dart';
import 'package:hermez_plugin/model/account.dart';
import 'package:hermez_plugin/model/token.dart';

class AccountSelectorArguments {
  final TransactionLevel txLevel;
  final TransactionType transactionType;
  final WalletHandler store;
  final String addressTo;

  AccountSelectorArguments(this.txLevel, this.transactionType, this.store,
      {this.addressTo});
}

class AccountSelectorPage extends HookWidget {
  AccountSelectorPage(this.arguments);

  final AccountSelectorArguments arguments;
  List<Account> _accounts;
  List<Token> _tokens;

  Future<List<Account>> getAccounts() {
    if ((arguments.txLevel == TransactionLevel.LEVEL1 &&
            arguments.transactionType != TransactionType.FORCEEXIT) ||
        arguments.transactionType == TransactionType.DEPOSIT) {
      return arguments.store.getL1Accounts();
    } else {
      return arguments.store.getAccounts();
    }
  }

  Future<List<Token>> getTokens() {
    return arguments.store.getTokens();
  }

  Future<void> _onRefresh() async {
    //setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String operation;
    if (arguments.transactionType == TransactionType.SEND) {
      operation = "send";
    } else if (arguments.transactionType == TransactionType.EXIT ||
        arguments.transactionType == TransactionType.FORCEEXIT ||
        arguments.transactionType == TransactionType.DEPOSIT ||
        arguments.transactionType == TransactionType.WITHDRAW) {
      operation = "move";
    } else if (arguments.transactionType == TransactionType.RECEIVE) {
      operation = "receive";
    }

    return Scaffold(
      appBar: new AppBar(
        title: new Text(operation[0].toUpperCase() + operation.substring(1),
            style: TextStyle(
                fontFamily: 'ModernEra',
                color: HermezColors.blackTwo,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        centerTitle: true,
        elevation: 0.0,
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(null),
          ),
        ],
        leading: new Container(),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: arguments.transactionType == TransactionType.RECEIVE
            ? getTokens()
            : getAccounts(),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
                    color: Colors.white,
                    child: handleAccountsList(snapshot, context)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget handleAccountsList(AsyncSnapshot snapshot, BuildContext context) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
        child: CircularProgressIndicator(),
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
          if (arguments.transactionType == TransactionType.RECEIVE) {
            _tokens = snapshot.data;
          } else {
            _accounts = snapshot.data;
            buildAccountsList();
          }
        } else {
          return Container(
            margin: EdgeInsets.all(20.0),
            child: Column(children: [
              Text(
                arguments.txLevel == TransactionLevel.LEVEL1
                    ? 'Make a deposit first in your Ethereum wallet to move your funds.'
                    : 'Make a deposit first in your Hermez wallet to move your funds.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: HermezColors.blackTwo,
                  fontSize: 18,
                  height: 1.5,
                  fontFamily: 'ModernEra',
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              new GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    "/qrcode",
                    arguments: QRCodeArguments(
                      qrCodeType: arguments.txLevel == TransactionLevel.LEVEL1
                          ? QRCodeType.ETHEREUM
                          : QRCodeType.HERMEZ,
                      code: arguments.txLevel == TransactionLevel.LEVEL1
                          ? arguments.store.state.ethereumAddress
                          : getHermezAddress(
                              arguments.store.state.ethereumAddress),
                      store: arguments.store,
                    ),
                  );
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: arguments.txLevel == TransactionLevel.LEVEL1
                          ? HermezColors.blueyGreyTwo
                          : HermezColors.darkOrange),
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              arguments.txLevel == TransactionLevel.LEVEL1
                                  ? 'Ethereum wallet'
                                  : 'Hermez wallet',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'ModernEra',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                color:
                                    arguments.txLevel == TransactionLevel.LEVEL1
                                        ? Colors.white
                                        : HermezColors.orange),
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 6, bottom: 6),
                            child: Text(
                              arguments.txLevel == TransactionLevel.LEVEL1
                                  ? 'L1'
                                  : 'L2',
                              style: TextStyle(
                                color: HermezColors.blackTwo,
                                fontSize: 15,
                                fontFamily: 'ModernEra',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/deposit3.png',
                              width: 75,
                              height: 75,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Image.asset(
                            arguments.txLevel == TransactionLevel.LEVEL1
                                ? 'assets/ethereum_logo.png'
                                : 'assets/hermez_logo_white.png',
                            width: 30,
                            height: 30,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          );
        }
      }
    }

    return buildAccountsList();
  }

  //widget that builds the list
  Widget buildAccountsList() {
    String operation;
    if (arguments.transactionType == TransactionType.SEND) {
      operation = "send";
    } else if (arguments.transactionType == TransactionType.EXIT ||
        arguments.transactionType == TransactionType.FORCEEXIT ||
        arguments.transactionType == TransactionType.DEPOSIT ||
        arguments.transactionType == TransactionType.WITHDRAW) {
      operation = "move";
    } else if (arguments.transactionType == TransactionType.RECEIVE) {
      operation = "receive";
    }

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Available tokens to ' + operation,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: HermezColors.blackTwo,
                fontSize: 16,
                fontFamily: 'ModernEra',
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: HermezColors.blueyGreyTwo),
              padding:
                  EdgeInsets.only(left: 12.0, right: 12.0, top: 4, bottom: 4),
              child: Text(
                arguments.txLevel == TransactionLevel.LEVEL1 ? "L1" : "L2",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'ModernEra',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 16,
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            child: RefreshIndicator(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: arguments.transactionType == TransactionType.RECEIVE
                    ? _tokens.length
                    : _accounts.length,
                //set the item count so that index won't be out of range
                padding: const EdgeInsets.all(16.0),
                //add some padding to make it look good
                itemBuilder: (context, i) {
                  //item builder returns a row for each index i=0,1,2,3,4
                  // if (i.isOdd) return Divider(); //if index = 1,3,5 ... return a divider to make it visually appealing

                  // final index = i ~/ 2; //get the actual index excluding dividers.
                  final index = i;
                  final String currency = arguments.store.state.defaultCurrency
                      .toString()
                      .split('.')
                      .last;
                  if (arguments.transactionType == TransactionType.RECEIVE) {
                    final Token token = _tokens[index];
                    return AccountRow(
                        token.name,
                        token.symbol,
                        currency != "USD"
                            ? token.USD * arguments.store.state.exchangeRatio
                            : token.USD,
                        currency,
                        0
                        /*double.parse(account.balance) /
                pow(10, account.token.decimals)*/
                        ,
                        false,
                        true,
                        false,
                        true, (String tokenId, String amount) async {
                      Navigator.pushReplacementNamed(
                          context, "/transaction_amount",
                          arguments: TransactionAmountArguments(arguments.store,
                              arguments.txLevel, arguments.transactionType,
                              token: token, addressTo: arguments.addressTo));
                      /*final Token supportedToken =
                await arguments.store.getTokenById(account.token.id);
                Navigator.pushReplacementNamed(context, "/transaction_amount",
                arguments: TransactionAmountArguments(arguments.store,
                arguments.txLevel, arguments.transactionType, account));
                */
                    });
                  } else {
                    final Account account = _accounts[index];
                    return AccountRow(
                        account.token.name,
                        account.token.symbol,
                        currency != "USD"
                            ? account.token.USD *
                                arguments.store.state.exchangeRatio
                            : account.token.USD,
                        currency,
                        double.parse(account.balance) /
                            pow(10, account.token.decimals),
                        false,
                        true,
                        false,
                        false, (String token, String amount) async {
                      final Token supportedToken =
                          await arguments.store.getTokenById(account.token.id);
                      Navigator.pushReplacementNamed(
                          context, "/transaction_amount",
                          arguments: TransactionAmountArguments(arguments.store,
                              arguments.txLevel, arguments.transactionType,
                              account: account,
                              addressTo: arguments.addressTo));
                    });
                  }

                  //final Color color = _colors[index %
                  //    _colors.length];
                  //iterate through indexes and get the next colour
                  //return _buildRow(context, element, color); //build the row widget
                },
              ),
              onRefresh: _onRefresh,
            ),
          ),
        ),
      ],
    );
  }
}
