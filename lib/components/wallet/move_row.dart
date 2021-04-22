import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez/utils/hermez_colors.dart';

class MoveRow extends StatelessWidget {
  MoveRow(this.transactionLevel, this.onPressed);

  final TransactionLevel transactionLevel;
  final void Function() onPressed;

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  'From ' +
                      (transactionLevel == TransactionLevel.LEVEL1
                          ? 'Ethereum'
                          : 'Hermez'),
                  style: TextStyle(
                    color: HermezColors.blackTwo,
                    fontSize: 16,
                    fontFamily: 'ModernEra',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: HermezColors.lightGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    (transactionLevel == TransactionLevel.LEVEL1
                        ? 'assets/ethereum_logo.png'
                        : 'assets/hermez_logo.png'),
                    width: 30,
                    height: 30,
                  ),
                ),
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.only(left: 7, top: 21),
              child: TextButton.icon(
                  onPressed: () {
                    if (onPressed != null) {
                      onPressed();
                    }
                  },
                  icon: Image.asset(onPressed != null
                      ? "assets/change_move_enable.png"
                      : "assets/change_move_disable.png"),
                  label: Text(""))),
          Expanded(
            child: Column(
              children: [
                Text(
                  'To ' +
                      (transactionLevel == TransactionLevel.LEVEL1
                          ? 'Hermez'
                          : 'Ethereum'),
                  style: TextStyle(
                    color: HermezColors.blackTwo,
                    fontSize: 16,
                    fontFamily: 'ModernEra',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: HermezColors.lightGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    (transactionLevel == TransactionLevel.LEVEL1
                        ? 'assets/hermez_logo.png'
                        : 'assets/ethereum_logo.png'),
                    width: 30,
                    height: 30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
