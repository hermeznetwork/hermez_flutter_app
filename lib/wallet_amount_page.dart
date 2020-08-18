import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'wallet_receiver_page.dart';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class AmountPage extends StatefulWidget {
  AmountPage({Key key}) : super(key : key);

  @override
  _AmountPageState createState() => _AmountPageState();
}

class _AmountPageState extends State<AmountPage> {
  String currentCurrency = "€";
  String currentAmount = "0.0";

  var outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: BorderSide(color: Colors.transparent)
  );

  int pinIndex = 0;
  int pinPosition = 1;

  bool isConfirming = false;

  String currentFeeText = "€0.09 fee";

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(
      child: Column(
        children: <Widget>[
          buildExitButton(),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  buildPinRow(),
                  SizedBox(height: 20.0),
                  buildFeeText(currentFeeText),
                ],
              ),
            )
          ),
          buildNumberPad(),
          buildButtonsRow(),
          SizedBox(height: 20.0),
        ],
      ),
    ),
    );
  }

  buildNumberPad() {
    return Expanded(
      child: Container(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly ,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  KeyboardNumber(
                    n: "1",
                    onPressed:() {
                      pinIndexSetup("1");
                    },
                  ),
                  KeyboardNumber(
                    n: "2",
                    onPressed:() {
                      pinIndexSetup("2");
                    },
                  ),
                  KeyboardNumber(
                    n: "3",
                    onPressed:() {
                      pinIndexSetup("3");
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  KeyboardNumber(
                    n: "4",
                    onPressed:() {
                      pinIndexSetup("4");
                    },
                  ),
                  KeyboardNumber(
                    n: "5",
                    onPressed:() {
                      pinIndexSetup("5");
                    },
                  ),
                  KeyboardNumber(
                    n: "6",
                    onPressed:() {
                      pinIndexSetup("6");
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  KeyboardNumber(
                    n: "7",
                    onPressed:() {
                      pinIndexSetup("7");
                    },
                  ),
                  KeyboardNumber(
                    n: "8",
                    onPressed:() {
                      pinIndexSetup("8");
                    },
                  ),
                  KeyboardNumber(
                    n: "9",
                    onPressed:() {
                      pinIndexSetup("9");
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  KeyboardNumber(
                    n: ".",
                    onPressed:() {
                      pinIndexSetup(".");
                    },
                  ),
                  KeyboardNumber(
                    n: "0",
                    onPressed:() {
                      pinIndexSetup("0");
                    },
                  ),
                  KeyboardNumber(
                    n: "<",
                    onPressed:() {
                      pinIndexSetup("<");
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  buildButtonsRow() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(width: 20.0),
          Expanded(
          child:
          RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
                side: BorderSide(color: Colors.black)),
            onPressed: () {
              Navigator.of(context).pushNamed("/receiver", arguments: ReceiverArguments(ReceiverType.REQUEST));
            },
            padding: EdgeInsets.all(16.0),
            color: Colors.black,
            textColor: Colors.white,
            child: Text("Request",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                )),
          ),
          ),
          SizedBox(width: 20.0),
          Expanded(
          child:
          RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
                side: BorderSide(color: Colors.black)),
            onPressed: () {
              Navigator.of(context).pushNamed("/receiver", arguments: ReceiverArguments(ReceiverType.SEND));
            },
            color: Colors.black,
            textColor: Colors.white,
            padding: EdgeInsets.all(16.0),
            child: Text("Send",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),),
          ),
          ),
          SizedBox(width: 20.0),
          ]
    );
  }

  pinIndexSetup(String text) {
    setState(() {
      if (text == "<") {
        if (currentAmount == "0.0") {

        } else {
          currentAmount = currentAmount.substring(0, currentAmount.length - 1);
          if (currentAmount == "") {
            currentAmount = "0.0";
          } else if (currentAmount.endsWith(".")) {
            currentAmount =
                currentAmount.substring(0, currentAmount.length - 1);
          }
        }
      } else if (text == ".") {
        if (currentAmount.contains(".")) {

        } else {
          currentAmount = currentAmount + text;
        }
      } else {
        if (currentAmount == "") {
          currentAmount = "0.0";
        } else if (currentAmount == "0.0") {
          currentAmount = text;
        } else {
          currentAmount = currentAmount + text;
        }
      }
    });
  }

  buildPinRow() {
    var myGroup = AutoSizeGroup();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
    Expanded( // Constrains AutoSizeText to the width of the Row
    child:
        AutoSizeText(
          currentCurrency + currentAmount,
          maxLines: 1,
          group: myGroup,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'ModernEra',
            fontWeight: FontWeight.w700,
            fontSize: 60),
        ),
    ),
      ],
    );
  }

  buildFeeText(String text) {
    return Text(
      currentCurrency + ((double.parse(currentAmount).toDouble()/100) * 2).toString() + " fee",
      style: TextStyle(
        color: Colors.grey,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  buildExitButton() {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child:
                  Text(
                      "Show amount in EUR ▼",//"\$${EthAmountFormatter(tokenBalance).format()}",
                      style: TextStyle(
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                          fontSize: 16)
                    //style: Theme.of(context).textTheme.body2.apply(fontSizeDelta: 6),
                  ),
        ),
    new Align(alignment: Alignment.centerRight,
    child:
         MaterialButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context, false);
              }
            },
            height: 50.0,
            minWidth: 50.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
            child: Icon(Icons.clear, color: Colors.black),
          ),
        ),
      ],
    );
  }
}

class KeyboardNumber extends StatelessWidget {
  final String n;
  final Function() onPressed;
  KeyboardNumber({this.n, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.0,
      height: 60.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.9),
      ),
      alignment: Alignment.center,
      child: MaterialButton(
        padding: EdgeInsets.all(8.0),
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(60.0),
        ),
        height: 90.0,
        child: Text(
          "$n",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24*MediaQuery.of(context).textScaleFactor,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}




