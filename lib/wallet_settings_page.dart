import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'context/wallet/wallet_handler.dart';
import 'context/wallet/wallet_provider.dart';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class SettingsPage extends HookWidget {
  WalletHandler store;

  @override
  Widget build(BuildContext context) {
    //StateContainer result = useState(0);
    store = useWallet(context);
    useEffect(() {
      store.initialiseReadOnly();
      return null;
    }, [store]);
    final _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text("Settings"), elevation: 0),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.only(left: 20.0, top: 40.0, bottom: 10.0),
                child: Text(
                  "Copy address",
                  style: TextStyle(
                      fontFamily: 'ModernEra',
                      fontWeight: FontWeight.w800,
                      fontSize: 16),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            ListTile(
                title: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: Colors.grey[300])),
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: store.state.address));
                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text("Copied"),
                      ));
                    },
                    padding: EdgeInsets.all(6.0),
                    color: Colors.grey[300],
                    textColor: Colors.black,
                    child: ListTile(
                      // get the first letter of each crypto with the color
                      title: Text(store.state.address ?? "",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          )),
                      trailing: Icon(Icons.content_copy),
                    ))),
            ListTile(
              title: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 5.0, top: 30.0, bottom: 30.0),
                  child: Text(
                    "View QR code",
                    style: TextStyle(
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w800,
                        fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              trailing: Container(
                  padding: EdgeInsets.only(
                    right: 10.0,
                    top: 10.0,
                  ),
                  child: Icon(Icons.arrow_forward_ios)),
              onTap: () {
                Navigator.of(context).pushNamed("/qrcode");
              },
            ),
            Container(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Divider(
                  color: Colors.grey,
                )),
            ListTile(
              title: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 5.0, top: 30.0, bottom: 30.0),
                  child: Text(
                    "Open wallet in block explorer",
                    style: TextStyle(
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w800,
                        color: Colors.grey,
                        fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Divider(
                  color: Colors.grey,
                )),
            ListTile(
              title: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 5.0, top: 30.0, bottom: 30.0),
                  child: Text(
                    "Default currency - " +
                        store.state.defaultCurrency.toString().split('.').last,
                    style: TextStyle(
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w800,
                        fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              trailing: Container(
                  padding: EdgeInsets.only(
                    right: 10.0,
                    top: 10.0,
                  ),
                  child: Icon(Icons.arrow_forward_ios)),
              onTap: () {
                Navigator.of(context)
                    .pushNamed("/currency_selector", arguments: store);
              },
            ),
            Container(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Divider(
                  color: Colors.grey,
                )),
            ListTile(
              title: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 5.0, top: 30.0, bottom: 30.0),
                  child: Text(
                    "Force exit (advanced)",
                    style: TextStyle(
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w800,
                        fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              trailing: Container(
                  padding: EdgeInsets.only(
                    right: 10.0,
                    top: 10.0,
                  ),
                  child: Icon(Icons.arrow_forward_ios)),
              onTap: () {
                //Navigator.of(context).pushNamed("/receiver", arguments: ReceiverArguments(ReceiverType.REQUEST));
              },
            ),
            Expanded(child: Container()),
            buildButtonRow(context)
          ],
        ),
      ),
    );
  }

  buildButtonRow(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(width: 20.0),
          Expanded(
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Colors.grey[300])),
              onPressed: () async {
                await store.resetWallet();
                //Navigator.popAndPushNamed(context, "/");
                Navigator.pushNamedAndRemoveUntil(
                    context, "/", (Route<dynamic> route) => false);
              },
              padding: EdgeInsets.all(20.0),
              color: Colors.white,
              textColor: Colors.black,
              child: Text("Disconnect wallet",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
          SizedBox(width: 20.0),
        ]);
  }
}
