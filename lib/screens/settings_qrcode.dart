import 'package:flutter/material.dart';
import 'package:hermez/screens/scanner.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../context/wallet/wallet_handler.dart';
import '../wallet_transfer_amount_page.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class SettingsQRCodeArguments {
  final WalletHandler store;
  final bool fromHomeScreen;
  SettingsQRCodeArguments({this.store, this.fromHomeScreen = true});
}

class SettingsQRCodePage extends StatefulWidget {
  SettingsQRCodePage({Key key, this.arguments}) : super(key: key);

  final SettingsQRCodeArguments arguments;

  @override
  _SettingsQRCodePageState createState() => _SettingsQRCodePageState();
}

class _SettingsQRCodePageState extends State<SettingsQRCodePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HermezColors.lightOrange,
      appBar: new AppBar(
        title: new Text("My Code",
            style: TextStyle(
                fontFamily: 'ModernEra',
                color: HermezColors.blackTwo,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: HermezColors.lightOrange,
      ),
      body: Container(
        margin: EdgeInsets.only(left: 60.3, right: 60.3),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              QrImage(
                padding: EdgeInsets.all(0),
                dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black),
                eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square, color: Colors.black),
                data: (widget.arguments.store.state.txLevel ==
                            TransactionLevel.LEVEL2
                        ? "hez:"
                        : "") +
                    widget.arguments.store.state.ethereumAddress,
              ),
              SizedBox(
                height: 33,
              ),
              Text(
                (widget.arguments.store.state.txLevel == TransactionLevel.LEVEL2
                        ? "hez:"
                        : "") +
                    widget.arguments.store.state.ethereumAddress,
                style: TextStyle(
                  color: HermezColors.blackTwo,
                  fontSize: 16,
                  height: 1.5,
                  fontFamily: 'ModernEra',
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(
                height: 44,
              ),
              TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.black,
                  backgroundColor: Color(0xfff6e9d3),
                  minimumSize: Size(60, 60),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  if (widget.arguments.fromHomeScreen) {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  } else {
                    Navigator.of(context).pushReplacementNamed("/scanner",
                        arguments: QRCodeScannerArguments(
                          store: widget.arguments.store,
                        ));
                  }
                },
                child: Image.asset("assets/scan.png",
                    color: HermezColors.blueyGreyTwo, height: 20),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "Scan",
                style: TextStyle(
                  color: HermezColors.blackTwo,
                  fontSize: 16,
                  fontFamily: 'ModernEra',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
