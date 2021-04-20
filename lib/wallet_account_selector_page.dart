import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/components/wallet/account_row.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';
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
    } else if (arguments.transactionType == TransactionType.MOVE) {
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
                  child: Column(
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
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 4, bottom: 4),
                            child: Text(
                              arguments.txLevel == TransactionLevel.LEVEL1
                                  ? "L1"
                                  : "L2",
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
                      handleAccountsList(snapshot)
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget handleAccountsList(AsyncSnapshot snapshot) {
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
              width: double.infinity,
              padding: const EdgeInsets.all(34.0),
              child: Text(
                arguments.store.state.txLevel == TransactionLevel.LEVEL1
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
                double.parse(account.balance) / pow(10, account.token.decimals),
                false,
                true,
                false, (String token, String amount) async {
              final Token supportedToken =
                  await arguments.store.getTokenById(account.token.id);
              Navigator.pushReplacementNamed(context, "/transfer_amount",
                  arguments: AmountArguments(
                      arguments.store,
                      arguments.store.state.txLevel,
                      arguments.transactionType,
                      account));
            }); //iterate through indexes and get the next colour
            //return _buildRow(context, element, color); //build the row widget
          },
        ),
        onRefresh: _onRefresh,
      ),
    );
  }
}
