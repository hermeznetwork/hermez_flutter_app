import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hermez/components/wallet/store_card.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/service/network/model/bitrefill_item.dart';
import 'package:hermez/service/network/model/pay_product.dart';
import 'package:hermez/service/network/model/pay_provider.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../constants.dart';

class StoreItemSelectorArguments {
  WalletHandler store;
  BuildContext parentContext;
  PayProvider provider;
  Color vendorColor;

  StoreItemSelectorArguments(
      this.store, this.parentContext, this.provider, this.vendorColor);
}

class StoreItemSelectorPage extends StatefulWidget {
  StoreItemSelectorPage({Key key, this.arguments}) : super(key: key);

  final StoreItemSelectorArguments arguments;

  @override
  _StoreItemSelectorPageState createState() => _StoreItemSelectorPageState();
}

class _StoreItemSelectorPageState extends State<StoreItemSelectorPage> {
  List<PayProduct> _products;
  List<BitrefillItem> _items = [];

  @override
  Widget build(BuildContext context) {
    final String currency =
        widget.arguments.store.state.defaultCurrency.toString().split('.').last;

    return Scaffold(
        appBar: new AppBar(
          automaticallyImplyLeading: false,
          title: new Text("Select item",
              style: TextStyle(
                  fontFamily: 'ModernEra',
                  color: HermezColors.blackTwo,
                  fontWeight: FontWeight.w800,
                  fontSize: 20)),
          centerTitle: true,
          elevation: 0.0,
          leading: IconButton(
            icon:
                Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
            onPressed: () => Navigator.pop(context, false),
          ),
          actions: <Widget>[
            Stack(children: [
              new IconButton(
                  icon: new Icon(Icons.shopping_cart_outlined),
                  onPressed: () {
                    showBarModalBottomSheet(
                      context: context,
                      builder: (context) => buildCartList(),
                    );
                  }),
              _items != null && _items.length > 0
                  ? Positioned(
                      bottom: 35,
                      right: 25,
                      child: Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                                left: 6.0, right: 6.0, top: 3.7, bottom: 3.0),
                            decoration: BoxDecoration(
                              color: HermezColors.darkOrange,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(_items.length.toString(),
                                style: TextStyle(
                                    fontFamily: 'ModernEra',
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12)),
                          )
                        ],
                      ),
                    )
                  : Container()
            ]),
          ],
        ),
        backgroundColor: Colors.white,
        body: FutureBuilder(
            future: fetchData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SingleChildScrollView(
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
                                  //List<BitrefillItem> _items = [];
                                  BitrefillItem item = BitrefillItem(
                                      id: _products[0].id.toString(),
                                      slug: _products[0].name,
                                      name: "Amazon.es Spain",
                                      baseName: "Amazon.es",
                                      iconImage: "amazon-icon",
                                      iconVersion: "1557911836",
                                      //recipient: "raul@iden3.com",
                                      amount: 1,
                                      value: 5,
                                      displayValue: "€5.00",
                                      currency: "EUR",
                                      giftInfo: null);
                                  setState(() {
                                    _items.add(item);
                                  });

                                  /*Navigator.pushNamed(
                                          context, '/bitrefill_form',
                                          arguments: BitrefillFormArguments(
                                              widget.arguments.provider,
                                              _items,
                                              widget.arguments.store))
                                      .then((results) {
                                    if (results is PopWithResults) {
                                      PopWithResults popResult = results;
                                      if (popResult.toPage ==
                                          "/store_item_selector") {
                                        // TODO do stuff
                                      } else {
                                        Navigator.of(context).pop(results);
                                      }
                                    }
                                  });*/
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
                );
              } else {
                return new Center(
                  child:
                      new CircularProgressIndicator(color: HermezColors.orange),
                );
              }
            }));
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

  Future<bool> fetchData() async {
    _products = await widget.arguments.store
        .getPayProducts(widget.arguments.provider.id);
    return true;
  }

  Widget buildCartList() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
      return Container(
        color: Colors.white,
        child: ListView.separated(
            shrinkWrap: true,
            itemCount: _items.length,
            padding: const EdgeInsets.all(16.0),
            separatorBuilder: (BuildContext context, int index) {
              return Container(
                padding: const EdgeInsets.all(10.0),
              );
            },
            itemBuilder: (context, i) {
              final index = i;

              BitrefillItem item = _items.elementAt(index);

              return ListTile(
                leading: _getLeadingWidget(item),
                title: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding:
                            EdgeInsets.only(left: 5.0, top: 24.0, bottom: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Text(
                                item.baseName,
                                style: TextStyle(
                                    fontFamily: 'ModernEra',
                                    color: HermezColors.blackTwo,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    item.giftInfo != null
                        ? Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(right: 10),
                            child: SvgPicture.asset(
                              'assets/gift.svg',
                              width: 20,
                              height: 20,
                            ),
                          )
                        : Container(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          child: Text(
                            (item.giftInfo != null
                                    ? ""
                                    : item.amount.toString() + " x ") +
                                item.displayValue,
                            style: TextStyle(
                                fontFamily: 'ModernEra',
                                color: HermezColors.blackTwo,
                                fontWeight: FontWeight.w700,
                                height: 1.71,
                                fontSize: 16),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            _items.removeAt(index);
                          });
                          setModalState(() {});
                        },
                        icon: Icon(Icons.delete)),
                  ],
                ),
              );
            }),
      );
    });
  }

  // takes in an object and color and returns a circle avatar with first letter and required color
  CircleAvatar _getLeadingWidget(BitrefillItem item) {
    return new CircleAvatar(
      radius: 23,
      child: Image.network(
        "https://www.bitrefill.com/content/cn/b_rgb%3Affffff%2Cc_pad%2Ch_64%2Cw_64/v" +
            item.iconVersion +
            "/" +
            item.iconImage +
            ".jpg",
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Center(
            child: new CircularProgressIndicator(color: HermezColors.orange),
          );
        },
        /*errorBuilder: (context, error, stackTrace) =>
            Text('Some errors occurred!'),*/
      ),
    );
  }
}
