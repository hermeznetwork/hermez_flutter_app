import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hermez/components/wallet/store_card.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/service/network/model/bitrefill_item.dart';
import 'package:hermez/utils/hermez_colors.dart';

import '../constants.dart';
import 'bitrefill_form.dart';

class StoreItemSelectorArguments {
  WalletHandler store;
  BuildContext parentContext;
  Color vendorColor;

  StoreItemSelectorArguments(this.store, this.parentContext, this.vendorColor);
}

class StoreItemSelectorPage extends StatefulWidget {
  StoreItemSelectorPage({Key key, this.arguments}) : super(key: key);

  final StoreItemSelectorArguments arguments;

  @override
  _StoreItemSelectorPageState createState() => _StoreItemSelectorPageState();
}

class _StoreItemSelectorPageState extends State<StoreItemSelectorPage> {
  @override
  Widget build(BuildContext context) {
    final String currency =
        widget.arguments.store.state.defaultCurrency.toString().split('.').last;

    return Scaffold(
      appBar: new AppBar(
        title: new Text("Select item",
            style: TextStyle(
                fontFamily: 'ModernEra',
                color: HermezColors.blackTwo,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        centerTitle: true,
        elevation: 0.0,
        leading: new Container(),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop(false);
              }),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
              children: ListTile.divideTiles(
                  context: context,
                  color: HermezColors.transparent,
                  tiles: [
                Row(children: [
                  Expanded(
                    child: new GestureDetector(
                      onTap: () {
                        List<BitrefillItem> _items = [];
                        BitrefillItem item = BitrefillItem(
                            id: "80be3cbc-564c-4568-8f35-c46795bafdd5",
                            slug: "amazon_es-spain",
                            name: "Amazon.es Spain",
                            baseName: "Amazon.es",
                            iconImage: "amazon-icon",
                            iconVersion: "1557911836",
                            recipient: "raul@iden3.com",
                            amount: 1,
                            value: 5,
                            displayValue: "€5.00",
                            currency: "EUR",
                            giftInfo: null);

                        _items.add(item);

                        Navigator.pushNamed(context, '/bitrefill_form',
                            arguments: BitrefillFormArguments(
                                _items, widget.arguments.store));
                        /*Navigator.pushNamed(
                            widget.arguments.parentContext, "/web_explorer",
                            arguments:
                                WebExplorerArguments(widget.arguments.store));*/
                      },
                      child: StoreCard(
                        HermezColors.lightGrey,
                        "https://cdn.freebiesupply.com/images/large/2x/amazon-logo-transparent.png",
                        height: 120,
                        padding: 10,
                        amount: 5,
                        currency: currency,
                        vendorColor: widget.arguments.vendorColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: new GestureDetector(
                      onTap: () {
                        showServiceAvailableSoonFlush();
                      },
                      child: StoreCard(
                        HermezColors.lightGrey,
                        "https://www.freepnglogos.com/uploads/netflix-logo-0.png",
                        height: 120,
                        padding: 10,
                        amount: 10,
                        currency: currency,
                        vendorColor: widget.arguments.vendorColor,
                        enabled: false,
                      ),
                    ),
                  ),
                ]),
                SizedBox(
                  height: 15,
                ),
                Row(children: [
                  Expanded(
                    child: new GestureDetector(
                      onTap: () {
                        showServiceAvailableSoonFlush();
                      },
                      child: StoreCard(
                        HermezColors.lightGrey,
                        "https://upload.wikimedia.org/wikipedia/commons/c/c5/Ikea_logo.svg",
                        height: 120,
                        padding: 10,
                        amount: 75,
                        currency: currency,
                        enabled: false,
                        vendorColor: widget.arguments.vendorColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: new GestureDetector(
                      onTap: () {
                        showServiceAvailableSoonFlush();
                      },
                      child: StoreCard(
                        HermezColors.lightGrey,
                        "https://upload.wikimedia.org/wikipedia/commons/2/26/Spotify_logo_with_text.svg",
                        height: 120,
                        padding: 10,
                        amount: 15,
                        currency: currency,
                        enabled: false,
                        vendorColor: widget.arguments.vendorColor,
                      ),
                    ),
                  ),
                ]),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Expanded(
                      child: new GestureDetector(
                        onTap: () {
                          showServiceAvailableSoonFlush();
                        },
                        child: StoreCard(
                          HermezColors.lightGrey,
                          "https://cdn.freelogovectors.net/wp-content/uploads/2016/12/airbnb-logo.png",
                          height: 120,
                          padding: 10,
                          amount: 100,
                          currency: currency,
                          enabled: false,
                          vendorColor: widget.arguments.vendorColor,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                        child:
                            Container() /*StoreCard(
                          HermezColors.lightGrey,
                          "https://upload.wikimedia.org/wikipedia/commons/2/26/Spotify_logo_with_text.svg",
                          height: 130,
                          padding: 25,
                        ),*/
                        ),
                  ],
                ),
              ]).toList()),
        ),
      ),
    );
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
