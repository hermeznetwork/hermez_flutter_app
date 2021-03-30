import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_plugin/model/exit.dart';
import 'package:intl/intl.dart';

class WithdrawalRow extends StatelessWidget {
  WithdrawalRow(
      this.exit, this.step, this.currency, this.exchangeRatio, this.onPressed);

  final Exit exit;
  final int step;
  final String currency;
  final double exchangeRatio;
  final void Function() onPressed;

  Widget build(BuildContext context) {
    String status = "";
    Color statusColor = HermezColors.statusOrange;
    Color statusBackgroundColor = HermezColors.statusOrangeBackground;
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
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: HermezColors.blackTwo),
            padding: EdgeInsets.all(20.0),
            child: Column(children: [
              Row(children: [
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
                      ),
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
                    ),
                  ],
                ),
              ]),
              Row(children: [
                step == 2
                    ? Expanded(
                        child: Container(
                        margin: EdgeInsets.only(top: 15, bottom: 15),
                        //width: double.infinity,
                        child: Divider(
                            color: Color(0x757a7c89),
                            height: 0.5,
                            thickness: 2),
                      ))
                    : Container(),
              ]),
              Row(children: [
                step == 2
                    ? Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                                child: RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyText2,
                                children: [
                                  WidgetSpan(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 5.0),
                                      child: Image.asset("assets/info.png",
                                          width: 15,
                                          height: 15,
                                          color: HermezColors.steel),
                                    ),
                                  ),
                                  TextSpan(
                                      text:
                                          "Sign required to\nfinalize withdraw",
                                      style: TextStyle(
                                        color: HermezColors.steel,
                                        fontSize: 14,
                                        height: 1.43,
                                        fontFamily: 'ModernEra',
                                        fontWeight: FontWeight.w500,
                                      )),
                                ],
                              ),
                            )),
                          ],
                        ),
                      )
                    : Container(),
                step == 2
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          SizedBox(
                            height: 42,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                side: BorderSide(color: Color(0xffe75a2b)),
                              ),
                              onPressed: () {
                                this.onPressed();
                              },
                              padding: EdgeInsets.only(
                                  top: 13.0,
                                  bottom: 13.0,
                                  right: 24.0,
                                  left: 24.0),
                              color: Color(0xffe75a2b),
                              textColor: Colors.white,
                              child: Text("Finalise",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w700,
                                  )),
                            ),
                          ),
                        ],
                      )
                    : Container(),
              ]), //title to be name of the crypto
            ])));
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