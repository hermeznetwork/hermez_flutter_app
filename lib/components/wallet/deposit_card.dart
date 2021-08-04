import 'package:flutter/material.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez/utils/hermez_colors.dart';

class DepositCard extends StatelessWidget {
  DepositCard(this.txLevel);

  final TransactionLevel txLevel;

  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: this.txLevel == TransactionLevel.LEVEL2
              ? HermezColors.darkOrange
              : HermezColors.blueyGreyTwo),
      padding: EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  (this.txLevel == TransactionLevel.LEVEL2
                          ? 'Hermez'
                          : 'Ethereum') +
                      ' wallet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'ModernEra',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: this.txLevel == TransactionLevel.LEVEL2
                        ? HermezColors.orange
                        : Colors.white),
                padding:
                    EdgeInsets.only(left: 12.0, right: 12.0, top: 6, bottom: 6),
                child: Text(
                  this.txLevel == TransactionLevel.LEVEL2 ? 'L2' : 'L1',
                  style: TextStyle(
                    color: HermezColors.blackTwo,
                    fontSize: 15,
                    fontFamily: 'ModernEra',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/deposit3.png',
                  width: 75,
                  height: 75,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(
                this.txLevel == TransactionLevel.LEVEL2
                    ? 'assets/hermez_logo_white.png'
                    : 'assets/ethereum_logo.png',
                width: 30,
                height: 30,
              )
            ],
          ),
        ],
      ),
    );
  }
}
