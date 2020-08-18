import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'context/wallet/wallet_handler.dart';
import 'wallet_receiver_page.dart';
import 'context/wallet/wallet_provider.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class SettingsQRCodePage extends HookWidget {

  @override
  Widget build(BuildContext context) {
    var store = useWallet(context);
    useEffect(() {
      store.initialise();
      return null;
    }, []);
    return Scaffold(
      appBar: AppBar(
        title: Text("QR code"),
        elevation: 0),
      body: SafeArea(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: QrImage(
                data: store.state.address,
                size: 230.0,
            ))
          ),
        ],
      ),
    ),
    );
  }
}




