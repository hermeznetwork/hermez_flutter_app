import 'package:hermez/model/wallet.dart';
import 'package:flutter/material.dart';
import 'context/wallet/wallet_handler.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class SettingsCurrencyPage extends StatefulWidget {
  SettingsCurrencyPage({Key key, this.store}) : super(key : key);

  final WalletHandler store;

  @override
  _SettingsCurrencyPageState createState() => _SettingsCurrencyPageState();
}

class _SettingsCurrencyPageState extends State<SettingsCurrencyPage> {

//class SettingsCurrencyPage extends HookWidget {

  //WalletHandler store;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.store.initialise();
  }

  @override
  Widget build(BuildContext context) {
    //widget.store = useWallet(context);
    /*useEffect(() {

      return null;
    }, []);*/

    final _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Default currency"),
        elevation: 0),
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
              padding:
              const EdgeInsets.all(16.0), //add some padding to make it look good
              itemBuilder: (context, i) {
                //item builder returns a row for each index i=0,1,2,3,4
                // if (i.isOdd) return Divider(); //if index = 1,3,5 ... return a divider to make it visually appealing

                // final index = i ~/ 2; //get the actual index excluding dividers.
                final index = i;
                print(index);

                dynamic element = WalletDefaultCurrency.values.elementAt(index);
                //final MaterialColor color = _colors[index %
                //    _colors.length]; //iterate through indexes and get the next colour
                return ListTile(
                    title: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.only(left:5.0, top: 30.0, bottom: 30.0),
                        child: Text(element.toString().split(".").last,
                          style: TextStyle(fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w800,
                              fontSize: 16)
                          ,textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    trailing: widget.store.state.defaultCurrency == element ? Container(
                        padding: EdgeInsets.only(right:10.0, top: 10.0,),
                        child:  Icon(Icons.check)) : null,
                    onTap: ()  {
                      setState(() {
                        widget.store.updateDefaultCurrency(element);
                      });
                    }
                  //store.fetchOwnBalance() = Wallet();
                  //Navigator.of(context).pushNamed("/receiver", arguments: ReceiverArguments(ReceiverType.REQUEST));,
                );
                //return _buildRow(); //build the row widget
              })
      ),
    );
  }
}




