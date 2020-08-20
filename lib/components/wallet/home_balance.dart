import 'package:hermez/components/copyButton/copy_button.dart';
import 'package:hermez/model/wallet.dart';
import 'package:hermez/utils/eth_amount_formatter.dart';
import 'package:hermez/wallet_account_details_page.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';

class HomeBalance extends StatelessWidget {
  HomeBalance({this.controller, this.address, this.ethBalance, this.tokenBalance, this.defaultCurrency, this.cryptoList});

  final String address;
  final BigInt ethBalance;
  final BigInt tokenBalance;
  final WalletDefaultCurrency defaultCurrency;
  final PageController controller;
  final List cryptoList;

  final bool _loading = false;
  final List<Color> _colors = [
    //to show different colors for different cryptos
    Color.fromRGBO(47, 128, 237, 1.0), // blue
    Color.fromRGBO(33, 150, 83, 1.0), // green
    Color.fromRGBO(152, 81, 224, 1.0), // purple
  ];

  List _elements = [
    {'symbol': 'WETH', 'name' : 'Wrapped Ether', 'value': '4.345646' },
    {'symbol': 'USDT', 'name' : 'Tether', 'value': '100.345646' },
    {'symbol': 'DAI', 'name' : 'DAI', 'value': '200.00' },
  ];

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
                Expanded(child:
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      icon: ImageIcon(
                        AssetImage('assets/account.png'),
                      ),
                  onPressed: () {
                    controller.animateToPage(
                      0,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.linear,
                    );
                    //Navigator.of(context).pushNamed("/settings");
                  },
                    )],
                  ),
                ),
                IconButton(
                  icon: ImageIcon(
                    AssetImage('assets/scan.png'),
                  ),
                  onPressed: () {
                    controller.animateToPage(
                      2,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.linear,
                    );
                    //Navigator.of(context).pushNamed("/settings");
                  },
                )
              ],
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  child: Row(children: <Widget>[
                    Text(
                      "Total Value",
                      style: TextStyle(fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w500,
                          fontSize: 18)
                      ,textAlign: TextAlign.left,
                    ),
                  ])
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: SizedBox(
                width: double.infinity,
                child:
                Row(children: <Widget>[
                  Text("€1543,80",//"\$${EthAmountFormatter(tokenBalance).format()}",
                      style: TextStyle(fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w800,
                          fontSize: 40)),
                ])
              ),
            ),
            SizedBox(height: 20),
            buildButtonsRow(),
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

  buildButtonsRow() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(width: 20.0),
          Expanded(
            child:
            FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Colors.grey[300])),
              onPressed: () {
                //Navigator.of(context).pushNamed("/receiver", arguments: ReceiverArguments(ReceiverType.REQUEST));
              },
              padding: EdgeInsets.all(20.0),
              color: Colors.white,
              textColor: Colors.black,
              child: Text("Deposit",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
          SizedBox(width: 20.0),
          Expanded(
            child:
            FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Colors.grey[300])),
              onPressed: () {
                //Navigator.of(context).pushNamed("/receiver", arguments: ReceiverArguments(ReceiverType.REQUEST));
              },
              padding: EdgeInsets.all(20.0),
              color: Colors.white,
              textColor: Colors.black,
              child: Text("Transfer",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
          SizedBox(width: 20.0),
          Expanded(
            child:
            FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Colors.grey[300])),
              onPressed: () {
                //Navigator.of(context).pushNamed("/receiver", arguments: ReceiverArguments(ReceiverType.SEND));
              },
              color: Colors.white,
              textColor: Colors.black,
              padding: EdgeInsets.all(20.0),
              child: Text("Withdraw",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),),
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
          final Color color = _colors[index %
              _colors.length]; //iterate through indexes and get the next colour
          return _buildRow(context, element, color); //build the row widget
        })
    ),
    );
  }

  Widget _buildRow(BuildContext context, dynamic element, Color color) {
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
  }

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
