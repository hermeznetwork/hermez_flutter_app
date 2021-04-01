import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/utils/hermez_colors.dart';

class RecoveryPhrasePage extends StatefulWidget {
  RecoveryPhrasePage({Key key, this.configurationService}) : super(key: key);

  final ConfigurationService configurationService;

  @override
  _RecoveryPhrasePageState createState() => _RecoveryPhrasePageState();
}

class _RecoveryPhrasePageState extends State<RecoveryPhrasePage> {
  bool checked = false;
  String mnemonic = "";
  List<String> words = List.filled(12, "");
  @override
  void initState() {
    fetchRecoveryPhrase(widget.configurationService);
    disableCapture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Recovery phrase",
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
              child: new Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 24, right: 24, top: 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          'Back up these words manually and keep '
                          'them in a safe place.',
                          style: TextStyle(
                            color: HermezColors.steel,
                            fontSize: 18,
                            height: 1.5,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 232,
                    margin: EdgeInsets.only(
                      left: 16,
                      right: 16,
                    ),
                    padding: EdgeInsets.only(
                        top: 24, bottom: 24, left: 32, right: 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xfff8ecd6),
                          offset: Offset(0, 4),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text('1',
                                  style: TextStyle(
                                    color: HermezColors.blueyGreyTwo,
                                    fontSize: 14,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Text(words[0],
                                  style: TextStyle(
                                    color: HermezColors.blackTwo,
                                    fontSize: 18,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text('7',
                                  style: TextStyle(
                                    color: HermezColors.blueyGreyTwo,
                                    fontSize: 14,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(words[6],
                                    style: TextStyle(
                                      color: HermezColors.blackTwo,
                                      fontSize: 18,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w500,
                                    )),
                              ),
                            ),
                          ]),
                        ),
                        Expanded(
                          child: Row(children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text('2',
                                  style: TextStyle(
                                    color: HermezColors.blueyGreyTwo,
                                    fontSize: 14,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Text(words[1],
                                  style: TextStyle(
                                    color: HermezColors.blackTwo,
                                    fontSize: 18,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text('8',
                                  style: TextStyle(
                                    color: HermezColors.blueyGreyTwo,
                                    fontSize: 14,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(words[7],
                                    style: TextStyle(
                                      color: HermezColors.blackTwo,
                                      fontSize: 18,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w500,
                                    )),
                              ),
                            ),
                          ]),
                        ),
                        Expanded(
                          child: Row(children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text('3',
                                  style: TextStyle(
                                    color: HermezColors.blueyGreyTwo,
                                    fontSize: 14,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Text(words[2],
                                  style: TextStyle(
                                    color: HermezColors.blackTwo,
                                    fontSize: 18,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text('9',
                                  style: TextStyle(
                                    color: HermezColors.blueyGreyTwo,
                                    fontSize: 14,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(words[8],
                                    style: TextStyle(
                                      color: HermezColors.blackTwo,
                                      fontSize: 18,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w500,
                                    )),
                              ),
                            ),
                          ]),
                        ),
                        Expanded(
                          child: Row(children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text('4',
                                  style: TextStyle(
                                    color: HermezColors.blueyGreyTwo,
                                    fontSize: 14,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Text(words[3],
                                  style: TextStyle(
                                    color: HermezColors.blackTwo,
                                    fontSize: 18,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text('10',
                                  style: TextStyle(
                                    color: HermezColors.blueyGreyTwo,
                                    fontSize: 14,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(words[9],
                                    style: TextStyle(
                                      color: HermezColors.blackTwo,
                                      fontSize: 18,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w500,
                                    )),
                              ),
                            ),
                          ]),
                        ),
                        Expanded(
                          child: Row(children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text('5',
                                  style: TextStyle(
                                    color: HermezColors.blueyGreyTwo,
                                    fontSize: 14,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Text(words[4],
                                  style: TextStyle(
                                    color: HermezColors.blackTwo,
                                    fontSize: 18,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text('11',
                                  style: TextStyle(
                                    color: HermezColors.blueyGreyTwo,
                                    fontSize: 14,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(words[10],
                                    style: TextStyle(
                                      color: HermezColors.blackTwo,
                                      fontSize: 18,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w500,
                                    )),
                              ),
                            ),
                          ]),
                        ),
                        Expanded(
                          child: Row(children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text('6',
                                  style: TextStyle(
                                    color: HermezColors.blueyGreyTwo,
                                    fontSize: 14,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Text(words[5],
                                  style: TextStyle(
                                    color: HermezColors.blackTwo,
                                    fontSize: 18,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text('12',
                                  style: TextStyle(
                                    color: HermezColors.blueyGreyTwo,
                                    fontSize: 14,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(words[11],
                                    style: TextStyle(
                                      color: HermezColors.blackTwo,
                                      fontSize: 18,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w500,
                                    )),
                              ),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  Container(
                    margin: EdgeInsets.only(left: 24, right: 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(children: [
                        Checkbox(
                          value: checked,
                          onChanged: (value) {
                            setState(() {
                              checked = value;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                              'I understand this is my only'
                              ' key to recover my funds.',
                              style: TextStyle(
                                color: HermezColors.blackTwo,
                                fontSize: 18,
                                height: 1.5,
                                fontFamily: 'ModernEra',
                                fontWeight: FontWeight.w500,
                              )),
                        )
                      ]),
                    ),
                  ),
                ],
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
                    onPressed: checked
                        ? () {
                            Navigator.of(context)
                                .pushNamed("/recovery_phrase_confirm");
                          }
                        : null,
                    padding: EdgeInsets.only(
                        top: 18.0, bottom: 18.0, right: 24.0, left: 24.0),
                    disabledColor: HermezColors.blueyGreyTwo,
                    color: HermezColors.darkOrange,
                    textColor: Colors.white,
                    child: Text("Continue",
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

  Future<void> fetchRecoveryPhrase(
      ConfigurationService configurationService) async {
    String entropyString = await configurationService.getMnemonic();
    String mnemonic = bip39.entropyToMnemonic(entropyString);
    setState(() {
      words = _mnemonicWords(mnemonic);
    });
  }

  List<String> _mnemonicWords(String mnemonic) {
    return mnemonic
        .split(" ")
        .where((item) => item != null && item.trim().isNotEmpty)
        .map((item) => item.trim())
        .toList();
  }

  Future<void> disableCapture() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }
}
