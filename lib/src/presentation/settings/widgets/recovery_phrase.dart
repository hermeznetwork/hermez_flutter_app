import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:hermez/dependencies_provider.dart';
import 'package:hermez/src/presentation/settings/settings_bloc.dart';
import 'package:hermez/src/presentation/settings/settings_state.dart';
import 'package:hermez/utils/hermez_colors.dart';

class RecoveryPhraseArguments {
  final bool isBackup;
  final SettingsBloc settingsBloc;

  RecoveryPhraseArguments(this.isBackup, this.settingsBloc);
}

class RecoveryPhrasePage extends StatefulWidget {
  RecoveryPhrasePage({Key key, this.arguments}) : super(key: key);

  final RecoveryPhraseArguments arguments;

  @override
  _RecoveryPhrasePageState createState() =>
      _RecoveryPhrasePageState(arguments.settingsBloc);
}

class _RecoveryPhrasePageState extends State<RecoveryPhrasePage> {
  bool checked = false;
  String mnemonic = "";
  List<String> words = List.filled(12, "");
  final SettingsBloc _settingsBloc;
  _RecoveryPhrasePageState(SettingsBloc settingsBloc)
      : _settingsBloc =
            settingsBloc != null ? settingsBloc : getIt<SettingsBloc>() {
    if (!(_settingsBloc.state is LoadedSettingsState)) {
      _settingsBloc.init();
    }
  }
  @override
  void initState() {
    fetchRecoveryPhrase();
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
      body: StreamBuilder<SettingsState>(
        initialData: _settingsBloc.state,
        stream: _settingsBloc.observableState,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is LoadingSettingsState) {
            return Container(
                color: HermezColors.lightOrange,
                child: Center(
                  child: CircularProgressIndicator(color: HermezColors.orange),
                ));
          } else if (state is ErrorSettingsState) {
            return Center(child: Text(state.message));
          } else {
            return _renderRecoveryPhrase(context, state);
          }
        },
      ),
    );
  }

  Widget _renderRecoveryPhrase(BuildContext context, LoadedSettingsState) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: new Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  widget.arguments.isBackup
                      ? Container(
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
                        )
                      : Container(),
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
                  SizedBox(height: 25),
                  widget.arguments.isBackup
                      ? Container(
                          margin: EdgeInsets.only(left: 24, right: 24),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: checked,
                                  onChanged: (value) {
                                    setState(() {
                                      checked = value;
                                    });
                                  },
                                ),
                                Expanded(
                                    child: Container(
                                  padding: EdgeInsets.only(top: 8),
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
                                ))
                              ]),
                        )
                      : Container(
                          margin: EdgeInsets.only(left: 24, right: 24),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                'Do not share your recovery phrase'
                                ' with anyone. This phrase gives access'
                                ' to your wallet and could be used to'
                                ' steal your funds.',
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
          widget.arguments.isBackup
              ? Container(
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
                )
              : Container(),
        ],
      ),
    );
  }

  Future<void> fetchRecoveryPhrase() async {
    String entropyString = await _settingsBloc.getRecoveryPhase();
    setState(() {
      mnemonic = bip39.entropyToMnemonic(entropyString);
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
    try {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    } catch (e) {}
  }
}
