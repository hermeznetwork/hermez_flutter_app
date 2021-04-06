import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/context/setup/wallet_setup_provider.dart';
import 'package:hermez/utils/hermez_colors.dart';

class WalletImportPage extends HookWidget {
  WalletImportPage(this.title);

  final String title;

  Widget build(BuildContext context) {
    List<FocusNode> focusNodes = List.filled(12, null);
    for (int i = 0; i < 12; i++) {
      focusNodes[i] = FocusNode();
    }
    var words = List.filled(12, "");
    var store = useWalletSetup(context);
    return Scaffold(
        appBar: new AppBar(
          title: new Text(title,
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
                                        cursorColor: HermezColors.orange,
                                        autofocus: true,
                                        textInputAction: TextInputAction.next,
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
                                          labelText: words[0],
                                          labelStyle: TextStyle(
                                            color: HermezColors.blackTwo,
                                            fontFamily: 'ModernEra',
                                            fontWeight: FontWeight.w500,
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
                                        focusNode: focusNodes[6],
                                        cursorColor: HermezColors.orange,
                                        textInputAction: TextInputAction.next,
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
                                          labelText: words[6],
                                          labelStyle: TextStyle(
                                            color: HermezColors.blackTwo,
                                            fontFamily: 'ModernEra',
                                            fontWeight: FontWeight.w500,
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
                                      focusNode: focusNodes[1],
                                      cursorColor: HermezColors.orange,
                                      textInputAction: TextInputAction.next,
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
                                        labelText: words[1],
                                        labelStyle: TextStyle(
                                          color: HermezColors.blackTwo,
                                          fontFamily: 'ModernEra',
                                          fontWeight: FontWeight.w500,
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
                                      focusNode: focusNodes[7],
                                      cursorColor: HermezColors.orange,
                                      textInputAction: TextInputAction.next,
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
                                        labelText: words[7],
                                        labelStyle: TextStyle(
                                          color: HermezColors.blackTwo,
                                          fontFamily: 'ModernEra',
                                          fontWeight: FontWeight.w500,
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
                                      focusNode: focusNodes[2],
                                      cursorColor: HermezColors.orange,
                                      textInputAction: TextInputAction.next,
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
                                        labelText: words[2],
                                        labelStyle: TextStyle(
                                          color: HermezColors.blackTwo,
                                          fontFamily: 'ModernEra',
                                          fontWeight: FontWeight.w500,
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
                                      focusNode: focusNodes[8],
                                      cursorColor: HermezColors.orange,
                                      textInputAction: TextInputAction.next,
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
                                        labelText: words[8],
                                        labelStyle: TextStyle(
                                          color: HermezColors.blackTwo,
                                          fontFamily: 'ModernEra',
                                          fontWeight: FontWeight.w500,
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
                                      focusNode: focusNodes[3],
                                      cursorColor: HermezColors.orange,
                                      textInputAction: TextInputAction.next,
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
                                        labelText: words[3],
                                        labelStyle: TextStyle(
                                          color: HermezColors.blackTwo,
                                          fontFamily: 'ModernEra',
                                          fontWeight: FontWeight.w500,
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
                                      focusNode: focusNodes[9],
                                      cursorColor: HermezColors.orange,
                                      textInputAction: TextInputAction.next,
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
                                        labelText: words[9],
                                        labelStyle: TextStyle(
                                          color: HermezColors.blackTwo,
                                          fontFamily: 'ModernEra',
                                          fontWeight: FontWeight.w500,
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
                                      focusNode: focusNodes[4],
                                      cursorColor: HermezColors.orange,
                                      textInputAction: TextInputAction.next,
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
                                        labelText: words[4],
                                        labelStyle: TextStyle(
                                          color: HermezColors.blackTwo,
                                          fontFamily: 'ModernEra',
                                          fontWeight: FontWeight.w500,
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
                                      focusNode: focusNodes[10],
                                      cursorColor: HermezColors.orange,
                                      textInputAction: TextInputAction.next,
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
                                        labelText: words[10],
                                        labelStyle: TextStyle(
                                          color: HermezColors.blackTwo,
                                          fontFamily: 'ModernEra',
                                          fontWeight: FontWeight.w500,
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
                                        focusNode: focusNodes[5],
                                        cursorColor: HermezColors.orange,
                                        textInputAction: TextInputAction.next,
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
                                          labelText: words[5],
                                          labelStyle: TextStyle(
                                            color: HermezColors.blackTwo,
                                            fontFamily: 'ModernEra',
                                            fontWeight: FontWeight.w500,
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
                                        focusNode: focusNodes[11],
                                        cursorColor: HermezColors.orange,
                                        textInputAction: TextInputAction.done,
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
                                          labelText: words[11],
                                          labelStyle: TextStyle(
                                            color: HermezColors.blackTwo,
                                            fontFamily: 'ModernEra',
                                            fontWeight: FontWeight.w500,
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
                      onPressed:
                          /*checked
                          ? () {
                        Navigator.of(context)
                            .pushNamed("/recovery_phrase_confirm");
                      }
                          :*/
                          null,
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
}
