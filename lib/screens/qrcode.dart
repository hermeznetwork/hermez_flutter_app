
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hermez/components/dialog/alert.dart';
import 'package:hermez/constants.dart';
import 'package:hermez/utils/eth_amount_formatter.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/utils/share_utils.dart';
import 'package:hermez_sdk/model/token.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../context/wallet/wallet_handler.dart';
import 'account_selector.dart';
import 'transaction_amount.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

enum QRCodeType { HERMEZ, ETHEREUM, REQUEST_PAYMENT }

class QRCodeArguments {
  final QRCodeType qrCodeType;
  final String title;
  final String code;
  final WalletHandler store;
  final double amount;
  final Token token;
  final bool isReceive;
  QRCodeArguments(
      {this.qrCodeType,
      this.title,
      this.code,
      this.store,
      this.amount,
      this.token,
      this.isReceive = false});
}

class QRCodePage extends StatefulWidget {
  QRCodePage({Key key, this.arguments}) : super(key: key);

  final QRCodeArguments arguments;

  @override
  _QRCodePageState createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  static GlobalKey qrCodeKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    String title;
    if (widget.arguments.qrCodeType == QRCodeType.HERMEZ) {
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
          actions:
          widget.arguments.qrCodeType != QRCodeType.REQUEST_PAYMENT ?
               <Widget>[
                  IconButton(
                    icon: Image.asset("assets/share.png",
                        color: HermezColors.blackTwo,
                        alignment: Alignment.topLeft,
                        height: 20),
                    onPressed: () async {
                      shareScreenshot();
                    },
                  ),
                ] : null
              ),
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
                        RepaintBoundary(
                          key: qrCodeKey,
                          child: QrImage(
                              size: 290,
                              padding: EdgeInsets.all(20),
                              dataModuleStyle: QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: Colors.black),
                              eyeStyle: QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: Colors.black),
                              backgroundColor: HermezColors.lightOrange,
                              data: widget.arguments.code == null
                                  ? (widget.arguments.store.state.txLevel ==
                                              TransactionLevel.LEVEL2
                                          ? "hez:"
                                          : "") +
                                      widget
                                          .arguments.store.state.ethereumAddress
                                  : widget.arguments.code +
                                      (widget.arguments.token != null
                                          ? ':' + widget.arguments.token.symbol
                                          : '') +
                                      (widget.arguments.amount != null &&
                                              widget.arguments.amount > 0
                                          ? ':' +
                                              EthAmountFormatter
                                                  .removeDecimalZeroFormat(
                                                      double.parse(widget
                                                          .arguments.amount
                                                          .toStringAsFixed(6)))
                                          : ''),
                            ),
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Container(
                          width: 250,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              widget.arguments.code == null
                                  ? (widget.arguments.store.state.txLevel ==
                                              TransactionLevel.LEVEL2
                                          ? "hez:"
                                          : "") +
                                      widget.arguments.store.state
                                          .ethereumAddress +
                                      "\n" +
                                      widget
                                          .arguments.store.state.ethereumAddress
                                  : widget.arguments.code.substring(
                                          0,
                                          (widget.arguments.code.length / 2)
                                              .floor()) +
                                      "\n" +
                                      widget.arguments.code.substring(
                                          (widget.arguments.code.length / 2)
                                              .floor(),
                                          widget.arguments.code.length) +
                                      "\n" +
                                      (widget.arguments.token != null
                                          ? ':' + widget.arguments.token.symbol
                                          : widget.arguments.amount != null &&
                                                  widget.arguments.amount > 0
                                              ? ':' +
                                                  widget.arguments.store.state
                                                      .defaultCurrency
                                                      .toString()
                                                      .split('.')
                                                      .last
                                              : '') +
                                      (widget.arguments.amount != null &&
                                              widget.arguments.amount > 0
                                          ? ':' +
                                              EthAmountFormatter
                                                  .removeDecimalZeroFormat(
                                                double.parse(widget
                                                    .arguments.amount
                                                    .toStringAsFixed(widget
                                                                .arguments
                                                                .token !=
                                                            null
                                                        ? 6
                                                        : 2))
                                              )
                                          : ''),
                              style: TextStyle(
                                color: HermezColors.blackTwo,
                                fontSize: 16,
                                height: 1.5,
                                fontFamily: 'ModernEra',
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 44,
                        ),
                      ],
                    ),
                  ),
                )),
            widget.arguments.isReceive
                ? Container()
                : Container(
                    margin: EdgeInsets.only(left: 30, right: 30),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: HermezColors.mediumOrange),
                    padding: EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset("assets/info.svg",
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
                 widget.arguments.qrCodeType != QRCodeType.REQUEST_PAYMENT ? Container(
                    margin: const EdgeInsets.only(
                        left: 30.0, right: 30.0, top: 20.0, bottom: 0.0),
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
                                      : widget.arguments.code +
                                          (widget.arguments.token != null
                                              ? ':' +
                                                  widget.arguments.token.symbol
                                              : '') +
                                          (widget.arguments.amount != null &&
                                                  widget.arguments.amount > 0
                                              ? ':' +
                                                  EthAmountFormatter.removeDecimalZeroFormat(
                                                      double.parse(
                                                          widget.arguments.amount.toStringAsFixed(6)))
                                              : '')));
                              Flushbar(
                                messageText: Text(
                                  'Copied',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: HermezColors.blackTwo,
                                    fontSize: 16,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                boxShadows: [
                                  BoxShadow(
                                    color:
                                        HermezColors.blueyGreyTwo.withAlpha(64),
                                    offset: Offset(0, 4),
                                    blurRadius: 16,
                                    spreadRadius: 0,
                                  ),
                                ],
                                borderColor:
                                    HermezColors.blueyGreyTwo.withAlpha(64),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                backgroundColor: Colors.white,
                                margin: EdgeInsets.all(16.0),
                                duration: Duration(
                                    seconds: FLUSHBAR_AUTO_HIDE_DURATION),
                              ).show(context);
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
                  ): Container(),
                 Container(
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
                            widget.arguments.isReceive ?
                            widget.arguments.qrCodeType ==
                                    QRCodeType.REQUEST_PAYMENT
                                ? shareScreenshot()
                                : Navigator.pushReplacementNamed(
                                    context, "/transaction_amount",
                                    arguments: TransactionAmountArguments(
                                        widget.arguments.store,
                                        widget.arguments.store.state.txLevel,
                                        TransactionType.RECEIVE,
                                        allowChangeLevel: false)) : Navigator.pushNamed(context,
                                "/account_selector",
                                arguments: AccountSelectorArguments(
                                    widget.arguments.qrCodeType ==
                                        QRCodeType.HERMEZ ? TransactionLevel.LEVEL2 : TransactionLevel.LEVEL1,
                                    TransactionType.RECEIVE,
                                    widget.arguments.store));
                          },
                          padding: EdgeInsets.only(
                              top: 18.0, bottom: 18.0, right: 24.0, left: 24.0),
                          textColor: HermezColors.steel,
                          color: Color(0xfff6e9d3),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                widget.arguments.isReceive ? Image.asset(
                                    widget.arguments.qrCodeType ==
                                            QRCodeType.REQUEST_PAYMENT
                                        ? "assets/share.png"
                                        : "assets/deposit.png",
                                    color: HermezColors.steel,
                                    height: 20) : Container(),
                                widget.arguments.isReceive ? SizedBox(width: 8) : Container(),
                                Text(
                                    widget.arguments.isReceive ?
                                    widget.arguments.qrCodeType ==
                                            QRCodeType.REQUEST_PAYMENT
                                        ? "Share payment link"
                                        : "Request payment" : "See supported tokens",
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
          ],
        ),
      ),
    );
  }

  void shareScreenshot() {
    //try {
      RenderRepaintBoundary boundary =
      qrCodeKey.currentContext.findRenderObject();

      // ScreenShot and save
      saveScreenShot(boundary, success: () async {
        String imagePath = await getScreenShotFilePath();
        if (imagePath != null) {
          Share.shareFiles([imagePath],

              text: widget.arguments.qrCodeType == QRCodeType.REQUEST_PAYMENT ?
              'Hello, scan this ' + (widget.arguments.store.state.txLevel ==
                  TransactionLevel.LEVEL2 ? 'Hermez' : 'Ethereum') + ' code to send me ' +
                  EthAmountFormatter.removeDecimalZeroFormat(
                      double.parse(
                          widget.arguments.amount.toStringAsFixed(6))) + ' ' +
                  widget.arguments.token.symbol
                  : 'Hello, here is my ' + (widget.arguments.qrCodeType == QRCodeType.HERMEZ ? 'Hermez' : 'Ethereum') + ' code!',
              subject: (widget.arguments.qrCodeType == QRCodeType.HERMEZ ? 'Hermez' : 'Ethereum') +' QR Code',
              sharePositionOrigin: boundary.localToGlobal(
                  Offset.zero) & boundary.size);
        } else {
          Alert(title: 'Error', text: "QR Code not saved").show(context);
        }

        /*saveScreenShot2SDCard(boundary, success: () {
          //showToast('save ok');
        }, fail: () {
          //showToast('save ok');
        });*/
      }, fail: () {
        Alert(title: 'Error', text: "QR Code not saved").show(context);
        //Alert(title: 'Error', text: e.toString()).show(context);
        //showToast('save fail!');
      });
    }
      /*ui.Image image = await boundary.toImage(pixelRatio: 2);

      final appDir = await syspaths.getApplicationDocumentsDirectory();
      imageFile.copy('${appDir.path}/$fileName');
      ByteData byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      await Share.file('Hermez QR Code', 'hermez_qrcode.png', pngBytes, 'image/png', text: widget.arguments.qrCodeType == QRCodeType.REQUEST_PAYMENT ? 'Hello, scan this Hermez code to send me ' + EthAmountFormatter.removeDecimalZeroFormat(
          double.parse(
              widget.arguments.amount.toStringAsFixed(6))) + ' ' + widget.arguments.token.symbol :'Hello, here is my Hermez code!');*/
    /*} on PlatformException catch (e) {
      print("Exception while taking screenshot:" + e.toString());
      Alert(title: 'Error', text: e.toString()).show(context);
    }*/

}
