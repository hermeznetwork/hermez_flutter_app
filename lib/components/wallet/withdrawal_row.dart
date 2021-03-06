import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_plugin/model/exit.dart';
import 'package:intl/intl.dart';

class WithdrawalRow extends StatelessWidget {
  WithdrawalRow(this.exit, this.step, this.currency, this.exchangeRatio
      /*this.onPressed*/
      );

  final Exit exit;
  final int step;
  final String currency;
  final double exchangeRatio;
  //final void Function(String token, String amount) onPressed;

  Widget build(BuildContext context) {
    String status = "";
    Color statusColor = HermezColors.statusOrange;
    Color statusBackgroundColor = HermezColors.statusOrangeBackground;
    //Color(0xfff2994a)
    //Color(0xffd8853b)
    switch (step) {
      case 1:
        status = "Initiated";
        statusColor = HermezColors.statusOrange;
        statusBackgroundColor = HermezColors.statusOrangeBackground;
        break;
      case 2:
        status = "On hold";
        statusColor = HermezColors.statusRed;
        statusBackgroundColor = HermezColors.statusRedBackground;
        break;
      case 3:
        status = "Pending";
        statusColor = HermezColors.statusOrange;
        statusBackgroundColor = HermezColors.statusOrangeBackground;
        break;
    }

    return Container(
        padding: EdgeInsets.only(bottom: 15.0),
        child: FlatButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(color: HermezColors.blackTwo)),
          onPressed: () {
            /*this.onPressed(
              symbol,
              amount.toString(),
            );*/
          },
          padding: EdgeInsets.all(20.0),
          color: HermezColors.blackTwo,
          textColor: Colors.black,
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Text("STEP $step/3",
                        style: TextStyle(
                          color: HermezColors.steel,
                          fontSize: 13,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    child: Text("Withdrawal",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: statusBackgroundColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(status,
                        // On Hold, Pending
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 16,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w700,
                        )),
                  )
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  child: Text("",
                      style: TextStyle(
                        color: HermezColors.steel,
                        fontSize: 13,
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w500,
                      )),
                ),
                SizedBox(height: 16.0),
                Container(
                  child: Text(
                      (double.parse(exit.balance) /
                                  pow(10, exit.token.decimals))
                              .toString() +
                          " " +
                          exit.token.symbol,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w700,
                      )),
                ),
                SizedBox(height: 8.0),
                Container(
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Text(
                      (currency == "EUR" ? "€" : "\$") +
                          (double.parse(exit.balance) /
                                  pow(10, exit.token.decimals) *
                                  exit.token.USD *
                                  (currency == "EUR" ? exchangeRatio : 1))
                              .toStringAsFixed(2),
                      // On Hold, Pending
                      style: TextStyle(
                        color: HermezColors.steel,
                        fontSize: 16,
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w500,
                      )),
                )
              ],
            )
          ]), //title to be name of the crypto
        ));
  }

  String formatAmount(double amount, String symbol) {
    double resultValue = 0;
    String result = "";
    String locale = "eu";
    if (symbol == "EUR") {
      locale = 'eu';
      symbol = '€';
    } else if (symbol == "USD") {
      locale = 'en';
      symbol = '\$';
    }
    if (amount != null) {
      double value = amount;
      resultValue = resultValue + value;
    }
    result =
        NumberFormat.currency(locale: locale, symbol: symbol).format(amount);
    return result;
  }
}
