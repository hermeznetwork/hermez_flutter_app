import 'package:flutter/material.dart';
import 'package:hermez/utils/eth_amount_formatter.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:intl/intl.dart';

class AccountRow extends StatelessWidget {
  AccountRow(
      this.name,
      this.symbol,
      this.price,
      this.defaultCurrency,
      this.amount,
      this.simplified,
      this.currencyFirst,
      this.pendingDeposit,
      this.isToken,
      this.onPressed);

  final String name;
  final String symbol;
  final double price;
  final String defaultCurrency;
  final double amount;
  final bool simplified;
  final bool currencyFirst;
  final bool pendingDeposit;
  final bool isToken;
  final void Function(String token, String amount) onPressed;

  Widget build(BuildContext context) {
    String status = "Pending";
    Color statusColor = HermezColors.statusOrange;
    Color statusBackgroundColor = HermezColors.statusOrangeBackground;

    return Container(
        padding: EdgeInsets.only(bottom: 15.0),
        child: FlatButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(
                  color: pendingDeposit
                      ? HermezColors.blackTwo
                      : HermezColors.lightGrey)),
          onPressed: () {
            this.onPressed(
              symbol,
              amount.toString(),
            );
          },
          padding: EdgeInsets.all(20.0),
          color:
              pendingDeposit ? HermezColors.blackTwo : HermezColors.lightGrey,
          textColor: pendingDeposit ? Colors.white : Colors.black,

          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        simplified ? this.name : this.symbol,
                        style: TextStyle(
                          color: pendingDeposit
                              ? Colors.white
                              : HermezColors.blackTwo,
                          fontSize: 16,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    simplified
                        ? Container()
                        : pendingDeposit
                            ? Container(
                                padding: EdgeInsets.all(8.0),
                                margin: EdgeInsets.only(top: 8.0),
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
                                      fontWeight: FontWeight.w500,
                                    )),
                              )
                            : Container(
                                padding: EdgeInsets.only(top: 15.0),
                                alignment: Alignment.centerLeft,
                                child: Text(this.name,
                                    style: TextStyle(
                                      color: HermezColors.blueyGreyTwo,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w500,
                                    )),
                              ),
                  ],
                ),
              ),
              isToken == false
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                          Container(
                            child: Text(
                              simplified
                                  ? formatAmount(
                                      currencyFirst
                                          ? (this.price * this.amount)
                                          : this.amount,
                                      currencyFirst
                                          ? defaultCurrency
                                          : this.symbol)
                                  : formatAmount(
                                      currencyFirst ? this.amount : this.price,
                                      this.symbol),
                              style: TextStyle(
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w600,
                                  color: pendingDeposit
                                      ? Colors.white
                                      : HermezColors.blackTwo,
                                  fontSize: 16),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          simplified
                              ? Container()
                              : Container(
                                  padding: EdgeInsets.only(top: 15.0),
                                  child: Text(
                                    formatAmount(
                                        currencyFirst
                                            ? (this.price * this.amount)
                                            : this.amount,
                                        currencyFirst
                                            ? defaultCurrency
                                            : this.symbol),
                                    style: TextStyle(
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w500,
                                      color: HermezColors.blueyGreyTwo,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                        ])
                  : Container(),
            ],
          ), //title to be name of the crypto
        ));
  }

  String formatAmount(double amount, String symbol) {
    double resultValue = 0;
    String result = "";
    String locale = "eu";
    bool isCurrency = false;
    if (symbol == "EUR") {
      locale = 'eu';
      symbol = '€';
      isCurrency = true;
    } else if (symbol == "CNY") {
      locale = 'en';
      symbol = '\¥';
      isCurrency = true;
    } else if (symbol == "USD") {
      locale = 'en';
      symbol = '\$';
      isCurrency = true;
    }
    if (amount != null) {
      double value = amount;
      resultValue += value;
    }
    resultValue =
        double.parse(EthAmountFormatter.removeDecimalZeroFormat(resultValue));
    result = NumberFormat.currency(
            locale: locale,
            symbol: symbol,
            decimalDigits: resultValue % 1 == 0
                ? 0
                : isCurrency
                    ? 2
                    : 6)
        .format(resultValue);
    return result;
  }
}
