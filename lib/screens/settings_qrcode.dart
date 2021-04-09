import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hermez/screens/scanner.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';

import '../context/wallet/wallet_handler.dart';
import '../wallet_transfer_amount_page.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class SettingsQRCodeArguments {
  final String message;
  final WalletHandler store;
  final bool fromHomeScreen;
  SettingsQRCodeArguments(
      {this.message, this.store, this.fromHomeScreen = true});
}

class SettingsQRCodePage extends StatefulWidget {
  SettingsQRCodePage({Key key, this.arguments}) : super(key: key);

  final SettingsQRCodeArguments arguments;

  @override
  _SettingsQRCodePageState createState() => _SettingsQRCodePageState();
}

class _SettingsQRCodePageState extends State<SettingsQRCodePage> {
  static GlobalKey _globalKey = GlobalKey();
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
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () async {
                shareScreenshot();
              },
            ),
          ]),
      body: Container(
        margin: EdgeInsets.only(left: 60.3, right: 60.3),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(
                children: [
                  RepaintBoundary(
                    key: _globalKey,
                    child: QrImage(
                      padding: EdgeInsets.all(0),
                      dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Colors.white),
                      eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.square, color: Colors.white),
                      data: widget.arguments.message == null
                          ? (widget.arguments.store.state.txLevel ==
                                      TransactionLevel.LEVEL2
                                  ? "hez:"
                                  : "") +
                              widget.arguments.store.state.ethereumAddress
                          : widget.arguments.message,
                    ),
                  ),
                  QrImage(
                    padding: EdgeInsets.all(0),
                    dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black),
                    eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.square, color: Colors.black),
                    data: widget.arguments.message == null
                        ? (widget.arguments.store.state.txLevel ==
                                    TransactionLevel.LEVEL2
                                ? "hez:"
                                : "") +
                            widget.arguments.store.state.ethereumAddress
                        : widget.arguments.message,
                  ),
                ],
              ),
              SizedBox(
                height: 33,
              ),
              Text(
                widget.arguments.message == null
                    ? (widget.arguments.store.state.txLevel ==
                                TransactionLevel.LEVEL2
                            ? "hez:"
                            : "") +
                        widget.arguments.store.state.ethereumAddress
                    : widget.arguments.message,
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
                            type: QRCodeScannerType.ALL));
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

  Future<Null> shareScreenshot() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      if (boundary.debugNeedsPaint) {
        Timer(Duration(seconds: 1), () => shareScreenshot());
        return null;
      }
      ui.Image image = await boundary.toImage();
      final directory = (await getExternalStorageDirectory()).path;
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      File imgFile = new File('$directory/screenshot.png');
      imgFile.writeAsBytes(pngBytes);
      final RenderBox box = context.findRenderObject();
      Share.shareFiles(List.filled(1, '$directory/screenshot.png'),
          subject: 'My Code',
          text: 'Hello, here is my Hermez code!',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } on PlatformException catch (e) {
      print("Exception while taking screenshot:" + e.toString());
    }
  }
}
