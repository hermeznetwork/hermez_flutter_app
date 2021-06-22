import 'package:flutter/material.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/screens/qrcode.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_sdk/addresses.dart';

class FirstDepositArguments {
  final WalletHandler store;
  final bool showHermezWallet;

  FirstDepositArguments(this.store, {this.showHermezWallet = false});
}

class FirstDepositPage extends StatefulWidget {
  FirstDepositPage({this.arguments, Key key}) : super(key: key);

  final FirstDepositArguments arguments;

  @override
  _FirstDepositPageState createState() => _FirstDepositPageState();
}

class _FirstDepositPageState extends State<FirstDepositPage> {
  @override
  void initState() {
    initialize();
    super.initState();
  }

  Future<void> initialize() async {
    if (widget.arguments.store.state.walletInitialized == false &&
        widget.arguments.store.state.loading == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Add Your Code here.
        widget.arguments.store.initialise();
      });
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: new AppBar(
            elevation: 0.0,
            backgroundColor: HermezColors.lightOrange,
            actions: <Widget>[
              !Navigator.canPop(context)
                  ? new IconButton(
                      icon: new Icon(Icons.close),
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, "/home", (Route<dynamic> route) => false,
                            arguments: true);
                      })
                  : Container(),
            ],
          ),
          backgroundColor: HermezColors.lightOrange,
          body: SafeArea(
              child: Container(
            margin: EdgeInsets.all(20.0),
            child: Column(children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Make your first deposit',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: HermezColors.blackTwo,
                    fontSize: 20,
                    height: 1.5,
                    fontFamily: 'ModernEra',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              new GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    "/qrcode",
                    arguments: QRCodeArguments(
                      qrCodeType: QRCodeType.HERMEZ,
                      code: getHermezAddress(
                          widget.arguments.store.state.ethereumAddress),
                      store: widget.arguments.store,
                    ),
                  );
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: HermezColors.darkOrange),
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Hermez wallet',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'ModernEra',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                color: HermezColors.orange),
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 6, bottom: 6),
                            child: Text(
                              'L2',
                              style: TextStyle(
                                color: HermezColors.blackTwo,
                                fontSize: 15,
                                fontFamily: 'ModernEra',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/deposit3.png',
                              width: 75,
                              height: 75,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Image.asset(
                            'assets/hermez_logo_white.png',
                            width: 30,
                            height: 30,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              new GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    "/qrcode",
                    arguments: QRCodeArguments(
                      qrCodeType: QRCodeType.ETHEREUM,
                      code: widget.arguments.store.state.ethereumAddress,
                      store: widget.arguments.store,
                    ),
                  );
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: HermezColors.blueyGreyTwo),
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Ethereum wallet',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'ModernEra',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                color: Colors.white),
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 6, bottom: 6),
                            child: Text(
                              'L1',
                              style: TextStyle(
                                color: HermezColors.blackTwo,
                                fontSize: 15,
                                fontFamily: 'ModernEra',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/deposit3.png',
                              width: 75,
                              height: 75,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Image.asset(
                            'assets/ethereum_logo.png',
                            width: 30,
                            height: 30,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          )),
        ),
        onWillPop: () async {
          if (!Navigator.canPop(context)) {
            Navigator.pushNamedAndRemoveUntil(
                context, "/home", (Route<dynamic> route) => false,
                arguments: widget.arguments.showHermezWallet);
            return false;
          } else {
            return true;
          }
        });
  }
}
