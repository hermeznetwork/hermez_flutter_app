import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/screens/pin.dart';
import 'package:hermez/utils/hermez_colors.dart';

class RemoveAccountInfoArguments {
  final WalletHandler store;

  RemoveAccountInfoArguments(this.store);
}

class RemoveAccountInfoPage extends HookWidget {
  RemoveAccountInfoPage(this.arguments);

  RemoveAccountInfoArguments arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Remove account",
            style: TextStyle(
                fontFamily: 'ModernEra',
                color: HermezColors.blackTwo,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: HermezColors.lightOrange,
      ),
      backgroundColor: HermezColors.lightOrange,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: new Center(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 65, right: 65),
                      child: Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/remove_account_warning.png',
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    Container(
                      margin: EdgeInsets.only(left: 24, right: 24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            'This will remove your account from this device. '
                            'If you didn’t make a backup and saved your '
                            'recovery phrase, you won’t be able to '
                            'restore your account after that.',
                            style: TextStyle(
                              color: HermezColors.blackTwo,
                              fontSize: 20,
                              height: 1.5,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ),
                  ],
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
                          .pushNamed("/pin",
                              arguments:
                                  PinArguments("Remove account", false, null))
                          .then(
                        (value) async {
                          if (value.toString() == 'true') {
                            await arguments.store.resetWallet();
                            Navigator.pushNamedAndRemoveUntil(
                                context, "/", (Route<dynamic> route) => false);
                          }
                        },
                      );
                    },
                    padding: EdgeInsets.only(
                        top: 18.0, bottom: 18.0, right: 24.0, left: 24.0),
                    disabledTextColor: Colors.grey,
                    disabledColor: Colors.blueGrey,
                    color: Colors.white,
                    textColor: HermezColors.blackTwo,
                    child: Text("Remove account",
                        style: TextStyle(
                          color: HermezColors.blackTwo,
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
                      Navigator.of(context).pop();
                    },
                    padding: EdgeInsets.only(
                        top: 18.0, bottom: 18.0, right: 24.0, left: 24.0),
                    disabledTextColor: Colors.grey,
                    textColor: HermezColors.blackTwo,
                    child: Text("Cancel",
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
    );
  }
}
