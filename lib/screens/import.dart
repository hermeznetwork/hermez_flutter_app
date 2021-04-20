import 'dart:convert';
import 'dart:math';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hermez/context/setup/wallet_setup_handler.dart';
import 'package:hermez/screens/pin.dart';
import 'package:hermez/screens/scanner.dart';
import 'package:hermez/utils/hermez_colors.dart';

class ImportWalletPage extends StatefulWidget {
  ImportWalletPage({Key key, this.store}) : super(key: key);

  WalletSetupHandler store;

  @override
  _ImportWalletState createState() => _ImportWalletState();
}

class _ImportWalletState extends State<ImportWalletPage> {
  bool buttonEnabled = false;
  List<String> words;
  List<FocusNode> focusNodes;
  List<TextEditingController> textEditingControllers;

  @override
  void initState() {
    focusNodes = List.filled(12, null);
    textEditingControllers = List.filled(12, null);
    for (int i = 0; i < 12; i++) {
      focusNodes[i] = FocusNode();
      textEditingControllers[i] = TextEditingController();
    }
    words = List.filled(12, "");
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text("Import wallet",
              style: TextStyle(
                  fontFamily: 'ModernEra',
                  color: HermezColors.blackTwo,
                  fontWeight: FontWeight.w800,
                  fontSize: 20)),
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: HermezColors.lightOrange,
          actions: <Widget>[
            IconButton(
              icon: ImageIcon(
                AssetImage('assets/scan.png'),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  "/scanner",
                  arguments: QRCodeScannerArguments(
                    //store: store,
                    type: QRCodeScannerType.RECOVERY_SEED,
                    onScanned: (value) async {
                      List<String> clipboardWords =
                          value.replaceAll(RegExp("\\s+"), " ").split(" ");
                      setState(
                        () {
                          int maxLength =
                              min(clipboardWords.length, words.length);
                          for (int i = 0; i < maxLength; i++) {
                            words[i] = clipboardWords[i];
                            textEditingControllers[i].text = clipboardWords[i];
                          }
                          checkEnabledButton();
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: HermezColors.lightOrange,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 24, right: 24, top: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Introduce your recovery phrase',
                              style: TextStyle(
                                color: HermezColors.steel,
                                fontSize: 17,
                                fontFamily: 'ModernEra',
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                      ),
                      SizedBox(height: 26),
                      Container(
                        height: 300,
                        margin: EdgeInsets.only(
                          left: 24,
                          right: 24,
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
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
                                    child: Container(
                                      child: TextField(
                                        controller: textEditingControllers[0],
                                        autocorrect: false,
                                        focusNode: focusNodes[0],
                                        cursorColor: HermezColors.orange,
                                        textInputAction: TextInputAction.next,
                                        onChanged: (text) {
                                          setState(() {
                                            words[0] = text;
                                            checkEnabledButton();
                                          });
                                        },
                                        onEditingComplete: () =>
                                            focusNodes[1].requestFocus(),
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.only(
                                              left: 12,
                                              right: 12,
                                              top: 8,
                                              bottom: 8),
                                          filled: true,
                                          fillColor: Colors.white,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HermezColors.orange),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 30,
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
                                    child: Container(
                                      child: TextField(
                                        controller: textEditingControllers[6],
                                        autocorrect: false,
                                        focusNode: focusNodes[6],
                                        cursorColor: HermezColors.orange,
                                        textInputAction: TextInputAction.next,
                                        onChanged: (text) {
                                          setState(() {
                                            words[6] = text;
                                            checkEnabledButton();
                                          });
                                        },
                                        onEditingComplete: () =>
                                            focusNodes[7].requestFocus(),
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.only(
                                              left: 12,
                                              right: 12,
                                              top: 8,
                                              bottom: 8),
                                          filled: true,
                                          fillColor: Colors.white,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HermezColors.orange),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
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
                                  child: Container(
                                    child: TextField(
                                      controller: textEditingControllers[1],
                                      autocorrect: false,
                                      focusNode: focusNodes[1],
                                      cursorColor: HermezColors.orange,
                                      textInputAction: TextInputAction.next,
                                      onChanged: (text) {
                                        setState(() {
                                          words[1] = text;
                                          checkEnabledButton();
                                        });
                                      },
                                      onEditingComplete: () =>
                                          focusNodes[2].requestFocus(),
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            left: 12,
                                            right: 12,
                                            top: 8,
                                            bottom: 8),
                                        filled: true,
                                        fillColor: Colors.white,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: HermezColors.orange),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
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
                                  child: Container(
                                    child: TextField(
                                      controller: textEditingControllers[7],
                                      autocorrect: false,
                                      focusNode: focusNodes[7],
                                      cursorColor: HermezColors.orange,
                                      textInputAction: TextInputAction.next,
                                      onChanged: (text) {
                                        setState(() {
                                          words[7] = text;
                                          checkEnabledButton();
                                        });
                                      },
                                      onEditingComplete: () =>
                                          focusNodes[8].requestFocus(),
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            left: 12,
                                            right: 12,
                                            top: 8,
                                            bottom: 8),
                                        filled: true,
                                        fillColor: Colors.white,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: HermezColors.orange),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                            SizedBox(height: 8),
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
                                  child: Container(
                                    child: TextField(
                                      controller: textEditingControllers[2],
                                      autocorrect: false,
                                      focusNode: focusNodes[2],
                                      cursorColor: HermezColors.orange,
                                      textInputAction: TextInputAction.next,
                                      onChanged: (text) {
                                        setState(() {
                                          words[2] = text;
                                          checkEnabledButton();
                                        });
                                      },
                                      onEditingComplete: () =>
                                          focusNodes[3].requestFocus(),
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            left: 12,
                                            right: 12,
                                            top: 8,
                                            bottom: 8),
                                        filled: true,
                                        fillColor: Colors.white,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: HermezColors.orange),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
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
                                  child: Container(
                                    child: TextField(
                                      controller: textEditingControllers[8],
                                      autocorrect: false,
                                      focusNode: focusNodes[8],
                                      cursorColor: HermezColors.orange,
                                      textInputAction: TextInputAction.next,
                                      onChanged: (text) {
                                        setState(() {
                                          words[8] = text;
                                          checkEnabledButton();
                                        });
                                      },
                                      onEditingComplete: () =>
                                          focusNodes[9].requestFocus(),
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            left: 12,
                                            right: 12,
                                            top: 8,
                                            bottom: 8),
                                        filled: true,
                                        fillColor: Colors.white,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: HermezColors.orange),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                            SizedBox(height: 8),
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
                                  child: Container(
                                    child: TextField(
                                      controller: textEditingControllers[3],
                                      autocorrect: false,
                                      focusNode: focusNodes[3],
                                      cursorColor: HermezColors.orange,
                                      textInputAction: TextInputAction.next,
                                      onChanged: (text) {
                                        setState(() {
                                          words[3] = text;
                                          checkEnabledButton();
                                        });
                                      },
                                      onEditingComplete: () =>
                                          focusNodes[4].requestFocus(),
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            left: 12,
                                            right: 12,
                                            top: 8,
                                            bottom: 8),
                                        filled: true,
                                        fillColor: Colors.white,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: HermezColors.orange),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
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
                                  child: Container(
                                    child: TextField(
                                      controller: textEditingControllers[9],
                                      autocorrect: false,
                                      focusNode: focusNodes[9],
                                      cursorColor: HermezColors.orange,
                                      textInputAction: TextInputAction.next,
                                      onChanged: (text) {
                                        setState(() {
                                          words[9] = text;
                                          checkEnabledButton();
                                        });
                                      },
                                      onEditingComplete: () =>
                                          focusNodes[10].requestFocus(),
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            left: 12,
                                            right: 12,
                                            top: 8,
                                            bottom: 8),
                                        filled: true,
                                        fillColor: Colors.white,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: HermezColors.orange),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                            SizedBox(height: 8),
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
                                  child: Container(
                                    child: TextField(
                                      controller: textEditingControllers[4],
                                      autocorrect: false,
                                      focusNode: focusNodes[4],
                                      cursorColor: HermezColors.orange,
                                      textInputAction: TextInputAction.next,
                                      onChanged: (text) {
                                        setState(() {
                                          words[4] = text;
                                          checkEnabledButton();
                                        });
                                      },
                                      onEditingComplete: () =>
                                          focusNodes[5].requestFocus(),
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            left: 12,
                                            right: 12,
                                            top: 8,
                                            bottom: 8),
                                        filled: true,
                                        fillColor: Colors.white,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: HermezColors.orange),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
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
                                  child: Container(
                                    child: TextField(
                                      controller: textEditingControllers[10],
                                      autocorrect: false,
                                      focusNode: focusNodes[10],
                                      cursorColor: HermezColors.orange,
                                      textInputAction: TextInputAction.next,
                                      onChanged: (text) {
                                        setState(() {
                                          words[10] = text;
                                          checkEnabledButton();
                                        });
                                      },
                                      onEditingComplete: () =>
                                          focusNodes[11].requestFocus(),
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            left: 12,
                                            right: 12,
                                            top: 8,
                                            bottom: 8),
                                        filled: true,
                                        fillColor: Colors.white,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: HermezColors.orange),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                            SizedBox(height: 8),
                            Expanded(
                              child: Row(
                                children: [
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
                                    child: Container(
                                      child: TextField(
                                        controller: textEditingControllers[5],
                                        autocorrect: false,
                                        focusNode: focusNodes[5],
                                        cursorColor: HermezColors.orange,
                                        textInputAction: TextInputAction.next,
                                        onChanged: (text) {
                                          setState(() {
                                            words[5] = text;
                                            checkEnabledButton();
                                          });
                                        },
                                        onEditingComplete: () =>
                                            focusNodes[6].requestFocus(),
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.only(
                                              left: 12,
                                              right: 12,
                                              top: 8,
                                              bottom: 8),
                                          filled: true,
                                          fillColor: Colors.white,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HermezColors.orange),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 30,
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
                                    child: Container(
                                      child: TextField(
                                        controller: textEditingControllers[11],
                                        autocorrect: false,
                                        focusNode: focusNodes[11],
                                        cursorColor: HermezColors.orange,
                                        textInputAction: TextInputAction.done,
                                        onChanged: (text) {
                                          setState(() {
                                            words[11] = text;
                                            checkEnabledButton();
                                          });
                                        },
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.only(
                                              left: 12,
                                              right: 12,
                                              top: 8,
                                              bottom: 8),
                                          filled: true,
                                          fillColor: Colors.white,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HermezColors.orange),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Container(
                        alignment: Alignment.center,
                        child: TextButton.icon(
                          onPressed: () {
                            FlutterClipboard.paste().then((String value) {
                              List<String> clipboardWords = value
                                  .replaceAll(RegExp("\\s+"), " ")
                                  .split(" ");
                              setState(() {
                                int maxLength =
                                    min(clipboardWords.length, words.length);
                                for (int i = 0; i < maxLength; i++) {
                                  words[i] = clipboardWords[i];
                                  textEditingControllers[i].text =
                                      clipboardWords[i];
                                }
                                checkEnabledButton();
                              });
                            });
                          },
                          icon: Icon(
                            Icons.paste,
                            color: HermezColors.blueyGreyTwo,
                          ),
                          label: Text(
                            'Paste from clipboard',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: HermezColors.blueyGreyTwo,
                              fontSize: 16,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                      onPressed: buttonEnabled
                          ? () {
                              Navigator.of(context).pushNamed("/pin",
                                  arguments: PinArguments(null, true, () async {
                                    String mnemonic = json.encode(words);
                                    mnemonic = mnemonic.replaceAll(",", " ");
                                    mnemonic = mnemonic.replaceAll("[", "");
                                    mnemonic = mnemonic.replaceAll("]", "");
                                    mnemonic = mnemonic.replaceAll("\"", "");
                                    bool imported = await widget.store
                                        .importFromMnemonic(mnemonic);
                                    if (imported) {
                                      Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          "/home",
                                          (Route<dynamic> route) => false);
                                    } else {}
                                  }));
                            }
                          : null,
                      padding: EdgeInsets.only(
                          top: 18.0, bottom: 18.0, right: 24.0, left: 24.0),
                      disabledColor: HermezColors.blueyGreyTwo,
                      color: HermezColors.darkOrange,
                      textColor: Colors.white,
                      child: Text("Import wallet",
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
            ],
          ),
        ) /*ImportWalletForm(
        errors: store.state.errors.toList(),
        onImport: !store.state.loading
            ? (type, value) async {
                switch (type) {
                  case WalletImportType.mnemonic:
                    if (!await store.importFromMnemonic(value)) return;
                    break;
                  case WalletImportType.privateKey:
                    if (!await store.importFromPrivateKey(value)) return;
                    break;
                  default:
                    break;
                }

                Navigator.pushNamedAndRemoveUntil(
                    context, "/home", (Route<dynamic> route) => false);
              }
            : null,
      ),
    );*/
        );
  }

  void checkEnabledButton() {
    bool isEnabled = true;
    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      if (word.isEmpty) {
        isEnabled = false;
        break;
      }
    }
    buttonEnabled = isEnabled;
  }
}
