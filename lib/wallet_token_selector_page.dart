import 'package:hermez/components/wallet/account_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';

class WalletTokenSelectorPage extends HookWidget {
  WalletTokenSelectorPage(this.amountType);

  final TransactionType amountType;

  List _elements = [
    {'symbol': 'USDT', 'name' : 'Tether', 'value': 100.345646, 'price': '€998.45' },
    {'symbol': 'ETH', 'name' : 'Ethereum', 'value': 4.345646, 'price': '€684.14' },
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text((() {
          if(amountType == TransactionType.DEPOSIT){
            return "Deposit";
          }else if (amountType == TransactionType.SEND){
            return "Send";
          } else {
            return "Withdraw";
          }
        })()),
        elevation: 0.0,
      ),
      body: Container(
            color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 10,),
                  Text((() {
                    if(amountType == TransactionType.DEPOSIT){
                      return "Available tokens to deposit";
                    }else if (amountType == TransactionType.SEND){
                      return "Available tokens to send";
                    } else {
                      return "Available tokens to withdraw";
                    }
                  })(),
                    style: TextStyle(fontFamily: 'ModernEra',
                      fontWeight: FontWeight.w600,
                      fontSize: 18)
                      ,textAlign: TextAlign.left,),
                  SizedBox(height: 10,),
                  buildAccountsList()
                ])
            )
    );
  }

  //widget that builds the list
  Widget buildAccountsList() {
    return Expanded(
      child: Container(
          color: Colors.white,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: _elements.length, //set the item count so that index won't be out of range
              padding:
              const EdgeInsets.all(16.0), //add some padding to make it look good
              itemBuilder: (context, i) {
                //item builder returns a row for each index i=0,1,2,3,4
                // if (i.isOdd) return Divider(); //if index = 1,3,5 ... return a divider to make it visually appealing

                // final index = i ~/ 2; //get the actual index excluding dividers.
                final index = i;
                print(index);
                final element = _elements[index];
                return AccountRow(element['name'], element['symbol'], element['price'], element['value'], (token, amount) async {
                  Navigator.pushReplacementNamed(context, "/transfer_amount", arguments: AmountArguments(amountType, element));
                },); //build the row widget
              })
      ),
    );
  }
}
