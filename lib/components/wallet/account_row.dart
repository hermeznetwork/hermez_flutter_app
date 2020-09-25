import 'package:flutter/material.dart';
import 'package:hermez/utils/hermez_colors.dart';

class AccountRow extends StatelessWidget {
  AccountRow(this.name, this.symbol, this.price, this.defaultCurrency,
      this.amount, this.simplified, this.currencyFirst, this.onPressed);

  final String name;
  final String symbol;
  final double price;
  final String defaultCurrency;
  final double amount;
  final bool simplified;
  final bool currencyFirst;
  final void Function(String token, String amount) onPressed;

  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(bottom: 15.0),
        child: FlatButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(color: HermezColors.lightGrey)),
          onPressed: () {
            this.onPressed(
              symbol,
              amount.toString(),
            );
          },
          padding: EdgeInsets.all(20.0),
          color: HermezColors.lightGrey,
          textColor: Colors.black,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(this.name,
                          style: TextStyle(
                            color: HermezColors.blackTwo,
                            fontSize: 16,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                    simplified
                        ? Container()
                        : Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(top: 15.0),
                            child: Text(
                              this.symbol,
                              style: TextStyle(
                                color: HermezColors.blueyGreyTwo,
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
                      child: Text(
                        currencyFirst
                            ? (this.price * this.amount).toStringAsFixed(2) +
                                " " +
                                this.defaultCurrency
                            : this.amount.toString() + " " + this.symbol,
                        style: TextStyle(
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w500,
                            color: HermezColors.blackTwo,
                            fontSize: 16),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    simplified
                        ? Container()
                        : Container(
                            padding: EdgeInsets.only(top: 15.0),
                            child: Text(
                              currencyFirst
                                  ? this.amount.toString() + " " + this.symbol
                                  : this.price,
                              style: TextStyle(
                                  fontFamily: 'ModernEra',
                                  color: HermezColors.blueyGreyTwo,
                                  fontWeight: FontWeight.w500),
                              textAlign: TextAlign.right,
                            ),
                          ),
                  ]),
            ],
          ), //title to be name of the crypto
        ));
  }
}
