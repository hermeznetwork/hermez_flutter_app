import 'package:flutter/material.dart';
import 'package:hermez/src/presentation/settings/widgets/recovery_phrase.dart';
import 'package:hermez/utils/hermez_colors.dart';

class BackupInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Back up your wallet",
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
              child: Center(
                child: new SingleChildScrollView(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: Align(
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/info_backup.png',
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
                              'If you continue you will see your recovery phrase.'
                              ' This is the only key to your wallet. If your'
                              ' phone gets stolen or lost, you will only be able'
                              ' to recover your funds with this recovery phrase.',
                              style: TextStyle(
                                color: HermezColors.blackTwo,
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
                      // TODO: pass settingsBloc
                      Navigator.of(context).pushNamed("/recovery_phrase",
                          arguments: RecoveryPhraseArguments(true, null));
                    },
                    padding: EdgeInsets.only(
                        top: 18.0, bottom: 18.0, right: 24.0, left: 24.0),
                    disabledTextColor: Colors.grey,
                    disabledColor: Colors.blueGrey,
                    color: HermezColors.darkOrange,
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
