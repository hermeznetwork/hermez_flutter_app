import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hermez/components/wallet/store_card.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/screens/store_item_selector.dart';
import 'package:hermez/utils/hermez_colors.dart';

import '../constants.dart';

class StoreSelectorArguments {
  WalletHandler store;
  BuildContext parentContext;

  StoreSelectorArguments(this.store, this.parentContext);
}

class StoreSelectorPage extends StatefulWidget {
  StoreSelectorPage({Key key, this.arguments}) : super(key: key);

  final StoreSelectorArguments arguments;

  @override
  _StoreSelectorPageState createState() => _StoreSelectorPageState();
}

class _StoreSelectorPageState extends State<StoreSelectorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text("Marketplace",
              style: TextStyle(
                  fontFamily: 'ModernEra',
                  color: HermezColors.blackTwo,
                  fontWeight: FontWeight.w800,
                  fontSize: 20)),
          centerTitle: true,
          elevation: 0.0,
          leading: new Container(),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Column(children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                    children: ListTile.divideTiles(
                        context: context,
                        color: HermezColors.transparent,
                        tiles: [
                      new GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(widget.arguments.parentContext,
                                "/store_item_selector",
                                arguments: StoreItemSelectorArguments(
                                    widget.arguments.store,
                                    widget.arguments.parentContext,
                                    HermezColors.vendorBitrefill));
                          },
                          child: StoreCard(HermezColors.vendorBitrefill,
                              "assets/vendor_bitrefill.svg")),
                      SizedBox(
                        height: 20,
                      ),
                      new GestureDetector(
                          onTap: () {
                            showServiceAvailableSoonFlush();
                          },
                          child: StoreCard(
                            HermezColors.vendorCoingate,
                            "assets/vendor_coingate.png",
                            enabled: false,
                          )),
                      SizedBox(
                        height: 20,
                      ),
                      new GestureDetector(
                          onTap: () {
                            showServiceAvailableSoonFlush();
                          },
                          child: StoreCard(
                            HermezColors.vendorBidali,
                            "assets/vendor_bidali.png",
                            enabled: false,
                          )),
                      SizedBox(
                        height: 20,
                      ),
                      new GestureDetector(
                          onTap: () {
                            showServiceAvailableSoonFlush();
                          },
                          child: StoreCard(
                            HermezColors.vendorCryptorefills,
                            "assets/vendor_cryptorefills.png",
                            enabled: false,
                          )),
                    ]).toList()),
              ),
            ),
          )
        ])));
  }

  void showServiceAvailableSoonFlush() {
    Flushbar(
      messageText: Text(
        'Service will be available soon',
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
          color: HermezColors.blueyGreyTwo.withAlpha(64),
          offset: Offset(0, 4),
          blurRadius: 16,
          spreadRadius: 0,
        ),
      ],
      borderColor: HermezColors.blueyGreyTwo.withAlpha(64),
      borderRadius: BorderRadius.all(Radius.circular(12)),
      backgroundColor: Colors.white,
      margin: EdgeInsets.all(16.0),
      duration: Duration(seconds: FLUSHBAR_AUTO_HIDE_DURATION),
    ).show(context);
  }
}
