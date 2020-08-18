import 'package:hermezwallet/components/copyButton/copy_button.dart';
import 'package:hermezwallet/model/wallet.dart';
import 'package:hermezwallet/utils/eth_amount_formatter.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';

class Balance extends StatelessWidget {
  Balance({this.address, this.ethBalance, this.tokenBalance, this.defaultCurrency, this.cryptoList});

  final String address;
  final BigInt ethBalance;
  final BigInt tokenBalance;
  final WalletDefaultCurrency defaultCurrency;
  final List cryptoList;


  final _saved = Set<Map>(); //store favourited cryptos
  final _boldStyle =
  new TextStyle(fontWeight: FontWeight.bold); //bold text style
  final bool _loading = false;
  final List<MaterialColor> _colors = [
    //to show different colors for different cryptos
    Colors.blue,
    Colors.indigo,
    Colors.lime,
    Colors.teal,
    Colors.cyan
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
          color: Colors.white,
          child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  child: Text(
                    "Balance",
                    style: TextStyle(fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w600,
                        fontSize: 28)
                    ,textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  child: Text(
                      "€650.43",//"\$${EthAmountFormatter(tokenBalance).format()}",
                      style: TextStyle(fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w700,
                          fontSize: 60)
                    //style: Theme.of(context).textTheme.body2.apply(fontSizeDelta: 6),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  child: Text(
                      "Hide all assets ▲",//"\$${EthAmountFormatter(tokenBalance).format()}",
                      style: TextStyle(fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w700,
                          color: Colors.grey,
                          fontSize: 16)
                    //style: Theme.of(context).textTheme.body2.apply(fontSizeDelta: 6),
                  ),
                ),
              ),
            ),

            /*Text(
              "${EthAmountFormatter(ethBalance).format()} ETH",
              style:
              Theme.of(context).textTheme.body2.apply(color: Colors.blueGrey, fontSizeDelta: 12),
            ),*/
            /*SizedBox(height: 20),*/
            /*Text(
              "${EthAmountFormatter(tokenBalance).format()} tokens",
              style: Theme.of(context).textTheme.body2.apply(fontSizeDelta: 6),
            ),*/
            /*QrImage(
              data: address ?? "",
              size: 150.0,
            ),
            SizedBox(height: 10),
            CopyButton(
              text: const Text('Copy address'),
              value: address,
            ),
            SizedBox(height: 20),
            Text(address ?? ""),*/
            SizedBox(height: 20),
            _buildCryptoList(),
          ],
        ),
      );
    }
  }

  //widget that builds the list
  Widget _buildCryptoList() {
    return Flexible(
        child: Container(
            color: Colors.grey[100],
            child: ListView.builder(
        shrinkWrap: true,
        itemCount: cryptoList
            .length, //set the item count so that index won't be out of range
        padding:
        const EdgeInsets.all(16.0), //add some padding to make it look good
        itemBuilder: (context, i) {
          //item builder returns a row for each index i=0,1,2,3,4
          // if (i.isOdd) return Divider(); //if index = 1,3,5 ... return a divider to make it visually appealing

          // final index = i ~/ 2; //get the actual index excluding dividers.
          final index = i;
          print(index);
          final MaterialColor color = _colors[index %
              _colors.length]; //iterate through indexes and get the next colour
          return _buildRow(cryptoList[index], color); //build the row widget
        })
    ),
    );
  }

  Widget _buildRow(Map crypto, MaterialColor color) {
    // if _saved contains our crypto, return true
    final bool favourited = _saved.contains(crypto);

    // function to handle when heart icon is tapped
    /*void _fav() {
      setState(() {
        if (favourited) {
          //if it is favourited previously, remove it from the list
          _saved.remove(crypto);
        } else {
          _saved.add(crypto); //else add it to the array
        }
      });
    }*/

    // returns a row with the desired properties
    return ListTile(
      leading: _getLeadingWidget(crypto['name'],
          color), // get the first letter of each crypto with the color
      title: Text(crypto['name']), //title to be name of the crypto
      subtitle: Text(
        //subtitle is below title, get the price in 2 decimal places and set style to bold
        cryptoPrice(crypto),
        style: _boldStyle,
      ),
      trailing: new Text(
        "\$${EthAmountFormatter(tokenBalance).format()}",
        //style: Theme.of(context).textTheme.body2.apply(fontSizeDelta: 6),
      )
    );
  }

  //takes in an object and returns the price with 2 decimal places
  String cryptoPrice(Map crypto) {
    int decimals = 2;
    int fac = pow(10, decimals);
    double d = crypto['quote']['USD']['price'];
    //double d = double.parse(price);
    return "\$" + (d = (d * fac).round() / fac).toString();
  }

  // takes in an object and color and returns a circle avatar with first letter and required color
  CircleAvatar _getLeadingWidget(String name, MaterialColor color) {
    return new CircleAvatar(
      backgroundColor: color,
      child: new Text(name[0]),
    );
  }
}
