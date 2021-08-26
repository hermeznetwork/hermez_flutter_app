import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hermez/components/wallet/store_card.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/screens/web_explorer.dart';
import 'package:hermez/utils/hermez_colors.dart';

class StoreItemSelectorArguments {
  WalletHandler store;
  BuildContext parentContext;

  StoreItemSelectorArguments(this.store, this.parentContext);
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
                        Navigator.pushNamed(
                            widget.arguments.parentContext, "/web_explorer",
                            arguments:
                                WebExplorerArguments(widget.arguments.store));
                      },
                      child: StoreCard(
                        HermezColors.lightGrey,
                        "https://cdn.freebiesupply.com/images/large/2x/amazon-logo-transparent.png",
                        height: 120,
                        padding: 10,
                        amount: 50,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: new GestureDetector(
                      onTap: () {
                        /*Navigator.pushNamed(
                            widget.arguments.parentContext, "/web_explorer",
                            arguments:
                                WebExplorerArguments(widget.arguments.store));*/
                      },
                      child: StoreCard(
                        HermezColors.lightGrey,
                        "https://www.freepnglogos.com/uploads/netflix-logo-0.png",
                        height: 120,
                        padding: 10,
                        amount: 10,
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
                        /*Navigator.pushNamed(
                            widget.arguments.parentContext, "/web_explorer",
                            arguments:
                                WebExplorerArguments(widget.arguments.store));*/
                      },
                      child: StoreCard(
                        HermezColors.lightGrey,
                        "https://upload.wikimedia.org/wikipedia/commons/c/c5/Ikea_logo.svg",
                        height: 120,
                        padding: 10,
                        amount: 75,
                        enabled: false,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: new GestureDetector(
                      onTap: () {
                        /*Navigator.pushNamed(
                            widget.arguments.parentContext, "/web_explorer",
                            arguments:
                                WebExplorerArguments(widget.arguments.store));*/
                      },
                      child: StoreCard(
                        HermezColors.lightGrey,
                        "https://upload.wikimedia.org/wikipedia/commons/2/26/Spotify_logo_with_text.svg",
                        height: 120,
                        padding: 10,
                        amount: 15,
                        enabled: false,
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
                          /*Navigator.pushNamed(
                              widget.arguments.parentContext, "/web_explorer",
                              arguments:
                                  WebExplorerArguments(widget.arguments.store));*/
                        },
                        child: StoreCard(
                          HermezColors.lightGrey,
                          "https://cdn.freelogovectors.net/wp-content/uploads/2016/12/airbnb-logo.png",
                          height: 120,
                          padding: 10,
                          amount: 100,
                          enabled: false,
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
}
