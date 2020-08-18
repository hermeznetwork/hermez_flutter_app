import 'package:hermez/components/wallet/activity.dart';
import 'package:hermez/model/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'context/wallet/wallet_handler.dart';
import 'context/wallet/wallet_provider.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class WalletAccountDetailsArguments {
  final dynamic element;
  final Color color;

  WalletAccountDetailsArguments(this.element, this.color);
}

class WalletAccountDetailsPage extends HookWidget {
  WalletAccountDetailsPage(this.arguments);
  final WalletAccountDetailsArguments arguments;

  WalletHandler store;

  @override
  Widget build(BuildContext context) {

    store = useWallet(context);
    useEffect(() {
      store.initialise();
      return null;
    }, []);

    final _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Hermez"),
        backgroundColor: arguments.color.withAlpha(50),
        elevation: 0),
      body: Container(
              color: arguments.color.withAlpha(50),
              child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: SizedBox(
                      width: double.infinity,
                        child: Container(
                          child:
                            Text(arguments.element['name'] + " Account",
                              style: TextStyle(fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w800,
                              fontSize: 24)
                              ,textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                  ),
                SizedBox(height: 20),
                  Padding(
        padding: const EdgeInsets.only(left: 30.0),
          child: SizedBox(
            width: double.infinity,
            child:
    Row(children: <Widget>[
    Text(arguments.element['value'] + " " + arguments.element['symbol'],
    style: TextStyle(fontFamily: 'ModernEra',
    fontWeight: FontWeight.w800,
    fontSize: 40)),
    ])
    ),
    ),
    SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: SizedBox(
                      width: double.infinity,
                      child:
                      Row(children: <Widget>[
                        Text("€984.14",
                            style: TextStyle(fontFamily: 'ModernEra',
                                fontWeight: FontWeight.w500,
                                fontSize: 16)),
                      ])
                  ),
                ),
                SizedBox(height: 20),
    buildButtonsRow(),
    SizedBox(height: 20),
    Container(
    color: Colors.white,
    child:
    Padding(
    padding: const EdgeInsets.only(left: 30.0, top: 20.0),
    child: SizedBox(
    width: double.infinity,
    child: Text(
    "Activity",
    style: TextStyle(fontFamily: 'ModernEra',
    fontWeight: FontWeight.w800,
    fontSize: 18)
    ,textAlign: TextAlign.left,
    ),
    ),
    ),
    ),
                Expanded(
                  child:
                  Activity(
                    address: store.state.address,
                    defaultCurrency: store.state.defaultCurrency,
                    cryptoList: store.state.cryptoList,
                  ),
                )
    ],
    ),
    ));
  }

buildButtonsRow() {
  return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(width: 20.0),
        Expanded(
          child:
          FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(56.0),
                side: BorderSide(color: Colors.grey[300])),
            onPressed: () {
              //Navigator.of(context).pushNamed("/receiver", arguments: ReceiverArguments(ReceiverType.REQUEST));
            },
            padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0, bottom: 15.0),
            color: Colors.white,
            textColor: Colors.black,
            child: Text("Send",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                )),
          ),
        ),
        SizedBox(width: 15.0),
        Expanded(
          child:
          FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(56.0),
                side: BorderSide(color: Colors.grey[300])),
            onPressed: () {
              //Navigator.of(context).pushNamed("/receiver", arguments: ReceiverArguments(ReceiverType.REQUEST));
            },
            padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0, bottom: 15.0),
            color: Colors.white,
            textColor: Colors.black,
            child: Text("Add funds",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                )),
          ),
        ),
        SizedBox(width: 15.0),
        Expanded(
          child:
          FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(56.0),
                side: BorderSide(color: Colors.grey[300])),
            onPressed: () {
              //Navigator.of(context).pushNamed("/receiver", arguments: ReceiverArguments(ReceiverType.SEND));
            },
            color: Colors.white,
            textColor: Colors.black,
            padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0, bottom: 15.0),
            child: Text("Withdrawal",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),),
          ),
        ),
        SizedBox(width: 20.0),
      ]
  );
}
}




