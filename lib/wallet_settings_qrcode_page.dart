import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'context/wallet/wallet_handler.dart';
import 'wallet_transfer_amount_page.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class SettingsQRCodePage extends HookWidget {
  SettingsQRCodePage(this.store);

  WalletHandler store;

  @override
  Widget build(BuildContext context) {
    /*var store = useWallet(context);
    useEffect(() {
      store.initialise();
      return null;
    }, []);*/
    return Scaffold(
      backgroundColor: HermezColors.lightOrange,
      appBar: new AppBar(
        title: new Text("My Address",
            style: TextStyle(
                fontFamily: 'ModernEra',
                color: HermezColors.blackTwo,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: HermezColors.lightOrange,
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(null),
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(left: 60.3, right: 60.3),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              QrImage(
                data: (store.state.txLevel == TransactionLevel.LEVEL2
                        ? "hez:"
                        : "") +
                    store.state.ethereumAddress,
              ),
              SizedBox(
                height: 33,
              ),
              Text(
                (store.state.txLevel == TransactionLevel.LEVEL2 ? "hez:" : "") +
                    store.state.ethereumAddress,
                style: TextStyle(
                  color: HermezColors.blackTwo,
                  fontSize: 16,
                  fontFamily: 'ModernEra',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
