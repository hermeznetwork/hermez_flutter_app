import 'package:flutter/material.dart';
import 'package:hermez/utils/eth_amount_formatter.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_sdk/model/account.dart';
import 'package:hermez_sdk/model/token.dart';

class AccountRow extends StatelessWidget {
  AccountRow(
      this.account,
      this.token,
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

  final Account account;
  final Token token;
  final String name;
  final String symbol;
  final double price;
  final String defaultCurrency;
  final double amount;
  final bool simplified;
  final bool currencyFirst;
  final bool pendingDeposit;
  final bool isToken;
  final void Function(
      Account account, Token token, String tokenId, String amount) onPressed;

  Widget build(BuildContext context) {
    String status = "Pending";
    Color statusColor = HermezColors.warning;
    Color statusBackgroundColor = HermezColors.warningBackground;

    return Container(
        padding: EdgeInsets.only(bottom: 15.0),
        child: FlatButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(
                  color: pendingDeposit
                      ? HermezColors.darkTwo
                      : HermezColors.quaternaryThree)),
          onPressed: onPressed != null
              ? () {
                  this.onPressed(
                    account,
                    token,
                    symbol,
                    amount.toString(),
                  );
                }
              : null,
          padding: EdgeInsets.all(20.0),
          color:
              pendingDeposit ? HermezColors.darkTwo : HermezColors.quaternaryThree,
          textColor: pendingDeposit ? Colors.white : Colors.black,
          disabledColor:
              pendingDeposit ? HermezColors.darkTwo : HermezColors.quaternaryThree,
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
                              : HermezColors.darkTwo,
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
                                      color: HermezColors.quaternaryTwo,
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
                                  ? EthAmountFormatter.formatAmount(
                                      currencyFirst
                                          ? (this.price * this.amount)
                                          : this.amount,
                                      currencyFirst
                                          ? defaultCurrency
                                          : this.symbol)
                                  : EthAmountFormatter.formatAmount(
                                      currencyFirst ? this.amount : this.price,
                                      this.symbol),
                              style: TextStyle(
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w600,
                                  color: pendingDeposit
                                      ? Colors.white
                                      : HermezColors.darkTwo,
                                  fontSize: 16),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          simplified
                              ? Container()
                              : Container(
                                  padding: EdgeInsets.only(top: 15.0),
                                  child: Text(
                                    EthAmountFormatter.formatAmount(
                                        currencyFirst
                                            ? (this.price * this.amount)
                                            : this.amount,
                                        currencyFirst
                                            ? defaultCurrency
                                            : this.symbol),
                                    style: TextStyle(
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w500,
                                      color: HermezColors.quaternaryTwo,
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
}
