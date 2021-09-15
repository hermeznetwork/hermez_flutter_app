import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez/utils/hermez_colors.dart';

class CategoryTag extends StatelessWidget {
  CategoryTag(
      {this.transactionLevel,
      this.onPressed,
      this.title = 'All',
      this.selected = false});

  final TransactionLevel transactionLevel;
  final void Function() onPressed;
  final String title;
  final bool selected;

  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 3, right: 3),
        child: TextButton(
          style: TextButton.styleFrom(
            primary: Colors.white,
            padding: EdgeInsets.only(left: 12, right: 12),
            backgroundColor:
                selected ? HermezColors.blueyGrey : HermezColors.lightGrey,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () async {},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: selected ? Colors.white : HermezColors.blueyGreyTwo,
                  fontSize: 12,
                  fontFamily: 'ModernEra',
                  fontWeight: FontWeight.w500,
                ),
              ),
              /*SizedBox(
            width: 4,
          ),
          new Icon(
            Icons.close,
            color: Colors.white,
            size: 15,
          ),*/
            ],
          ),
        ));
  }
}
