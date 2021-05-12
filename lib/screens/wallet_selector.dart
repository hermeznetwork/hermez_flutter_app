import 'dart:math';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:hermez/screens/qrcode.dart';
import 'package:hermez/screens/wallet_details.dart';
import 'package:hermez/utils/address_utils.dart';
import 'package:hermez/utils/blinking_text_animation.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_plugin/addresses.dart';
import 'package:hermez_plugin/model/account.dart';
import 'package:intl/intl.dart';

import '../context/wallet/wallet_handler.dart';
import 'transaction_amount.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class WalletSelectorArguments {
  bool showHermezWallet;
  Function hermezWalletShown;
  WalletHandler store;
  BuildContext parentContext;

  WalletSelectorArguments(this.store, this.parentContext,
      {this.showHermezWallet = false, this.hermezWalletShown});
}

class WalletSelectorPage extends StatefulWidget {
  WalletSelectorPage({Key key, this.arguments}) : super(key: key);

  WalletSelectorArguments arguments;

  @override
  _WalletSelectorPageState createState() => _WalletSelectorPageState();
}

class _WalletSelectorPageState extends State<WalletSelectorPage>
    with AfterLayoutMixin<WalletSelectorPage> {
  List<Account> l1Accounts;
  List<Account> l2Accounts;

  bool isLoading = false;

  @override
  Future<void> afterFirstLayout(BuildContext context) {
    if (widget.arguments.showHermezWallet == true) {
      widget.arguments.store.updateLevel(TransactionLevel.LEVEL2);
      Navigator.pushNamed(context, 'wallet_details',
          arguments: WalletDetailsArguments(
            widget.arguments.store,
            TransactionLevel.LEVEL2,
            widget.arguments.parentContext,
          ));
      widget.arguments.showHermezWallet = false;
      if (widget.arguments.hermezWalletShown != null) {
        widget.arguments.hermezWalletShown();
      }
    }
  }

  Future<void> fetchData() async {
    isLoading = true;
    if (widget.arguments.store.state.ethereumAddress == null) {
      await widget.arguments.store.initialise();
    }
    l1Accounts = await widget.arguments.store.getL1Accounts(false);
    l2Accounts = await widget.arguments.store.getAccounts();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: HermezColors.lightOrange,
      body: FutureBuilder(
          future: fetchData(),
          builder: (context, snapshot) {
            return SafeArea(
              child: Container(
                margin: EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: new GestureDetector(
                          onTap: () {
                            widget.arguments.store
                                .updateLevel(TransactionLevel.LEVEL2);
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              Navigator.pushNamed(context, 'wallet_details',
                                  arguments: WalletDetailsArguments(
                                    widget.arguments.store,
                                    TransactionLevel.LEVEL2,
                                    widget.arguments.parentContext,
                                  )).then((value) {
                                setState(() {
                                  l1Accounts = null;
                                  l2Accounts = null;
                                });
                              });
                            });
                          },
                          child: Container(
                            height: width * 0.58,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                color: HermezColors.darkOrange),
                            padding: EdgeInsets.only(
                                left: 24.0,
                                top: 16.0,
                                right: 16.0,
                                bottom: 16.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Hermez wallet',
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
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          color: HermezColors.orange),
                                      padding: EdgeInsets.only(
                                          left: 12.0,
                                          right: 12.0,
                                          top: 6,
                                          bottom: 6),
                                      child: Text(
                                        'L2',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      l2Accounts != null
                                          ? Text(totalBalance(l2Accounts),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 32,
                                                fontFamily: 'ModernEra',
                                                fontWeight: FontWeight.w700,
                                              ))
                                          : BlinkingTextAnimation(
                                              arguments:
                                                  BlinkingTextAnimationArguments(
                                                      Colors.white,
                                                      '0.0',
                                                      32,
                                                      FontWeight.w700))
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "hez:" +
                                            "0x" +
                                            (widget.arguments.store.state.ethereumAddress != null
                                                ? AddressUtils.strip0x(widget
                                                        .arguments
                                                        .store
                                                        .state
                                                        .ethereumAddress
                                                        .substring(0, 6))
                                                    .toUpperCase()
                                                : "") +
                                            " ･･･ " +
                                            (widget.arguments.store
                                                        .state.ethereumAddress !=
                                                    null
                                                ? widget.arguments.store.state
                                                    .ethereumAddress
                                                    .substring(
                                                        widget
                                                                .arguments
                                                                .store
                                                                .state
                                                                .ethereumAddress
                                                                .length -
                                                            4,
                                                        widget
                                                            .arguments
                                                            .store
                                                            .state
                                                            .ethereumAddress
                                                            .length)
                                                    .toUpperCase()
                                                : ""),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'ModernEra',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                        icon: ImageIcon(
                                          AssetImage('assets/qr_code.png'),
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          Navigator.of(widget
                                                  .arguments.parentContext)
                                              .pushNamed(
                                            "/qrcode",
                                            arguments: QRCodeArguments(
                                                qrCodeType: QRCodeType.HERMEZ,
                                                code: getHermezAddress(widget
                                                    .arguments
                                                    .store
                                                    .state
                                                    .ethereumAddress),
                                                store: widget.arguments.store,
                                                isReceive: true),
                                          );
                                        })
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                            padding: EdgeInsets.only(
                                left: 23, right: 23, bottom: 16, top: 16),
                            backgroundColor: HermezColors.blackTwo,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: () {
                            if (!isLoading) {
                              if ((l1Accounts == null ||
                                      l1Accounts.length == 0) &&
                                  (l2Accounts == null ||
                                      l2Accounts.length == 0)) {
                                Navigator.pushNamed(
                                    widget.arguments.parentContext,
                                    "/first_deposit",
                                    arguments: false);
                              } else if (l1Accounts != null &&
                                  l1Accounts.length > 0) {
                                widget.arguments.store
                                    .updateLevel(TransactionLevel.LEVEL1);
                                Account account;
                                if (l1Accounts.length == 1) {
                                  account = l1Accounts[0];
                                }
                                Navigator.pushNamed(
                                    widget.arguments.parentContext,
                                    "/transaction_amount",
                                    arguments: TransactionAmountArguments(
                                      widget.arguments.store,
                                      TransactionLevel.LEVEL1,
                                      TransactionType.DEPOSIT,
                                      account: account,
                                      allowChangeLevel: true,
                                    )).then((value) {
                                  setState(() {
                                    l1Accounts = null;
                                    l2Accounts = null;
                                  });
                                });
                              } else if (l2Accounts != null &&
                                  l2Accounts.length > 0) {
                                widget.arguments.store
                                    .updateLevel(TransactionLevel.LEVEL2);
                                Account account;
                                if (l2Accounts.length == 1) {
                                  account = l2Accounts[0];
                                }
                                Navigator.pushNamed(
                                    widget.arguments.parentContext,
                                    "/transaction_amount",
                                    arguments: TransactionAmountArguments(
                                      widget.arguments.store,
                                      TransactionLevel.LEVEL2,
                                      TransactionType.EXIT,
                                      account: account,
                                      allowChangeLevel: true,
                                    )).then((value) {
                                  setState(() {
                                    l1Accounts = null;
                                    l2Accounts = null;
                                  });
                                });
                              } else {
                                widget.arguments.store
                                    .updateLevel(TransactionLevel.LEVEL1);
                                Navigator.pushNamed(
                                    widget.arguments.parentContext,
                                    "/transaction_amount",
                                    arguments: TransactionAmountArguments(
                                      widget.arguments.store,
                                      TransactionLevel.LEVEL1,
                                      TransactionType.DEPOSIT,
                                      allowChangeLevel: true,
                                    )).then((value) {
                                  setState(() {
                                    l1Accounts = null;
                                    l2Accounts = null;
                                  });
                                });
                              }
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Move',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              ImageIcon(
                                AssetImage('assets/move.png'),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: new GestureDetector(
                          onTap: () {
                            widget.arguments.store
                                .updateLevel(TransactionLevel.LEVEL1);
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              Navigator.pushNamed(context, 'wallet_details',
                                  arguments: WalletDetailsArguments(
                                    widget.arguments.store,
                                    TransactionLevel.LEVEL1,
                                    widget.arguments.parentContext,
                                  )).then((value) {
                                setState(() {
                                  l1Accounts = null;
                                  l2Accounts = null;
                                });
                              });
                            });
                          },
                          child: Container(
                            height: width * 0.58,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                color: HermezColors.blueyGreyTwo),
                            padding: EdgeInsets.only(
                                left: 24.0,
                                top: 16.0,
                                right: 16.0,
                                bottom: 16.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Ethereum wallet',
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
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          color: Colors.white),
                                      padding: EdgeInsets.only(
                                          left: 12.0,
                                          right: 12.0,
                                          top: 6,
                                          bottom: 6),
                                      child: Text(
                                        'L1',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      l1Accounts != null
                                          ? Text(totalBalance(l1Accounts),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 32,
                                                fontFamily: 'ModernEra',
                                                fontWeight: FontWeight.w700,
                                              ))
                                          : BlinkingTextAnimation(
                                              arguments:
                                                  BlinkingTextAnimationArguments(
                                                      Colors.white,
                                                      '0.0',
                                                      32,
                                                      FontWeight.w700))
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "0x" +
                                            (widget.arguments.store.state.ethereumAddress != null
                                                ? AddressUtils.strip0x(widget
                                                        .arguments
                                                        .store
                                                        .state
                                                        .ethereumAddress
                                                        .substring(0, 6))
                                                    .toUpperCase()
                                                : "") +
                                            " ･･･ " +
                                            (widget.arguments.store
                                                        .state.ethereumAddress !=
                                                    null
                                                ? widget.arguments.store.state
                                                    .ethereumAddress
                                                    .substring(
                                                        widget
                                                                .arguments
                                                                .store
                                                                .state
                                                                .ethereumAddress
                                                                .length -
                                                            4,
                                                        widget
                                                            .arguments
                                                            .store
                                                            .state
                                                            .ethereumAddress
                                                            .length)
                                                    .toUpperCase()
                                                : ""),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'ModernEra',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: ImageIcon(
                                        AssetImage('assets/qr_code.png'),
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        Navigator.of(
                                                widget.arguments.parentContext)
                                            .pushNamed(
                                          "/qrcode",
                                          arguments: QRCodeArguments(
                                              qrCodeType: QRCodeType.ETHEREUM,
                                              code: widget.arguments.store.state
                                                  .ethereumAddress,
                                              store: widget.arguments.store,
                                              isReceive: true),
                                        );
                                        //Navigator.pushNamed(context, 'home');
                                      },
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ), //buildCurrencyList(),
                  ],
                ),
              ),
            );
          }),
    );
  }

  String totalBalance(List<Account> _accounts) {
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
          resultValue += value;
        }
      }
    }
    //result += (resultValue / pow(10, 18)).toStringAsFixed(2);
    result = NumberFormat.currency(locale: locale, symbol: symbol)
        .format(resultValue / pow(10, 18));
    return result;
  }
}
