import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hermez/components/wallet/account_row.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/screens/qrcode.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez/utils/balance_utils.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_plugin/addresses.dart';
import 'package:hermez_plugin/model/account.dart';
import 'package:hermez_plugin/model/token.dart';

class AccountSelectorArguments {
  final TransactionLevel txLevel;
  final TransactionType transactionType;
  final WalletHandler store;

  AccountSelectorArguments(this.txLevel, this.transactionType, this.store);
}

class AccountSelectorPage extends StatefulWidget {
  AccountSelectorPage({Key key, this.arguments}) : super(key: key);

  final AccountSelectorArguments arguments;

  @override
  _AccountSelectorPageState createState() => _AccountSelectorPageState();
}

class _AccountSelectorPageState extends State<AccountSelectorPage> {
  List<Account> _accounts;
  List<Token> _tokens;

  List<Account> getAccounts() {
    if ((widget.arguments.txLevel == TransactionLevel.LEVEL1 &&
            widget.arguments.transactionType != TransactionType.FORCEEXIT) ||
        widget.arguments.transactionType == TransactionType.DEPOSIT) {
      return widget.arguments.store.state.l1Accounts; //getL1Accounts(false);
    } else {
      return widget.arguments.store.state.l2Accounts; //getL2Accounts();
    }
  }

  Future<List<Token>> getTokens() {
    return widget.arguments.store.getTokens();
  }

  Future<void> _onRefresh() async {
    //setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String operation;
    if (widget.arguments.transactionType == TransactionType.SEND) {
      operation = "send";
    } else if (widget.arguments.transactionType == TransactionType.EXIT ||
        widget.arguments.transactionType == TransactionType.FORCEEXIT ||
        widget.arguments.transactionType == TransactionType.DEPOSIT ||
        widget.arguments.transactionType == TransactionType.WITHDRAW) {
      operation = "move";
    } else if (widget.arguments.transactionType == TransactionType.RECEIVE) {
      operation = "receive";
    }

    _accounts = getAccounts();

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
            onPressed: () {
              Navigator.of(context).maybePop();
            },
          ),
        ],
        leading: new Container(),
      ),
      body: widget.arguments.transactionType == TransactionType.RECEIVE
          ? FutureBuilder<List<dynamic>>(
              future: getTokens(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>> snapshot) {
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
            )
          : _accounts != null && _accounts.length > 0
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                          color: Colors.white,
                          child: buildAccountsList(context)),
                    ),
                  ],
                )
              : Container(
                  margin: EdgeInsets.all(20.0),
                  child: Column(children: [
                    Text(
                      'Make a deposit first in your ' +
                          (widget.arguments.txLevel == TransactionLevel.LEVEL1
                              ? 'Ethereum wallet'
                              : 'Hermez wallet') +
                          ' to ' +
                          (widget.arguments.transactionType ==
                                  TransactionType.SEND
                              ? 'send tokens.'
                              : 'move your funds.'),
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
                            qrCodeType: widget.arguments.txLevel ==
                                    TransactionLevel.LEVEL1
                                ? QRCodeType.ETHEREUM
                                : QRCodeType.HERMEZ,
                            code: widget.arguments.txLevel ==
                                    TransactionLevel.LEVEL1
                                ? widget.arguments.store.state.ethereumAddress
                                : getHermezAddress(widget
                                    .arguments.store.state.ethereumAddress),
                            store: widget.arguments.store,
                          ),
                        );
                      },
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            color: widget.arguments.txLevel ==
                                    TransactionLevel.LEVEL1
                                ? HermezColors.blueyGreyTwo
                                : HermezColors.darkOrange),
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.arguments.txLevel ==
                                            TransactionLevel.LEVEL1
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
                                      color: widget.arguments.txLevel ==
                                              TransactionLevel.LEVEL1
                                          ? Colors.white
                                          : HermezColors.orange),
                                  padding: EdgeInsets.only(
                                      left: 12.0,
                                      right: 12.0,
                                      top: 6,
                                      bottom: 6),
                                  child: Text(
                                    widget.arguments.txLevel ==
                                            TransactionLevel.LEVEL1
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
                                  widget.arguments.txLevel ==
                                          TransactionLevel.LEVEL1
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
                ),
    );
  }

  Widget handleAccountsList(AsyncSnapshot snapshot, BuildContext context) {
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
          if (widget.arguments.transactionType == TransactionType.RECEIVE) {
            _tokens = snapshot.data;
          } else {
            _accounts = snapshot.data;
            buildAccountsList(context);
          }
        } else {
          return Container(
            margin: EdgeInsets.all(20.0),
            child: Column(children: [
              Text(
                'Make a deposit first in your ' +
                    (widget.arguments.txLevel == TransactionLevel.LEVEL1
                        ? 'Ethereum wallet'
                        : 'Hermez wallet') +
                    ' to ' +
                    (widget.arguments.transactionType == TransactionType.SEND
                        ? 'send tokens.'
                        : 'move your funds.'),
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
                      qrCodeType:
                          widget.arguments.txLevel == TransactionLevel.LEVEL1
                              ? QRCodeType.ETHEREUM
                              : QRCodeType.HERMEZ,
                      code: widget.arguments.txLevel == TransactionLevel.LEVEL1
                          ? widget.arguments.store.state.ethereumAddress
                          : getHermezAddress(
                              widget.arguments.store.state.ethereumAddress),
                      store: widget.arguments.store,
                    ),
                  );
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: widget.arguments.txLevel == TransactionLevel.LEVEL1
                          ? HermezColors.blueyGreyTwo
                          : HermezColors.darkOrange),
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.arguments.txLevel ==
                                      TransactionLevel.LEVEL1
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
                                color: widget.arguments.txLevel ==
                                        TransactionLevel.LEVEL1
                                    ? Colors.white
                                    : HermezColors.orange),
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 6, bottom: 6),
                            child: Text(
                              widget.arguments.txLevel ==
                                      TransactionLevel.LEVEL1
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
                            widget.arguments.txLevel == TransactionLevel.LEVEL1
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

    return buildAccountsList(context);
  }

  //widget that builds the list
  Widget buildAccountsList(BuildContext parentContext) {
    String operation;
    if (widget.arguments.transactionType == TransactionType.SEND) {
      operation = "send";
    } else if (widget.arguments.transactionType == TransactionType.EXIT ||
        widget.arguments.transactionType == TransactionType.FORCEEXIT ||
        widget.arguments.transactionType == TransactionType.DEPOSIT ||
        widget.arguments.transactionType == TransactionType.WITHDRAW) {
      operation = "move";
    } else if (widget.arguments.transactionType == TransactionType.RECEIVE) {
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
                widget.arguments.txLevel == TransactionLevel.LEVEL1
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
        Expanded(
          child: Container(
            color: Colors.white,
            child: RefreshIndicator(
              color: HermezColors.orange,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount:
                    widget.arguments.transactionType == TransactionType.RECEIVE
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
                  final String currency = widget
                      .arguments.store.state.defaultCurrency
                      .toString()
                      .split('.')
                      .last;
                  if (widget.arguments.transactionType ==
                      TransactionType.RECEIVE) {
                    final Token token = _tokens[index];
                    return AccountRow(
                        null,
                        token,
                        token.name,
                        token.symbol,
                        currency != "USD"
                            ? token.USD *
                                widget.arguments.store.state.exchangeRatio
                            : token.USD,
                        currency,
                        0,
                        false,
                        true,
                        false,
                        true, (Account account, Token token, String tokenId,
                            String amount) async {
                      Navigator.maybePop(parentContext, token);
                    });
                  } else {
                    final Account account = _accounts[index];
                    return AccountRow(
                        account,
                        null,
                        account.token.name,
                        account.token.symbol,
                        currency != "USD"
                            ? account.token.USD *
                                widget.arguments.store.state.exchangeRatio
                            : account.token.USD,
                        currency,
                        BalanceUtils.calculatePendingBalance(
                                widget.arguments.txLevel,
                                account,
                                account.token.symbol,
                                widget.arguments.store) /
                            pow(10, account.token.decimals),
                        false,
                        true,
                        false,
                        false, (Account account, Token token, String tokenId,
                            String amount) {
                      Navigator.maybePop(parentContext, account);
                    });
                  }
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
