import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hermez/service/configuration_service.dart';
import 'package:hermez/utils/hermez_colors.dart';

import 'info.dart';

class PinArguments {
  final bool creatingPin;

  PinArguments(this.creatingPin);
}

class PinPage extends StatefulWidget {
  PinPage({Key key, this.arguments, this.configurationService})
      : super(key: key);

  final PinArguments arguments;
  final ConfigurationService configurationService;

  @override
  _PinPageState createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  int maxPosition = 6;
  String pinString = "";
  String confirmPinString = "";
  int currentPosition = 1;
  bool confirmingPin = false;

  bool position1Selected = false;
  bool position2Selected = false;
  bool position3Selected = false;
  bool position4Selected = false;
  bool position5Selected = false;
  bool position6Selected = false;

  String pinInfoText = "";
  bool pinError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Create passcode",
            style: TextStyle(
                fontFamily: 'ModernEra',
                color: HermezColors.blackTwo,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: HermezColors.mediumOrange,
      ),
      body: SafeArea(
        child: Container(
          color: HermezColors.mediumOrange,
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 80),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          height: 15.0,
                          width: 15.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: position1Selected ? Colors.black : null,
                            border: Border.all(color: Colors.black, width: 1.0),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          height: 15.0,
                          width: 15.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: position2Selected ? Colors.black : null,
                            border: Border.all(color: Colors.black, width: 1.0),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          height: 15.0,
                          width: 15.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: position3Selected ? Colors.black : null,
                            border: Border.all(color: Colors.black, width: 1.0),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          height: 15.0,
                          width: 15.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: position4Selected ? Colors.black : null,
                            border: Border.all(color: Colors.black, width: 1.0),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          height: 15.0,
                          width: 15.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: position5Selected ? Colors.black : null,
                            border: Border.all(color: Colors.black, width: 1.0),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          height: 15.0,
                          width: 15.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: position6Selected ? Colors.black : null,
                            border: Border.all(color: Colors.black, width: 1.0),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    Container(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyText2,
                          children: [
                            WidgetSpan(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: pinError
                                    ? Image.asset("assets/info.png",
                                        width: 17,
                                        height: 17,
                                        color: HermezColors.redError)
                                    : null,
                              ),
                            ),
                            TextSpan(
                              text: pinInfoText,
                              style: TextStyle(
                                color: pinError
                                    ? HermezColors.redError
                                    : HermezColors.steel,
                                fontSize: 16,
                                fontFamily: 'ModernEra',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                    left: 30.0, right: 30.0, top: 30.0, bottom: 30.0),
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 10),
                              TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.black,
                                  minimumSize: Size(60, 60),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    pinNumberSelected(1);
                                  });
                                },
                                child: Text(
                                  '1',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 20),
                              TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.black,
                                  minimumSize: Size(60, 60),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    pinNumberSelected(4);
                                  });
                                },
                                child: Text(
                                  '4',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 20),
                              TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.black,
                                  minimumSize: Size(60, 60),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    pinNumberSelected(7);
                                  });
                                },
                                child: Text(
                                  '7',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                height: 60.0,
                                width: 60.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.black,
                                  minimumSize: Size(60, 60),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    pinNumberSelected(2);
                                  });
                                },
                                child: Text(
                                  '2',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 20),
                              TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.black,
                                  minimumSize: Size(60, 60),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    pinNumberSelected(5);
                                  });
                                },
                                child: Text(
                                  '5',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 20),
                              TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.black,
                                  minimumSize: Size(60, 60),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    pinNumberSelected(8);
                                  });
                                },
                                child: Text(
                                  '8',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 20),
                              TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.black,
                                  minimumSize: Size(60, 60),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    pinNumberSelected(0);
                                  });
                                },
                                child: Text(
                                  '0',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.black,
                                  minimumSize: Size(60, 60),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    pinNumberSelected(3);
                                  });
                                },
                                child: Text(
                                  '3',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 20),
                              TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.black,
                                  minimumSize: Size(60, 60),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    pinNumberSelected(6);
                                  });
                                },
                                child: Text(
                                  '6',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 20),
                              TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.black,
                                  minimumSize: Size(60, 60),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    pinNumberSelected(9);
                                  });
                                },
                                child: Text(
                                  '9',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 20),
                              TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.black,
                                  minimumSize: Size(60, 60),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    deletePinNumberSelected();
                                  });
                                },
                                child: Text(
                                  '<',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ],
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

  void clearAllSelected() {
    currentPosition = 1;
    position1Selected = false;
    position2Selected = false;
    position3Selected = false;
    position4Selected = false;
    position5Selected = false;
    position6Selected = false;
    if (confirmingPin) {
      confirmPinString = "";
    } else {
      pinString = "";
    }
  }

  Future<void> pinNumberSelected(int number) async {
    final PinArguments args = ModalRoute.of(context).settings.arguments;
    if (currentPosition <= maxPosition) {
      switch (currentPosition) {
        case 1:
          position1Selected = true;
          break;
        case 2:
          position2Selected = true;
          break;
        case 3:
          position3Selected = true;
          break;
        case 4:
          position4Selected = true;
          break;
        case 5:
          position5Selected = true;
          break;
        case 6:
          position6Selected = true;
          break;
      }
      currentPosition++;
      if (confirmingPin) {
        confirmPinString += number.toString();
      } else {
        pinString += number.toString();
      }
      if (currentPosition > maxPosition) {
        if (args.creatingPin) {
          if (!confirmingPin) {
            confirmingPin = true;
            pinInfoText = "Confirm your passcode";
            pinError = false;
            clearAllSelected();
          } else {
            if (pinString == confirmPinString) {
              widget.configurationService.setPasscode(pinString);
              Navigator.of(context)
                  .pushNamed("/info",
                      arguments: InfoArguments(
                          "info_success.png", false, "Passcode created"))
                  .then((value) {
                Navigator.pop(context, pinString);
              });
            } else {
              pinInfoText = "Passcode doesn\'t match";
              pinError = true;
              confirmingPin = false;
              clearAllSelected();
            }
          }
        } else {
          if (pinString == await widget.configurationService.getPasscode()) {
            //navigator.showMain(activity!!)
            //activity?.finish()
          } else {
            pinInfoText = "Passcode is incorrect";
            pinError = true;
            clearAllSelected();
          }
        }
      } else if (pinError) {
        pinInfoText = "";
        pinError = false;
      }
    }
  }

  void deletePinNumberSelected() {
    if (currentPosition > 1) {
      currentPosition--;
      switch (currentPosition) {
        case 1:
          position1Selected = false;
          break;
        case 2:
          position2Selected = false;
          break;
        case 3:
          position3Selected = false;
          break;
        case 4:
          position4Selected = false;
          break;
        case 5:
          position5Selected = false;
          break;
        case 6:
          position6Selected = false;
          break;
      }
      if (confirmingPin) {
        confirmPinString =
            confirmPinString.substring(0, confirmPinString.length - 1);
      } else {
        pinString = pinString.substring(0, pinString.length - 1);
      }
    }
  }
}
