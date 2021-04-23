import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';

import '../context/wallet/wallet_handler.dart';
import 'transaction_amount.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

enum QRCodeType { HERMEZ, ETHEREUM, RECOVERY_PHRASE, REQUEST_PAYMENT }

class QRCodeArguments {
  final QRCodeType qrCodeType;
  final String title;
  final String code;
  final WalletHandler store;
  final bool isReceive;
  QRCodeArguments(
      {this.qrCodeType,
      this.title,
      this.code,
      this.store,
      this.isReceive = false});
}

class QRCodePage extends StatefulWidget {
  QRCodePage({Key key, this.arguments}) : super(key: key);

  final QRCodeArguments arguments;

  @override
  _QRCodePageState createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  static GlobalKey _globalKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    String title;
    if (widget.arguments.qrCodeType == QRCodeType.RECOVERY_PHRASE) {
      title = "Recovery phrase";
    } else if (widget.arguments.qrCodeType == QRCodeType.HERMEZ) {
      title = "Your Hermez Wallet";
    } else if (widget.arguments.qrCodeType == QRCodeType.ETHEREUM) {
      title = "Your Ethereum Wallet";
    } else {
      title = "Request payment";
    }
    return Scaffold(
      backgroundColor: HermezColors.lightOrange,
      appBar: new AppBar(
          title: new Text(title,
              style: TextStyle(
                  fontFamily: 'ModernEra',
                  color: HermezColors.blackTwo,
                  fontWeight: FontWeight.w800,
                  fontSize: 20)),
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: HermezColors.lightOrange,
          actions: Platform.isAndroid
              ? <Widget>[
                  IconButton(
                    icon: Image.asset("assets/share.png",
                        color: HermezColors.blackTwo,
                        alignment: Alignment.topLeft,
                        height: 20),
                    onPressed: () async {
                      shareScreenshot();
                    },
                  ),
                ]
              : null),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                flex: 1,
                child: new Center(
                  child: SingleChildScrollView(
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Stack(
                          children: [
                            RepaintBoundary(
                              key: _globalKey,
                              child: QrImage(
                                size: 200,
                                padding: EdgeInsets.all(0),
                                dataModuleStyle: QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: Colors.white),
                                eyeStyle: QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: Colors.white),
                                data: widget.arguments.code == null
                                    ? (widget.arguments.store.state.txLevel ==
                                                TransactionLevel.LEVEL2
                                            ? "hez:"
                                            : "") +
                                        widget.arguments.store.state
                                            .ethereumAddress
                                    : widget.arguments.code,
                              ),
                            ),
                            QrImage(
                              size: 200,
                              padding: EdgeInsets.all(0),
                              dataModuleStyle: QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: Colors.black),
                              eyeStyle: QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: Colors.black),
                              data: widget.arguments.code == null
                                  ? (widget.arguments.store.state.txLevel ==
                                              TransactionLevel.LEVEL2
                                          ? "hez:"
                                          : "") +
                                      widget
                                          .arguments.store.state.ethereumAddress
                                  : widget.arguments.code,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 33,
                        ),
                        Container(
                          width: 205,
                          child: Text(
                            widget.arguments.code == null
                                ? (widget.arguments.store.state.txLevel ==
                                            TransactionLevel.LEVEL2
                                        ? "hez:"
                                        : "") +
                                    widget.arguments.store.state.ethereumAddress
                                : widget.arguments.code,
                            style: TextStyle(
                              color: HermezColors.blackTwo,
                              fontSize: 16,
                              height: 1.5,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        SizedBox(
                          height: 44,
                        ),
                      ],
                    ),
                  ),
                )),
            widget.arguments.isReceive ||
                    widget.arguments.qrCodeType == QRCodeType.RECOVERY_PHRASE
                ? Container()
                : Container(
                    margin: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: HermezColors.mediumOrange),
                    padding: EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset("assets/info.png",
                            color: HermezColors.blackTwo,
                            alignment: Alignment.topLeft,
                            height: 20),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                            child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                child: Text(
                                  widget.arguments.qrCodeType ==
                                          QRCodeType.HERMEZ
                                      ? "From Hermez to Hermez"
                                      : "From Ethereum to Hermez",
                                  style: TextStyle(
                                      color: HermezColors.blackTwo,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  widget.arguments.qrCodeType ==
                                          QRCodeType.HERMEZ
                                      ? "Use this code to transfer tokens from another Hermez account."
                                      : "Transfer tokens to your Ethereum wallet first and then move them to your Hermez wallet.",
                                  style: TextStyle(
                                      color: HermezColors.blackTwo,
                                      fontFamily: 'ModernEra',
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ],
                        ))
                      ],
                    ),
                  ),
            widget.arguments.isReceive &&
                    widget.arguments.qrCodeType != QRCodeType.RECOVERY_PHRASE
                ? Container(
                    margin: const EdgeInsets.only(
                        left: 30.0, right: 30.0, top: 30.0, bottom: 0.0),
                    child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: SizedBox(
                        width: double.infinity,
                        child: FlatButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text: widget.arguments.code == null
                                      ? (widget.arguments.store.state.txLevel ==
                                                  TransactionLevel.LEVEL2
                                              ? "hez:"
                                              : "") +
                                          widget.arguments.store.state
                                              .ethereumAddress
                                      : widget.arguments.code));
                              final snackBar =
                                  SnackBar(content: Text('Copied'));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            },
                            padding: EdgeInsets.only(
                                top: 18.0,
                                bottom: 18.0,
                                right: 24.0,
                                left: 24.0),
                            color: Color(0xfff6e9d3),
                            textColor: HermezColors.steel,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset("assets/paste.png",
                                      color: HermezColors.steel, height: 20),
                                  SizedBox(width: 8),
                                  Text("Copy",
                                      style: TextStyle(
                                        color: HermezColors.steel,
                                        fontSize: 16,
                                        fontFamily: 'ModernEra',
                                        fontWeight: FontWeight.w700,
                                      )),
                                ])),
                      ),
                    ),
                  )
                : Container(),
            (widget.arguments.isReceive &&
                        widget.arguments.qrCodeType !=
                            QRCodeType.RECOVERY_PHRASE &&
                        widget.arguments.qrCodeType !=
                            QRCodeType.REQUEST_PAYMENT) ||
                    (widget.arguments.qrCodeType ==
                            QRCodeType.REQUEST_PAYMENT &&
                        Platform.isAndroid)
                ? Container(
                    margin: const EdgeInsets.only(
                        left: 30.0, right: 30.0, top: 20.0, bottom: 20.0),
                    child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: SizedBox(
                        width: double.infinity,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          onPressed: () {
                            widget.arguments.qrCodeType ==
                                    QRCodeType.REQUEST_PAYMENT
                                ? shareScreenshot()
                                : Navigator.pushReplacementNamed(
                                    context, "/transaction_amount",
                                    arguments: TransactionAmountArguments(
                                        widget.arguments.store,
                                        widget.arguments.store.state.txLevel,
                                        TransactionType.RECEIVE));
                          },
                          padding: EdgeInsets.only(
                              top: 18.0, bottom: 18.0, right: 24.0, left: 24.0),
                          textColor: HermezColors.steel,
                          color: Color(0xfff6e9d3),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                    widget.arguments.qrCodeType ==
                                            QRCodeType.REQUEST_PAYMENT
                                        ? "assets/share.png"
                                        : "assets/deposit.png",
                                    color: HermezColors.steel,
                                    height: 20),
                                SizedBox(width: 8),
                                Text(
                                    widget.arguments.qrCodeType ==
                                            QRCodeType.REQUEST_PAYMENT
                                        ? "Share payment link"
                                        : "Request payment",
                                    style: TextStyle(
                                      color: HermezColors.steel,
                                      fontSize: 16,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w700,
                                    )),
                              ]),
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
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
