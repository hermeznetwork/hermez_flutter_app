import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/context/setup/wallet_setup_provider.dart';
import 'package:hermez/screens/pin.dart';
import 'package:hermez/utils/hermez_colors.dart';

import 'info.dart';

/*class IntroPage extends StatefulWidget {
  IntroPage({Key key, this.store}) : super(key: key);

  WalletSetupHandler store;

  @override
  _IntroPageState createState() => _IntroPageState();
}*/

class IntroPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final store = useWalletSetup(context);
    return Scaffold(
      appBar: new AppBar(
        elevation: 0.0,
        backgroundColor: HermezColors.lightOrange,
      ),
      backgroundColor: HermezColors.lightOrange,
      body: SafeArea(
        child: Container(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: new Center(
                  child: SingleChildScrollView(
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/intro_hermez_logo.png',
                          width: 120,
                          height: 120,
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: EdgeInsets.all(30.0),
                          child: Text(
                            'Secure wallet for low-cost\n token transfers',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: HermezColors.steel,
                              fontSize: 18,
                              height: 1.8,
                              decoration: TextDecoration.none,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                    left: 30.0, right: 30.0, top: 30.0, bottom: 0.0),
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(
                          "/pin",
                          arguments: PinArguments(null, true, null),
                        )
                            .then((value) async {
                          if (value.toString() == 'true') {
                            String mnemonic = await store.generateMnemonic();
                            Navigator.of(context)
                                .pushNamed("/info",
                                    arguments: InfoArguments(
                                        "info_backup_success.png",
                                        false,
                                        "Your wallet has been created",
                                        iconSize: 300))
                                .then((value) =>
                                    Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        "/home",
                                        (Route<dynamic> route) => false));
                          }
                        });
                      },
                      padding: EdgeInsets.only(
                          top: 18.0, bottom: 18.0, right: 24.0, left: 24.0),
                      disabledTextColor: Colors.grey,
                      disabledColor: Colors.blueGrey,
                      color: HermezColors.darkOrange,
                      textColor: Colors.white,
                      child: Text("Create new wallet",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                    left: 30.0, right: 30.0, top: 20.0, bottom: 20.0),
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed("/import");
                      },
                      padding: EdgeInsets.only(
                          top: 18.0, bottom: 18.0, right: 24.0, left: 24.0),
                      disabledTextColor: Colors.grey,
                      textColor: HermezColors.blackTwo,
                      child: Text("Import a wallet",
                          style: TextStyle(
                            color: HermezColors.blackTwo,
                            fontSize: 16,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
