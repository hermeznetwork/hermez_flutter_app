import 'package:flutter/material.dart';
import 'package:hermez/src/domain/accounts/account.dart';
import 'package:hermez/utils/eth_amount_formatter.dart';
import 'package:hermez/utils/hermez_colors.dart';

class AccountRow extends StatelessWidget {
  AccountRow(
      this.account,
      this.name,
      this.symbol,
      this.price,
      this.defaultCurrency,
      this.amount,
      this.simplified,
      this.currencyFirst,
      this.pendingDeposit,
      this.onPressed);

  final Account account;
  final String name;
  final String symbol;
  final double price;
  final String defaultCurrency;
  final double amount;
  final bool simplified;
  final bool currencyFirst;
  final bool pendingDeposit;
  final void Function(Account account, String tokenId, String amount) onPressed;

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
          onPressed: onPressed != null
              ? () {
                  this.onPressed(
                    account,
                    symbol,
                    amount.toString(),
                  );
                }
              : null,
          padding: EdgeInsets.all(20.0),
          color:
              pendingDeposit ? HermezColors.blackTwo : HermezColors.lightGrey,
          textColor: pendingDeposit ? Colors.white : Colors.black,
          disabledColor:
              pendingDeposit ? HermezColors.blackTwo : HermezColors.lightGrey,
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
              Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      child: Text(
                        simplified
                            ? EthAmountFormatter.formatAmount(
                                currencyFirst
                                    ? (this.price * this.amount)
                                    : this.amount,
                                currencyFirst ? defaultCurrency : this.symbol)
                            : EthAmountFormatter.formatAmount(
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
                                color: HermezColors.blueyGreyTwo,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                  ])
            ],
          ), //title to be name of the crypto
        ));
  }
}
