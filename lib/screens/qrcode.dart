
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hermez/components/dialog/alert.dart';
import 'package:hermez/components/wallet/account_row.dart';
import 'package:hermez/constants.dart';
import 'package:hermez/utils/eth_amount_formatter.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/utils/share_utils.dart';
import 'package:hermez_sdk/model/token.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../context/wallet/wallet_handler.dart';
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

  List<Token> _tokens;
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
      backgroundColor: HermezColors.quaternaryThree,
      appBar: new AppBar(
          title: new Text(title,
              style: TextStyle(
                  fontFamily: 'ModernEra',
                  color: HermezColors.darkTwo,
                  fontWeight: FontWeight.w800,
                  fontSize: 20)),
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: HermezColors.quaternaryThree,
          actions:
          widget.arguments.qrCodeType != QRCodeType.REQUEST_PAYMENT ?
               <Widget>[
                  IconButton(
                    icon: Image.asset("assets/share.png",
                        color: HermezColors.darkTwo,
                        alignment: Alignment.topLeft,
                        height: 20),
                    onPressed: () async {
                      shareScreenshot();
                    },
                  ),
                ] : null
              ),
      body: SafeArea(
        child:
        SingleChildScrollView(
        child: Column(
          children: [
            !widget.arguments.isReceive ?
            Container(
              margin: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    widget.arguments.qrCodeType == QRCodeType.HERMEZ ?
                    'Use this code to transfer tokens from another Hermez account.' :
                    'Transfer tokens to your Ethereum wallet first and'
                        ' then move them to your Hermez wallet.',
                    style: TextStyle(
                      color: HermezColors.quaternary,
                      fontSize: 18,
                      height: 1.5,
                      fontFamily: 'ModernEra',
                      fontWeight: FontWeight.w500,
                    )),
              ),
            ): Container( margin: EdgeInsets.only(bottom: 50),
            ), Center(
                    child:RepaintBoundary(
                      key: qrCodeKey,
                      child:Container( color: HermezColors.quaternaryThree,child:
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            QrImage(
                              size: 290,
                              padding: EdgeInsets.all(20),
                              dataModuleStyle: QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: Colors.black),
                              eyeStyle: QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: Colors.black),
                              backgroundColor: HermezColors.quaternaryThree,
                              embeddedImage: AssetImage('assets/hermez_logo_white.png'),
                              embeddedImageStyle: QrEmbeddedImageStyle(
                                size: Size(36, 36),
                              ),
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
                        ],
                        ),
                        Container(
                          width: 290,
                          padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                          color: HermezColors.quaternaryThree,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              widget.arguments.code == null
                                  ? ((widget.arguments.store.state.txLevel ==
                                              TransactionLevel.LEVEL2
                                          ? "hez:"
                                          : "") +
                                  widget.arguments.store.state
                                      .ethereumAddress.substring(
                                                                0,
                                      (widget.arguments.store.state
                                        .ethereumAddress.length / 2)
                                        .floor()) +
                                        "\n" +
                                  widget.arguments.store.state
                                      .ethereumAddress.substring(
                                      (widget.arguments.store.state
                                          .ethereumAddress.length / 2)
                                        .floor(),
                                      widget.arguments.store.state
                                          .ethereumAddress.length))
                                  : (widget.arguments.code.substring(
                                          0,
                                          (widget.arguments.code.length / 2)
                                              .floor()) +
                                      "\n" +
                                      widget.arguments.code.substring(
                                          (widget.arguments.code.length / 2)
                                              .floor(),
                                          widget.arguments.code.length)
                                  +
                                      (widget.arguments.token != null || (widget.arguments.amount != null && widget.arguments.amount > 0)
                                          ? ("\n" + ':')
                                          + (widget.arguments.token != null ? widget.arguments.token.symbol : widget.arguments.store.state
                                              .defaultCurrency
                                              .toString()
                                              .split('.')
                                              .last)
                                          + (widget.arguments.amount != null &&
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
                                              : '') : ''
                                      )),
                              style: TextStyle(
                                color: HermezColors.darkTwo,
                                fontSize: 16,
                                height: 1.5,
                                fontFamily: 'ModernEra',
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ),
          Column(
            children: <Widget>[
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
                                    color: HermezColors.darkTwo,
                                    fontSize: 16,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                boxShadows: [
                                  BoxShadow(
                                    color:
                                        HermezColors.quaternaryTwo.withAlpha(64),
                                    offset: Offset(0, 4),
                                    blurRadius: 16,
                                    spreadRadius: 0,
                                  ),
                                ],
                                borderColor:
                                    HermezColors.quaternaryTwo.withAlpha(64),
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
                            textColor: HermezColors.quaternary,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset("assets/paste.png",
                                      color: HermezColors.quaternary, height: 20),
                                  SizedBox(width: 8),
                                  Text("Copy",
                                      style: TextStyle(
                                        color: HermezColors.quaternary,
                                        fontSize: 16,
                                        fontFamily: 'ModernEra',
                                        fontWeight: FontWeight.w700,
                                      )),
                                ])),
                      ),
                    ),
                  ): Container(),
            widget.arguments.isReceive ?
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
                            widget.arguments.qrCodeType ==
                                    QRCodeType.REQUEST_PAYMENT
                                ? shareScreenshot()
                                : Navigator.pushReplacementNamed(
                                    context, "/transaction_amount",
                                    arguments: TransactionAmountArguments(
                                        widget.arguments.store,
                                        widget.arguments.store.state.txLevel,
                                        TransactionType.RECEIVE,
                                        allowChangeLevel: false));
                          },
                          padding: EdgeInsets.only(
                              top: 18.0, bottom: 18.0, right: 24.0, left: 24.0),
                          textColor: HermezColors.quaternary,
                          color: Color(0xfff6e9d3),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                    widget.arguments.qrCodeType ==
                                            QRCodeType.REQUEST_PAYMENT
                                        ? "assets/share.png"
                                        : "assets/deposit.png",
                                    color: HermezColors.quaternary,
                                    height: 20),
                                SizedBox(width: 8),
                                Text(
                                    widget.arguments.qrCodeType ==
                                            QRCodeType.REQUEST_PAYMENT
                                        ? "Share payment link"
                                        : "Request payment",
                                    style: TextStyle(
                                      color: HermezColors.quaternary,
                                      fontSize: 16,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w700,
                                    )),
                              ]),
                        ),
                      ),
                    ),
                  ) : Container(),
            widget.arguments.isReceive
                ? Container()
                : Container(
              margin: EdgeInsets.only(left: 30, right: 30,top: 20.0, bottom: 20.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: HermezColors.darkTwo),
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset("assets/info.svg",
                      color: Colors.white,
                      alignment: Alignment.topLeft,
                      height: 20,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              child: Text(
                                 "Make sure to receive only tokens that are supported in Hermez",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'ModernEra',
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: HermezColors.quaternary.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () {
                              showBarModalBottomSheet(
                                context: context,
                                builder: (context) => Scaffold(body: FutureBuilder(
                                  future: fetchTokens(),
                                    builder: (buildContext, snapshot) {
                                      return handleTokensList(snapshot, context);
                                    }
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.only(right: 6, left: 6),
                              child: Text(
                                'More info',
                                style: TextStyle(
                                  color: HermezColors.quaternaryThree,
                                  fontSize: 15,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ))

                ],

              ),
            ),
          ],
        ),]),
    )));
  }

  Future<List<Token>> fetchTokens() async {
    return widget.arguments.store.getTokens();
  }

  Widget handleTokensList(AsyncSnapshot snapshot, BuildContext context) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
        child: CircularProgressIndicator(color: HermezColors.secondary),
      );
    } else {
      if (snapshot.hasError) {
        // while data is loading:
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(34.0),
            child: Column(children: [
              Text(
                'There was an error loading \n\n this page.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: HermezColors.quaternary,
                  fontSize: 16,
                  fontFamily: 'ModernEra',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ]));
      } else {
        if (snapshot.hasData && (snapshot.data as List).length > 0) {
            _tokens = snapshot.data;
            return buildTokensList(context);
        }
      }
    }
  }

  //widget that builds the list
  Widget buildTokensList(BuildContext parentContext) {
    return  Column(
      children: [
        SizedBox(
          height: 30,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            Text(
              'Supported tokens in Hermez',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: HermezColors.darkTwo,
                fontSize: 18,
                fontFamily: 'ModernEra',
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 16,
        ),
        Expanded(
          flex: 1,
          child:Container(
            color: Colors.white,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: _tokens.length,
                padding: const EdgeInsets.all(16.0),
                itemBuilder: (context, i) {
                  final index = i;
                  final String currency = widget
                      .arguments.store.state.defaultCurrency
                      .toString()
                      .split('.')
                      .last;
                    final Token token = _tokens[index];
                    return AccountRow(
                        null,
                        token,
                        token.name,
                        token.symbol,
                        currency != "USD"
                            ? token.USD *
                            widget.arguments.store.state.exchangeRatio
                            : token.USD,
                        currency,
                        0,
                        false,
                        true,
                        false,
                        true, null);
                  },
            ),
          ),),
      ],
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
}
