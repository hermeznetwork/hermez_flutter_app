import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AccountRow extends StatelessWidget {
  AccountRow(this.name, this.symbol, this.price, this.amount, this.onPressed);

  final String name;
  final String symbol;
  final String price;
  final double amount;
  final void Function(String token, String amount) onPressed;

  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(bottom: 15.0),
        child:FlatButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: Color.fromRGBO(245, 245, 245, 1.0))),
          onPressed: () {
            this.onPressed(
              symbol,
              amount.toString(),
            );
          },
          padding: EdgeInsets.all(20.0),
          color: Color.fromRGBO(245, 245, 245, 1.0),
          textColor: Colors.black,
          child: Row(
            children: <Widget>[
              Expanded(child:
              Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    child:
                    Text(this.name,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 15.0),
                    child: Text(this.symbol,
                      style: TextStyle(
                        color: Color.fromRGBO(130, 130, 130, 1.0),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ],
              ),
              ),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      child: Text(this.price,
                        style: TextStyle(fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontSize: 24)
                        ,textAlign: TextAlign.right,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 15.0),
                      child: Text(this.amount.toString() + " " + this.symbol,
                        style: TextStyle(fontFamily: 'ModernEra',
                            color: Color.fromRGBO(130, 130, 130, 1.0),
                            fontSize: 16,
                            fontWeight: FontWeight.w500)
                        ,textAlign: TextAlign.right,
                      ),
                    ),
                  ]),
              //SizedBox(width: 10,),
              //_getLeadingWidget("assets/arrow_down.png")
            ],
          ), //title to be name of the crypto
        ));
  }
}
