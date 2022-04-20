import 'dart:core';
import 'dart:math';

import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/material.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/utils/recovery_phrase_utils.dart';

import 'info.dart';

class RecoveryPhraseConfirmPage extends StatefulWidget {
  RecoveryPhraseConfirmPage({Key key, this.configurationService})
      : super(key: key);

  final ConfigurationService configurationService;

  @override
  _RecoveryPhraseConfirmPageState createState() =>
      _RecoveryPhraseConfirmPageState();
}

class _RecoveryPhraseConfirmPageState extends State<RecoveryPhraseConfirmPage> {
  bool checked = false;
  List<int> positions = [];
  List<int> correctCombination = [];
  List<int> selectedCombination = [0, 0, 0, 0];
  List<String> words = List.filled(12, "");
  List<String> fakeWords = [];
  @override
  void initState() {
    fetchRecoveryPhrase(widget.configurationService);
    getPositions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int fakeIndex = 0;
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Recovery phrase",
            style: TextStyle(
                fontFamily: 'ModernEra',
                color: HermezColors.darkTwo,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: HermezColors.quaternaryThree,
      ),
      backgroundColor: HermezColors.quaternaryThree,
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
                      margin: EdgeInsets.only(left: 24, right: 24, top: 24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            'Select the words according to your'
                            ' recovery phrase.',
                            style: TextStyle(
                              color: HermezColors.quaternary,
                              fontSize: 18,
                              height: 1.5,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: 24, right: 24, top: 20, bottom: 15),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Select word #' + positions[0].toString(),
                            style: TextStyle(
                              color: HermezColors.dark,
                              fontSize: 18,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 24, right: 24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(children: [
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                primary: selectedCombination[0] == 1
                                    ? Colors.white
                                    : HermezColors.darkTwo,
                                backgroundColor: selectedCombination[0] == 1
                                    ? Colors.black
                                    : Colors.white,
                                minimumSize: Size(50, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedCombination[0] = 1;
                                });
                              },
                              child: Text(
                                correctCombination[0] == 1
                                    ? words[positions[0] - 1]
                                    : fakeWords[fakeIndex++],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                primary: selectedCombination[0] == 2
                                    ? Colors.white
                                    : HermezColors.darkTwo,
                                backgroundColor: selectedCombination[0] == 2
                                    ? Colors.black
                                    : Colors.white,
                                minimumSize: Size(50, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              onPressed: () {
                                setState(() {
                                  setState(() {
                                    selectedCombination[0] = 2;
                                  });
                                });
                              },
                              child: Text(
                                correctCombination[0] == 2
                                    ? words[positions[0] - 1]
                                    : fakeWords[fakeIndex++],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                primary: selectedCombination[0] == 3
                                    ? Colors.white
                                    : HermezColors.darkTwo,
                                backgroundColor: selectedCombination[0] == 3
                                    ? Colors.black
                                    : Colors.white,
                                minimumSize: Size(50, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedCombination[0] = 3;
                                });
                              },
                              child: Text(
                                correctCombination[0] == 3
                                    ? words[positions[0] - 1]
                                    : fakeWords[fakeIndex++],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: 24, right: 24, top: 28, bottom: 15),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Select word #' + positions[1].toString(),
                            style: TextStyle(
                              color: HermezColors.dark,
                              fontSize: 18,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 24, right: 24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(children: [
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                primary: selectedCombination[1] == 1
                                    ? Colors.white
                                    : HermezColors.darkTwo,
                                backgroundColor: selectedCombination[1] == 1
                                    ? Colors.black
                                    : Colors.white,
                                minimumSize: Size(50, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedCombination[1] = 1;
                                });
                              },
                              child: Text(
                                correctCombination[1] == 1
                                    ? words[positions[1] - 1]
                                    : fakeWords[fakeIndex++],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                primary: selectedCombination[1] == 2
                                    ? Colors.white
                                    : HermezColors.darkTwo,
                                backgroundColor: selectedCombination[1] == 2
                                    ? Colors.black
                                    : Colors.white,
                                minimumSize: Size(50, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedCombination[1] = 2;
                                });
                              },
                              child: Text(
                                correctCombination[1] == 2
                                    ? words[positions[1] - 1]
                                    : fakeWords[fakeIndex++],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                primary: selectedCombination[1] == 3
                                    ? Colors.white
                                    : HermezColors.darkTwo,
                                backgroundColor: selectedCombination[1] == 3
                                    ? Colors.black
                                    : Colors.white,
                                minimumSize: Size(50, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedCombination[1] = 3;
                                });
                              },
                              child: Text(
                                correctCombination[1] == 3
                                    ? words[positions[1] - 1]
                                    : fakeWords[fakeIndex++],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: 24, right: 24, top: 28, bottom: 15),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Select word #' + positions[2].toString(),
                            style: TextStyle(
                              color: HermezColors.dark,
                              fontSize: 18,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 24, right: 24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(children: [
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                primary: selectedCombination[2] == 1
                                    ? Colors.white
                                    : HermezColors.darkTwo,
                                backgroundColor: selectedCombination[2] == 1
                                    ? Colors.black
                                    : Colors.white,
                                minimumSize: Size(50, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedCombination[2] = 1;
                                });
                              },
                              child: Text(
                                correctCombination[2] == 1
                                    ? words[positions[2] - 1]
                                    : fakeWords[fakeIndex++],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                primary: selectedCombination[2] == 2
                                    ? Colors.white
                                    : HermezColors.darkTwo,
                                backgroundColor: selectedCombination[2] == 2
                                    ? Colors.black
                                    : Colors.white,
                                minimumSize: Size(50, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedCombination[2] = 2;
                                });
                              },
                              child: Text(
                                correctCombination[2] == 2
                                    ? words[positions[2] - 1]
                                    : fakeWords[fakeIndex++],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                primary: selectedCombination[2] == 3
                                    ? Colors.white
                                    : HermezColors.darkTwo,
                                backgroundColor: selectedCombination[2] == 3
                                    ? Colors.black
                                    : Colors.white,
                                minimumSize: Size(50, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedCombination[2] = 3;
                                });
                              },
                              child: Text(
                                correctCombination[2] == 3
                                    ? words[positions[2] - 1]
                                    : fakeWords[fakeIndex++],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: 24, right: 24, top: 28, bottom: 15),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Select word #' + positions[3].toString(),
                            style: TextStyle(
                              color: HermezColors.dark,
                              fontSize: 18,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 24, right: 24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(children: [
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                primary: selectedCombination[3] == 1
                                    ? Colors.white
                                    : HermezColors.darkTwo,
                                backgroundColor: selectedCombination[3] == 1
                                    ? Colors.black
                                    : Colors.white,
                                minimumSize: Size(50, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedCombination[3] = 1;
                                });
                              },
                              child: Text(
                                correctCombination[3] == 1
                                    ? words[positions[3] - 1]
                                    : fakeWords[fakeIndex++],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                primary: selectedCombination[3] == 2
                                    ? Colors.white
                                    : HermezColors.darkTwo,
                                backgroundColor: selectedCombination[3] == 2
                                    ? Colors.black
                                    : Colors.white,
                                minimumSize: Size(50, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedCombination[3] = 2;
                                });
                              },
                              child: Text(
                                correctCombination[3] == 2
                                    ? words[positions[3] - 1]
                                    : fakeWords[fakeIndex++],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                primary: selectedCombination[3] == 3
                                    ? Colors.white
                                    : HermezColors.darkTwo,
                                backgroundColor: selectedCombination[3] == 3
                                    ? Colors.black
                                    : Colors.white,
                                minimumSize: Size(50, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedCombination[3] = 3;
                                });
                              },
                              child: Text(
                                correctCombination[3] == 3
                                    ? words[positions[3] - 1]
                                    : fakeWords[fakeIndex++],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ]),
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
                    onPressed: !selectedCombination.contains(0)
                        ? () async {
                            if (areListsEqual(
                                selectedCombination, correctCombination)) {
                              widget.configurationService.backupDone(true);
                              var value = await Navigator.of(context).pushNamed(
                                  "/info",
                                  arguments: InfoArguments(
                                      "info_backup_success.png",
                                      false,
                                      "Your wallet is backed up",
                                      iconSize: 300));
                              Navigator.pushNamedAndRemoveUntil(context,
                                  "/home", (Route<dynamic> route) => false);
                            } else {
                              var value = await Navigator.of(context).pushNamed(
                                  "/info",
                                  arguments: InfoArguments("info_failure.png",
                                      false, "Invalid recovery phrase"));
                              Navigator.pop(context);
                            }
                          }
                        : null,
                    padding: EdgeInsets.only(
                        top: 18.0, bottom: 18.0, right: 24.0, left: 24.0),
                    disabledColor: HermezColors.quaternaryTwo,
                    color: HermezColors.secondary,
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

  void getPositions() {
    positions.clear();
    correctCombination.clear();
    fakeWords.clear();
    final random = new Random();
    var i = 0;
    do {
      int value = random.nextInt(12) + 1;
      if (!positions.contains(value)) {
        positions.add(value);
        i++;
      }
    } while (i < 4);
    i = 0;
    do {
      int value = random.nextInt(3) + 1;
      correctCombination.add(value);
      i++;
    } while (i < 4);
    i = 0;
    do {
      String value = WORDLIST[random.nextInt(WORDLIST.length)];
      if (!fakeWords.contains(value)) {
        fakeWords.add(value);
        i++;
      }
    } while (i < 8);
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

  bool areListsEqual(var list1, var list2) {
    // check if both are lists
    if (!(list1 is List && list2 is List)
        // check if both have same length
        ||
        list1.length != list2.length) {
      return false;
    }

    // check if elements are equal
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) {
        return false;
      }
    }

    return true;
  }
}
