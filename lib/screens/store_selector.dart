import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hermez/components/wallet/store_card.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/screens/web_explorer.dart';
import 'package:hermez/utils/hermez_colors.dart';

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
              children: ListTile.divideTiles(
                  context: context,
                  color: HermezColors.blueyGreyThree,
                  tiles: [
                new GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                          widget.arguments.parentContext, "/web_explorer",
                          arguments:
                              WebExplorerArguments(widget.arguments.store));
                    },
                    child: StoreCard(HermezColors.vendorBitrefill)),
              ]).toList()),
        ),
      ),
    );
  }
}
