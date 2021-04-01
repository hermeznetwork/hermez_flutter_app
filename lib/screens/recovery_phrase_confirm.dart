import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/utils/hermez_colors.dart';

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
  @override
  void initState() {
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
                          'Select the words according to your'
                          ' recovery phrase.',
                          style: TextStyle(
                            color: HermezColors.steel,
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
                      child: Text('Select word #',
                          style: TextStyle(
                            color: HermezColors.black,
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
                              primary: HermezColors.blackTwo,
                              backgroundColor: Colors.white,
                              minimumSize: Size(50, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () {
                              setState(() {
                                //pinNumberSelected(1);
                              });
                            },
                            child: Text(
                              'physics',
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
                              primary: HermezColors.blackTwo,
                              backgroundColor: Colors.white,
                              minimumSize: Size(50, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () {
                              setState(() {
                                //pinNumberSelected(1);
                              });
                            },
                            child: Text(
                              'player',
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
                              primary: HermezColors.blackTwo,
                              backgroundColor: Colors.white,
                              minimumSize: Size(50, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () {
                              setState(() {
                                //pinNumberSelected(1);
                              });
                            },
                            child: Text(
                              'judgement',
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
                        left: 24, right: 24, top: 20, bottom: 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Select word #',
                          style: TextStyle(
                            color: HermezColors.black,
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
                              primary: HermezColors.blackTwo,
                              backgroundColor: Colors.white,
                              minimumSize: Size(50, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () {
                              setState(() {
                                //pinNumberSelected(1);
                              });
                            },
                            child: Text(
                              'physics',
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
                              primary: HermezColors.blackTwo,
                              backgroundColor: Colors.white,
                              minimumSize: Size(50, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () {
                              setState(() {
                                //pinNumberSelected(1);
                              });
                            },
                            child: Text(
                              'player',
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
                              primary: HermezColors.blackTwo,
                              backgroundColor: Colors.white,
                              minimumSize: Size(50, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () {
                              setState(() {
                                //pinNumberSelected(1);
                              });
                            },
                            child: Text(
                              'judgement',
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
                        left: 24, right: 24, top: 20, bottom: 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Select word #',
                          style: TextStyle(
                            color: HermezColors.black,
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
                              primary: HermezColors.blackTwo,
                              backgroundColor: Colors.white,
                              minimumSize: Size(50, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () {
                              setState(() {
                                //pinNumberSelected(1);
                              });
                            },
                            child: Text(
                              'physics',
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
                              primary: HermezColors.blackTwo,
                              backgroundColor: Colors.white,
                              minimumSize: Size(50, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () {
                              setState(() {
                                //pinNumberSelected(1);
                              });
                            },
                            child: Text(
                              'player',
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
                              primary: HermezColors.blackTwo,
                              backgroundColor: Colors.white,
                              minimumSize: Size(50, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () {
                              setState(() {
                                //pinNumberSelected(1);
                              });
                            },
                            child: Text(
                              'judgement',
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
                        left: 24, right: 24, top: 20, bottom: 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Select word #',
                          style: TextStyle(
                            color: HermezColors.black,
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
                              primary: HermezColors.blackTwo,
                              backgroundColor: Colors.white,
                              minimumSize: Size(50, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () {
                              setState(() {
                                //pinNumberSelected(1);
                              });
                            },
                            child: Text(
                              'physics',
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
                              primary: HermezColors.blackTwo,
                              backgroundColor: Colors.white,
                              minimumSize: Size(50, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () {
                              setState(() {
                                //pinNumberSelected(1);
                              });
                            },
                            child: Text(
                              'player',
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
                              primary: HermezColors.blackTwo,
                              backgroundColor: Colors.white,
                              minimumSize: Size(50, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () {
                              setState(() {
                                //pinNumberSelected(1);
                              });
                            },
                            child: Text(
                              'judgement',
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
                    onPressed: checked ? () {} : null,
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

  Future<void> disableCapture() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }
}
