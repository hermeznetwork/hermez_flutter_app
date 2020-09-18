import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/components/wallet/account_row.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';

class WalletTokenSelectorPage extends HookWidget {
  WalletTokenSelectorPage(this.amountType);

  final TransactionType amountType;

  List _elements = [
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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text('Token',
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
        body: Container(
            color: Colors.white,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[buildAccountsList()])));
  }

  //widget that builds the list
  Widget buildAccountsList() {
    return Expanded(
      child: Container(
          color: Colors.white,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: _elements
                  .length, //set the item count so that index won't be out of range
              padding: const EdgeInsets.all(
                  16.0), //add some padding to make it look good
              itemBuilder: (context, i) {
                //item builder returns a row for each index i=0,1,2,3,4
                // if (i.isOdd) return Divider(); //if index = 1,3,5 ... return a divider to make it visually appealing

                // final index = i ~/ 2; //get the actual index excluding dividers.
                final index = i;
                print(index);
                final element = _elements[index];
                return AccountRow(
                  element['name'],
                  element['symbol'],
                  element['price'],
                  element['value'],
                  false,
                  true,
                  (token, amount) async {
                    Navigator.pushReplacementNamed(context, "/transfer_amount",
                        arguments: AmountArguments(amountType, element));
                  },
                ); //build the row widget
              })),
    );
  }
}
