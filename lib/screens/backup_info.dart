import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hermez/screens/recovery_phrase.dart';
import 'package:hermez/utils/hermez_colors.dart';

class BackupInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Back up your wallet",
            style: TextStyle(
                fontFamily: 'ModernEra',
                color: HermezColors.dark,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        centerTitle: true,
        elevation: 0.0,
      ),
      backgroundColor: HermezColors.neutralLight,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Center(
                child: new SingleChildScrollView(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: Align(
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'assets/info_backup.svg',
                            width: 300,
                            height: 300,
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      Container(
                        margin: EdgeInsets.only(left: 30, right: 30),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'You are about to see your recovery phrase. '
                              'If your phone gets stolen or lost, '
                              'you can only recover your funds with your recovery phrase.',
                              style: TextStyle(
                                color: HermezColors.dark,
                                fontSize: 18,
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
            ),
            Container(
              margin: const EdgeInsets.only(
                  left: 30.0, right: 30.0, top: 30.0, bottom: 20.0),
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed("/recovery_phrase",
                          arguments: RecoveryPhraseArguments(true));
                    },
                    padding: EdgeInsets.only(
                        top: 18.0, bottom: 18.0, right: 24.0, left: 24.0),
                    disabledTextColor: Colors.grey,
                    disabledColor: Colors.blueGrey,
                    color: HermezColors.primary,
                    textColor: Colors.white,
                    child: Text("Back up now",
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
          ],
        ),
      ),
    );
  }
}
