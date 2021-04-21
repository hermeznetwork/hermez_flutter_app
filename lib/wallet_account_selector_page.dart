import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/components/wallet/account_row.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/screens/qrcode.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';
import 'package:hermez_plugin/addresses.dart';
import 'package:hermez_plugin/model/account.dart';
import 'package:hermez_plugin/model/token.dart';

class AccountSelectorArguments {
  final TransactionLevel txLevel;
  final TransactionType transactionType;
  final WalletHandler store;

  AccountSelectorArguments(this.txLevel, this.transactionType, this.store);
}

class WalletAccountSelectorPage extends HookWidget {
  WalletAccountSelectorPage(this.arguments);

  final AccountSelectorArguments arguments;
  List<Account> _accounts;

  Future<List<Account>> getAccounts() {
    if ((arguments.txLevel == TransactionLevel.LEVEL1 &&
            arguments.transactionType != TransactionType.FORCEEXIT) ||
        arguments.transactionType == TransactionType.DEPOSIT) {
      return arguments.store.getL1Accounts();
    } else {
      return arguments.store.getAccounts();
    }
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
      body: FutureBuilder<List<Account>>(
        future: getAccounts(),
        builder: (BuildContext context, AsyncSnapshot<List<Account>> snapshot) {
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
    }

    return Column(children: [
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
      Container(
        color: Colors.white,
        child: RefreshIndicator(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _accounts.length,
            //set the item count so that index won't be out of range
            padding: const EdgeInsets.all(16.0),
            //add some padding to make it look good
            itemBuilder: (context, i) {
              //item builder returns a row for each index i=0,1,2,3,4
              // if (i.isOdd) return Divider(); //if index = 1,3,5 ... return a divider to make it visually appealing

              // final index = i ~/ 2; //get the actual index excluding dividers.
              final index = i;
              final Account account = _accounts[index];

              final String currency = arguments.store.state.defaultCurrency
                  .toString()
                  .split('.')
                  .last;
              //final Color color = _colors[index %
              //    _colors.length];
              return AccountRow(
                  account.token.name,
                  account.token.symbol,
                  currency != "USD"
                      ? account.token.USD * arguments.store.state.exchangeRatio
                      : account.token.USD,
                  currency,
                  double.parse(account.balance) /
                      pow(10, account.token.decimals),
                  false,
                  true,
                  false, (String token, String amount) async {
                final Token supportedToken =
                    await arguments.store.getTokenById(account.token.id);
                Navigator.pushReplacementNamed(context, "/transfer_amount",
                    arguments: AmountArguments(arguments.store,
                        arguments.txLevel, arguments.transactionType, account));
              }); //iterate through indexes and get the next colour
              //return _buildRow(context, element, color); //build the row widget
            },
          ),
          onRefresh: _onRefresh,
        ),
      ),
    ]);
  }
}
