import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/utils/address_utils.dart';
import 'package:hermez/utils/hermez_colors.dart';

import 'context/wallet/wallet_handler.dart';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class SettingsPage extends HookWidget {
  SettingsPage(this.store);

  WalletHandler store;

  @override
  Widget build(BuildContext context) {
    //StateContainer result = useState(0);
    /*store = useWallet(context);
    useEffect(() {
      store.initialiseReadOnly();
      return null;
    }, [store]);*/
    final _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text("Settings",
            style: TextStyle(
                fontFamily: 'ModernEra',
                color: HermezColors.blackTwo,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: HermezColors.lightOrange,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              color: HermezColors.lightOrange,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.only(top: 44.0, bottom: 20.0),
                  child: Text(
                    "0x" +
                            AddressUtils.strip0x(
                                    store.state.address.substring(0, 6))
                                .toUpperCase() +
                            " ･･･ " +
                            store.state.address
                                .substring(store.state.address.length - 5,
                                    store.state.address.length)
                                .toUpperCase() ??
                        "",
                    style: TextStyle(
                      color: HermezColors.blackTwo,
                      fontSize: 20,
                      fontFamily: 'ModernEra',
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 24.0),
              color: HermezColors.lightOrange,
              child: Align(
                alignment: Alignment.center,
                child: FlatButton(
                  height: 44,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(56.0),
                      side: BorderSide(color: HermezColors.mediumOrange)),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: store.state.address));
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text("Copied"),
                    ));
                  },
                  color: HermezColors.mediumOrange,
                  textColor: HermezColors.steel,
                  child: Wrap(
                    children: [
                      Image.asset(
                        'assets/paste.png',
                        width: 20,
                        height: 20,
                      ),
                      SizedBox(width: 10.0),
                      Text(
                        "Copy",
                        style: TextStyle(
                          color: HermezColors.steel,
                          fontSize: 16,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              /*FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.grey[300])),
                  onPressed: () {

                  },
                  padding: EdgeInsets.all(6.0),
                  color: Colors.grey[300],
                  textColor: Colors.black,
                  child: ListTile(
                    // get the first letter of each crypto with the color
                    title:
                    trailing: Icon(Icons.content_copy),
                  ),
                ),*/
            ),
            SizedBox(
              height: 30,
            ),
            ListTile(
              title: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 5.0, top: 25.0, bottom: 25.0),
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
              leading: Container(
                padding: EdgeInsets.only(
                  top: 12.0,
                ),
                child: Image.asset(
                  "assets/qr_code.png",
                  width: 20,
                  height: 20,
                ),
              ),
              onTap: () {
                Navigator.of(context).pushNamed("/qrcode", arguments: store);
              },
            ),
            ListTile(
              title: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.only(top: 25.0, bottom: 25.0),
                  child: Text(
                    "Currency conversion - " +
                        store.state.defaultCurrency.toString().split('.').last,
                    style: TextStyle(
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w800,
                        fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              leading: Container(
                padding: EdgeInsets.only(
                  top: 12.0,
                ),
                child: Image.asset(
                  "assets/currency_conversion.png",
                  width: 20,
                  height: 20,
                ),
              ),
              onTap: () {
                Navigator.of(context)
                    .pushNamed("/currency_selector", arguments: store);
              },
            ),
            ListTile(
              title: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 5.0, top: 25.0, bottom: 25.0),
                  child: Text(
                    "Force withdrawal",
                    style: TextStyle(
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w800,
                        fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              leading: Container(
                padding: EdgeInsets.only(
                  top: 12.0,
                ),
                child: Image.asset(
                  "assets/force_exit.png",
                  width: 20,
                  height: 20,
                ),
              ),
              onTap: () {
                //Navigator.of(context).pushNamed("/receiver", arguments: ReceiverArguments(ReceiverType.REQUEST));
              },
            ),
            ListTile(
              title: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 5.0, top: 25.0, bottom: 25.0),
                  child: Text(
                    "Disconnect wallet",
                    style: TextStyle(
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w800,
                        fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              leading: Container(
                padding: EdgeInsets.only(
                  top: 12.0,
                ),
                child: Image.asset(
                  "assets/disconnect.png",
                  width: 20,
                  height: 20,
                ),
              ),
              onTap: () async {
                await store.resetWallet();
                //Navigator.popAndPushNamed(context, "/");
                Navigator.pushNamedAndRemoveUntil(
                    context, "/", (Route<dynamic> route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
