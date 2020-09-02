import 'package:flutter/services.dart';
import 'package:hermez/components/copyButton/copy_button.dart';
import 'package:hermez/components/wallet/account_row.dart';
import 'package:hermez/model/wallet.dart';
import 'package:hermez/utils/eth_amount_formatter.dart';
import 'package:hermez/wallet_account_details_page.dart';
import 'package:flutter/material.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';

class HomeBalanceArguments {
  final String address;
  final BigInt ethBalance;
  final BigInt tokenBalance;
  final WalletDefaultCurrency defaultCurrency;
  final PageController controller;
  final List cryptoList;
  final scaffoldKey;

  HomeBalanceArguments(this.controller, this.address, this.ethBalance, this.tokenBalance, this.defaultCurrency, this.cryptoList, this.scaffoldKey);
}

class HomeBalance extends StatefulWidget {
  HomeBalance({Key key, this.arguments}) : super(key : key);

  final HomeBalanceArguments arguments;

  @override
  _HomeBalanceState createState() => _HomeBalanceState();
}

class _HomeBalanceState extends State<HomeBalance> {

  final bool _loading = false;
  final List<Color> _colors = [
    //to show different colors for different cryptos
    Color.fromRGBO(47, 128, 237, 1.0), // blue
    Color.fromRGBO(33, 150, 83, 1.0), // green
    Color.fromRGBO(152, 81, 224, 1.0), // purple
  ];

  List _elements = [

    {'symbol': 'USDT', 'name' : 'Tether', 'value': 100.345646, 'price': '€998.45' },
    {'symbol': 'ETH', 'name' : 'Ethereum', 'value': 4.345646, 'price': '€684.14' },
    {'symbol': 'DAI', 'name' : 'DAI', 'value': 200.00, 'price': '€156.22' },
  ];

  List<bool> _selections = [false, true];

  /*@override
  void initState() {
    //override creation of state so that we can call our function
    super.initState();
    getCryptoPrices(); //this function is called which then sets the state of our app
  }*/

  @override
  Widget build(BuildContext context) {
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
                Expanded(child:
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ToggleButtons(
                      children: <Widget>[
                        Text(
                          "L1",
                          style: TextStyle(fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w800,
                              fontSize: 20)
                          ,
                        ),
                        Text(
                          "L2",
                          style: TextStyle(fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w800,
                              fontSize: 20)
                          ,
                        ),
                      ],
                      fillColor: Color.fromRGBO(51, 51, 51, 1.0),
                      selectedColor: Color.fromRGBO(249, 244, 235, 1.0),
                      borderRadius: BorderRadius.circular(8.0),
                      borderColor: Color.fromRGBO(51, 51, 51, 1.0),
                      selectedBorderColor: Color.fromRGBO(51, 51, 51, 1.0),
                      borderWidth: 2,
                      isSelected: _selections,
                      onPressed: (int index) {
                        setState(() {
                          _selections = [false, false];
                          _selections[index] = true;
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
              child:
                FlatButton(
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                  side: BorderSide(color: Color.fromRGBO(51, 51, 51, 0.05))),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _selections[0] == true ? widget.arguments.address : "hez:" + widget.arguments.address));
                    widget.arguments.scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text("Copied"),
                    ));
                  },
                  padding: EdgeInsets.all(20.0),
                  color: Color.fromRGBO(51, 51, 51, 0.05),
                  textColor: Color.fromRGBO(51, 51, 51, 0.60),
                  child: Text(_selections[0] == true ? widget.arguments.address : "hez:" + widget.arguments.address,
                  maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color.fromRGBO(51, 51, 51, 0.60),
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,

                  )),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
                width: double.infinity,
                child:
                Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                  Text(_selections[0] == true ? "€184.50" : "€67.02",//"\$${EthAmountFormatter(tokenBalance).format()}",
                      style: TextStyle(fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w800,
                          fontSize: 40)),
                ])
            ),
            SizedBox(height: 20),
            buildButtonsRow(context),
            SizedBox(height: 20),
            Container(
              color: Colors.white,
              child:
            Padding(
              padding: const EdgeInsets.only(left: 30.0, bottom: 20.0, top: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                    "Accounts",
                    style: TextStyle(fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w800,
                        fontSize: 18)
                    ,textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
            buildAccountsList(),
          ],
        ),
      );
    }
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
                  borderRadius: BorderRadius.circular(10.0),),
                onPressed: () {
                  Navigator.of(context).pushNamed("/token_selector", arguments: TransactionType.SEND);
                },
                padding: EdgeInsets.all(20.0),
                color: Colors.transparent,
                textColor: Colors.black,
                child: Column(children: <Widget>[
                  CircleAvatar(
                      radius: 25,
                      backgroundColor: Color.fromRGBO(247, 222, 207, 1.0),
                      child: Image.asset("assets/send.png",
                        width: 35,
                        height: 35,
                        fit:BoxFit.fill,
                        color: Color.fromRGBO(231, 90, 43, 1.0),)

                  ),
                  SizedBox(height: 10,),
                  Text("Send",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      )),
                ],)
            ),
          ),
          SizedBox(width: 20.0),
          Expanded(
            child:
            // takes in an object and color and returns a circle avatar with first letter and required color
            FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),),
                onPressed: () {
                  Navigator.of(context).pushNamed("/token_selector", arguments: TransactionType.DEPOSIT);
                },
                padding: EdgeInsets.all(20.0),
                color: Colors.transparent,
                textColor: Colors.black,
                child: Column(children: <Widget>[
                  CircleAvatar(
                      radius: 25,
                      backgroundColor: Color.fromRGBO(247, 222, 207, 1.0),
                      child: Image.asset("assets/add.png",
                        width: 25,
                        height: 25,
                        fit:BoxFit.fill,
                        color: Color.fromRGBO(231, 90, 43, 1.0),)

                  ),
                  SizedBox(height: 10,),
                  Text("Deposit",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      )),
                ],)
            ),
          ),
          SizedBox(width: 20.0),
          Expanded(
            child:
            // takes in an object and color and returns a circle avatar with first letter and required color
            FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),),
                onPressed: () {
                  Navigator.of(context).pushNamed("/token_selector", arguments: TransactionType.WITHDRAW);
                },
                padding: EdgeInsets.all(20.0),
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
          SizedBox(width: 20.0),
        ]
    );
  }

  //widget that builds the list
  Widget buildAccountsList() {
    return Expanded(
        child: Container(
            color: Colors.white,
            child: ListView.builder(
        shrinkWrap: true,
        itemCount: 3, //set the item count so that index won't be out of range
        padding:
        const EdgeInsets.all(16.0), //add some padding to make it look good
        itemBuilder: (context, i) {
          //item builder returns a row for each index i=0,1,2,3,4
          // if (i.isOdd) return Divider(); //if index = 1,3,5 ... return a divider to make it visually appealing

          // final index = i ~/ 2; //get the actual index excluding dividers.
          final index = i;
          print(index);
          final element = _elements[index];
          //final Color color = _colors[index %
          //    _colors.length];
          return AccountRow(element['name'], element['symbol'], element['price'], element['value'], null);//iterate through indexes and get the next colour
          //return _buildRow(context, element, color); //build the row widget
        })
    ),
    );
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

  // takes in an object and color and returns a circle avatar with first letter and required color
  CircleAvatar _getLeadingWidget(String name, Color color) {
    return new CircleAvatar(
      backgroundColor: color,
    );
  }
}
