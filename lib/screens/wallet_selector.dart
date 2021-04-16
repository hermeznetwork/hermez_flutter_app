import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hermez/utils/address_utils.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_plugin/model/account.dart';
import 'package:intl/intl.dart';

import '../context/wallet/wallet_handler.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class WalletSelectorPage extends StatefulWidget {
  WalletSelectorPage({Key key, this.store}) : super(key: key);

  final WalletHandler store;

  @override
  _WalletSelectorPageState createState() => _WalletSelectorPageState();
}

class _WalletSelectorPageState extends State<WalletSelectorPage> {
  List<Account> L1Accounts;
  List<Account> L2Accounts;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  Future<void> fetchData() async {
    L2Accounts = await widget.store.getAccounts();
    L1Accounts = await widget.store.getL1Accounts();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: HermezColors.lightOrange,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Center(
                  child: Container(
                    height: width * 0.58,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        color: HermezColors.darkOrange),
                    padding: EdgeInsets.all(24.0),
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
                                  borderRadius: BorderRadius.circular(16.0),
                                  color: HermezColors.orange),
                              padding: EdgeInsets.only(
                                  left: 12.0, right: 12.0, top: 6, bottom: 6),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                totalBalance(L2Accounts),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "hez:" +
                                        "0x" +
                                        AddressUtils.strip0x(widget
                                                .store.state.ethereumAddress
                                                .substring(0, 6))
                                            .toUpperCase() +
                                        " ･･･ " +
                                        widget.store.state.ethereumAddress
                                            .substring(
                                                widget
                                                        .store
                                                        .state
                                                        .ethereumAddress
                                                        .length -
                                                    4,
                                                widget.store.state
                                                    .ethereumAddress.length)
                                            .toUpperCase() ??
                                    "",
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
                                  Navigator.pushNamed(context, 'home');
                                })
                          ],
                        ),
                      ],
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
                    onPressed: () {},
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
                  child: Container(
                    height: width * 0.58,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        color: HermezColors.blueyGreyTwo),
                    padding: EdgeInsets.all(24.0),
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
                                  borderRadius: BorderRadius.circular(16.0),
                                  color: Colors.white),
                              padding: EdgeInsets.only(
                                  left: 12.0, right: 12.0, top: 6, bottom: 6),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                totalBalance(L1Accounts),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "0x" +
                                        AddressUtils.strip0x(widget
                                                .store.state.ethereumAddress
                                                .substring(0, 6))
                                            .toUpperCase() +
                                        " ･･･ " +
                                        widget.store.state.ethereumAddress
                                            .substring(
                                                widget
                                                        .store
                                                        .state
                                                        .ethereumAddress
                                                        .length -
                                                    4,
                                                widget.store.state
                                                    .ethereumAddress.length)
                                            .toUpperCase() ??
                                    "",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            ImageIcon(
                              AssetImage('assets/qr_code.png'),
                              color: Colors.white,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ), //buildCurrencyList(),
            ],
          ),
        ),
      ),
    );
  }

  String totalBalance(List<Account> _accounts) {
    double resultValue = 0;
    String result = "";
    String locale = "";
    String symbol = "";
    final String currency =
        widget.store.state.defaultCurrency.toString().split('.').last;
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
            value *= widget.store.state.exchangeRatio;
          }
          resultValue = resultValue + value;
        }
      }
    }
    //result += (resultValue / pow(10, 18)).toStringAsFixed(2);
    result = NumberFormat.currency(locale: locale, symbol: symbol)
        .format(resultValue / pow(10, 18));
    return result;
  }
}
