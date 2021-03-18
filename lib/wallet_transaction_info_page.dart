import 'package:flutter/material.dart';
import 'package:hermez/utils/hermez_colors.dart';

import 'context/wallet/wallet_handler.dart';

class TransactionInfoArguments {
  final WalletHandler store;

  TransactionInfoArguments(this.store);
}

class TransactionInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TransactionInfoArguments args =
        ModalRoute.of(context).settings.arguments;
    return Scaffold(
      backgroundColor: HermezColors.lightOrange,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 65, right: 65),
            child: Align(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/success.png',
              ),
            ),
          ),
          SizedBox(height: 32),
          Align(
            alignment: Alignment.center,
            child: Text('Transaction is awaiting verification.',
                style: TextStyle(
                  color: HermezColors.black,
                  fontSize: 20,
                  fontFamily: 'ModernEra',
                  fontWeight: FontWeight.w700,
                )),
          ),
          SizedBox(height: 72),
          Align(
            alignment: Alignment.center,
            child: FlatButton(
              minWidth: 152.0,
              height: 56,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  side: BorderSide(color: HermezColors.darkOrange)),
              onPressed: () {
                args.store.transactionFinished();
                Navigator.pop(context);
              },
              padding: EdgeInsets.all(15.0),
              color: HermezColors.darkOrange,
              textColor: Colors.white,
              child: Text("Done",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'ModernEra',
                    fontWeight: FontWeight.w700,
                  )),
            ),
          )
        ],
      ),
    );
  }
}
