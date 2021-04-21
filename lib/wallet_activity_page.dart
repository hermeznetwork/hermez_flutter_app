import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/model/wallet.dart';

import 'context/wallet/wallet_handler.dart';
import 'context/wallet/wallet_provider.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class WalletActivityPage extends HookWidget {
  WalletActivityPage(this.title);

  final String title;

  WalletHandler store;

  @override
  Widget build(BuildContext context) {
    store = useWallet(context);
    useEffect(() {
      store.initialise();
      return null;
    }, []);

    //final _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      //key: _scaffoldKey,
      appBar: AppBar(title: Text(title), elevation: 0),
      body: Column(
        children: <Widget>[
          buildCurrencyList(),
        ],
      ),
    );
  }

  //widget that builds the list
  Widget buildCurrencyList() {
    return Expanded(
      child: Container(
          color: Colors.grey[100],
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: WalletDefaultCurrency.values.length,
              padding: const EdgeInsets.all(
                  16.0), //add some padding to make it look good
              itemBuilder: (context, i) {
                //item builder returns a row for each index i=0,1,2,3,4
                // if (i.isOdd) return Divider(); //if index = 1,3,5 ... return a divider to make it visually appealing

                // final index = i ~/ 2; //get the actual index excluding dividers.
                final index = i;

                dynamic element = WalletDefaultCurrency.values.elementAt(index);
                //final MaterialColor color = _colors[index %
                //    _colors.length]; //iterate through indexes and get the next colour
                return ListTile(
                    title: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding:
                            EdgeInsets.only(left: 5.0, top: 30.0, bottom: 30.0),
                        child: Text(
                          element.toString().split(".").last,
                          style: TextStyle(
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w800,
                              fontSize: 16),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    trailing: store.state.defaultCurrency == element
                        ? Container(
                            padding: EdgeInsets.only(
                              right: 10.0,
                              top: 10.0,
                            ),
                            child: Icon(Icons.check))
                        : null,
                    onTap: () {
                      store.updateDefaultCurrency(element);
                    }
                    //store.fetchOwnBalance() = Wallet();
                    //Navigator.of(context).pushNamed("/receiver", arguments: ReceiverArguments(ReceiverType.REQUEST));,
                    );
                //return _buildRow(); //build the row widget
              })),
    );
  }
}
