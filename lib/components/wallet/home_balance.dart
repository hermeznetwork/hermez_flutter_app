import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hermez/components/wallet/account_row.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/model/wallet.dart';
import 'package:hermez/service/network/model/L1_account.dart';
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
  final bool _loading = false;

  List _elements = [];
  /*RefreshController _refreshController =
      RefreshController(initialRefresh: false);*/
  /*widget.arguments.cryptoList;/*[
    {
      'symbol': 'USDT',
      'name': 'Tether',
      'value': 100.345646,
      'price': '€998.45',
    },
    {
      'symbol': 'ETH',
      'name': 'Ethereum',
      'value': 4.345646,
      'price': '€684.14',
    },
    {
      'symbol': 'DAI',
      'name': 'DAI',
      'value': 200.00,
      'price': '€156.22',
    },
  ];*/*/

  /*@override
  void initState() {
    //override creation of state so that we can call our function
    super.initState();
    getCryptoPrices(); //this function is called which then sets the state of our app
  }*/

  Future<void> _onRefresh() async {
    /*setState(() {
      fetchUsers();
    });*/

    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    //_elements = widget.arguments.cryptoList;
    //_refreshController.refreshCompleted();
  }

  /* void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    //items.add((items.length + 1).toString());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }*/

  @override
  Widget build(BuildContext context) {
    _elements = widget.arguments.cryptoList;
    if (_loading) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      //return _buildCryptoList();
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
                            index == 1
                                ? _elements = []
                                : _elements = widget.arguments.cryptoList;
                            /*_elements = [
                                    {
                                      'symbol': 'USDT',
                                      'name': 'Tether',
                                      'value': 100.345646,
                                      'price': '€998.45'
                                    },
                                    {
                                      'symbol': 'ETH',
                                      'name': 'Ethereum',
                                      'value': 4.345646,
                                      'price': '€684.14'
                                    },
                                    {
                                      'symbol': 'DAI',
                                      'name': 'DAI',
                                      'value': 200.00,
                                      'price': '€156.22'
                                    },
                                  ];*/
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
                  widget.arguments.scaffoldKey.currentState
                      .showSnackBar(SnackBar(
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
                child:
                    /*SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: false,
                  header: WaterDropHeader(),
                  footer: CustomFooter(
                    builder: (BuildContext context, LoadStatus mode) {
                      Widget body;
                      if (mode == LoadStatus.idle) {
                        body = Text("pull up load");
                      } else if (mode == LoadStatus.loading) {
                        body = CupertinoActivityIndicator();
                      } else if (mode == LoadStatus.failed) {
                        body = Text("Load Failed!Click retry!");
                      } else if (mode == LoadStatus.canLoading) {
                        body = Text("release to load more");
                      } else {
                        body = Text("No more Data");
                      }
                      return Container(
                        height: 55.0,
                        child: Center(child: body),
                      );
                    },
                  ),
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  child:*/
                    buildAccountsList(),
              ),
            ),
            //),
          ],
        ),
      );
    }
  }

  buildButtonsRow(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _elements.length > 0 ? SizedBox(width: 20.0) : Container(),
          widget.arguments.store.state.txLevel == TransactionLevel.LEVEL1 &&
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
    return widget.arguments.store.state.txLevel == TransactionLevel.LEVEL1
        ? widget.arguments.cryptoList.length == 0
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(34.0),
                child: Text(
                  'There are no tokens in this account. \n\n Please make a deposit.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: HermezColors.blueyGrey,
                    fontSize: 16,
                    fontFamily: 'ModernEra',
                    fontWeight: FontWeight.w500,
                  ),
                ))
            : Container(
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
                      final L1Account account = _elements[index];

                      final String currency = widget
                          .arguments.store.state.defaultCurrency
                          .toString()
                          .split('.')
                          .last;
                      //final Color color = _colors[index %
                      //    _colors.length];
                      return AccountRow(
                          //account.,
                          account.publicKey,
                          account.tokenSymbol,
                          currency == "EUR"
                              ? account.USD *
                                  widget.arguments.store.state.exchangeRatio
                              : account.USD,
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
              )
        : Container(
            width: double.infinity,
            padding: const EdgeInsets.all(34.0),
            child: Text(
              'Deposit tokens from your \n\n Ethereum account.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: HermezColors.blueyGrey,
                fontSize: 16,
                fontFamily: 'ModernEra',
                fontWeight: FontWeight.w500,
              ),
            ));
  }

/*Widget _buildRow(BuildContext context, dynamic element, Color color) {
    // returns a row with the desired properties
    return Container(
        padding: EdgeInsets.only(bottom: 15.0),
        child:FlatButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: Color.fromRGBO(245, 245, 245, 1.0))),
          onPressed: () {
            Navigator.of(context).pushNamed("/account_details", arguments: WalletAccountDetailsArguments(element, color));
          },
          padding: EdgeInsets.all(10.0),
          color: Color.fromRGBO(245, 245, 245, 1.0),
          textColor: Colors.black,
          child: ListTile(
              title: Row(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: color,
                        borderRadius: new BorderRadius.all(const Radius.circular(4.0),
                        )
                    ),
                    padding: EdgeInsets.only(top: 7.0, bottom: 7.0, left: 10.0, right: 10.0),
                    child: Text(element['symbol'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w800,
                        )),
                  ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  child:
                    Text(element['name'],
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      )),
                ),
                ],
              ), //title to be name of the crypto
              subtitle:
              Column(
               children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 10.0),
                      child: Text(element['value'],
                        style: TextStyle(
                        color: Color.fromRGBO(51, 51, 51, 1.0),
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        ),
                      ),
                  ),
                 Container(
                   alignment: Alignment.centerLeft,
                   padding: EdgeInsets.only(top: 10.0),
                   child: Text("€984.14",
                     style: TextStyle(
                       color: Color.fromRGBO(130, 130, 130, 1.0),
                       fontSize: 16.0,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                 )
              ]),
          )
        ));
  }*/

//takes in an object and returns the price with 2 decimal places
/*String cryptoPrice(Map crypto) {
    int decimals = 2;
    int fac = pow(10, decimals);
    double d = crypto['quote']['USD']['price'];
    //double d = double.parse(price);
    return "\$" + (d = (d * fac).round() / fac).toString();


    ListTile(
      contentPadding: const EdgeInsets.all(16.0),
      leading: _getLeadingWidget('name',
          color), // get the first letter of each crypto with the color
      title: Text('name'), //title to be name of the crypto
      subtitle: Text(
        //subtitle is below title, get the price in 2 decimal places and set style to bold
        "cryptoPrice(crypto)",
        style: _boldStyle,
      ),
      trailing: new Text(
        "\$${EthAmountFormatter(tokenBalance).format()}",
        //style: Theme.of(context).textTheme.body2.apply(fontSizeDelta: 6),
      )
    )
  }*/

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
