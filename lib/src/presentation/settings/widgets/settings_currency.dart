import 'package:flutter/material.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/src/domain/wallets/wallet.dart';
import 'package:hermez/utils/hermez_colors.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class SettingsCurrencyPage extends StatefulWidget {
  SettingsCurrencyPage({Key key, this.store}) : super(key: key);

  final WalletHandler store;

  @override
  _SettingsCurrencyPageState createState() => _SettingsCurrencyPageState();
}

class _SettingsCurrencyPageState extends State<SettingsCurrencyPage> {
  @override
  Widget build(BuildContext context) {
    //final _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      //key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text("Currency conversion",
            style: TextStyle(
                fontFamily: 'ModernEra',
                color: HermezColors.blackTwo,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
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
          color: Colors.white,
          child: ListView.separated(
              shrinkWrap: true,
              itemCount: WalletDefaultCurrency.values.length,
              padding: const EdgeInsets.all(
                  16.0), //add some padding to make it look good
              separatorBuilder: (BuildContext context, int index) {
                return Container(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Divider(color: HermezColors.steel));
              },
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
                              color: HermezColors.blackTwo,
                              fontWeight: FontWeight.w500,
                              fontSize: 16),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    trailing: widget.store.state.defaultCurrency == element
                        ? Radio(
                            groupValue: null,
                            activeColor: HermezColors.blackTwo,
                            value: null,
                            onChanged: (value) {
                              setState(() {
                                widget.store.updateDefaultCurrency(element);
                              });
                            },
                          )
                        : Radio(
                            groupValue: null,
                            value: element.toString().split(".").last,
                            activeColor: HermezColors.blackTwo,
                            onChanged: (value) {
                              setState(() {
                                widget.store.updateDefaultCurrency(element);
                              });
                            },
                          ),
                    onTap: () {
                      setState(() {
                        widget.store.updateDefaultCurrency(element);
                      });
                    }
                    //store.fetchOwnBalance() = Wallet();
                    //Navigator.of(context).pushNamed("/receiver", arguments: ReceiverArguments(ReceiverType.REQUEST));,
                    );
                //return _buildRow(); //build the row widget
              })),
    );
  }
}
