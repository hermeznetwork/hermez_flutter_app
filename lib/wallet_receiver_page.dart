import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

enum ReceiverType {
  REQUEST,
  SEND
}

class ReceiverArguments {
  final ReceiverType receiverType;

  ReceiverArguments(this.receiverType);
}

class ReceiverPage extends StatefulWidget {
  ReceiverPage({Key key, this.arguments}) : super(key : key);

  final ReceiverArguments arguments;

  @override
  _ReceiverPageState createState() => _ReceiverPageState();
}

class _ReceiverPageState extends State<ReceiverPage> {
  String currentCurrency = "€";
  String currentAmount = "0.0";

  final List<MaterialColor> _colors = [
    //to show different colors for different cryptos
    Colors.lightBlue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.cyan
  ];

  final List<String> _contactNames = [
    //to show different colors for different cryptos
    "Amélie",
    "Arnau Cádiz",
    "Julie Andrieu",
  ];

  final List<String> _contactSubtitles = [
    //to show different colors for different cryptos
    "amelie.rose@gmail.com",
    "0x3b66ba...b6aa14",
    "+33 456 432 234",
  ];

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
    // var qrcodeAddress = useState();

    return Scaffold(body: SafeArea(
      child: Column(
        children: <Widget>[
          buildExitButton(),
          buildToRow(),
          _buildContactList(),
          buildButtonRow(),
        ],
      ),
    ),
    );
  }

  buildToRow() {
    return
      Column(
        children: <Widget>[
          Divider(
            color: Colors.grey[150],
            height: 20,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 40, top: 20, bottom: 20, right: 20),
                child:
                  Text("To",
                    style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    ))
              ),
              Expanded(
                child:
                  Text("Name, Phone, Email, Eth address",
                    maxLines: 1,
                    style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16.0,
                  )),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 0, right: 30),
                child:
                IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        "/qrcode_reader",
                        arguments: (scannedAddress) async {
                          //qrcodeAddress.value = scannedAddress.toString();
                        },
                      );
                    }
                ),
              ),
            ],
          ),
          Divider(
            color: Colors.grey[150],
            height: 20,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          Row(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(left: 40, top: 20, bottom: 20, right: 20),
                  child:
                  Text("For",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ))
              ),
              Expanded(
                child:
                Text("Add a message",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16.0,
                    )),
              ),
            ],
          ),
          Divider(
            color: Colors.grey[150],
            height: 20,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          )],
    );
  }

  //widget that builds the list
  Widget _buildContactList() {
    return Expanded(
      child: Container(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: 5, //set the item count so that index won't be out of range
              padding:
              const EdgeInsets.all(16.0), //add some padding to make it look good
              itemBuilder: (context, i) {
                //item builder returns a row for each index i=0,1,2,3,4
                //if (i.isOdd) return Divider(); //if index = 1,3,5 ... return a divider to make it visually appealing

                int index = i; //get the actual index excluding dividers.

                if (index == 0) return Padding(
                    padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
                        child:Text("Suggested",
                            style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                )));
                if (index == 2) return Padding(
                    padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
                    child:Text("Contacts",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        )));
                print(index);
                if (index > 2) {
                  index = i - 2;
                } else {
                  index = 0;
                }
                final MaterialColor color = _colors[index %
                    _colors.length]; //iterate through indexes and get the next colour
                final String name = _contactNames[index %
                    _contactNames.length];
                final String subtitle = _contactSubtitles[index %
                    _contactSubtitles.length];
                return _buildRow(color, name, subtitle, index == 0); //build the row widget
              })
      ),
    );
  }

  Widget _buildRow(MaterialColor color, String name, String subtitle, bool isChecked) {
    // returns a row with the desired properties
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        child: new Text(name[0],
          style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,)),
      ),
      title: Text(
          name,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          )
      ),
      subtitle: Text(subtitle),
      trailing: isChecked ? Icon(Icons.check) : null,
      onTap: () {
        Text('Another data');
      },
    );
  }

  buildButtonRow() {
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
                //Navigator.of(context).pushNamed("/receiver");
              },
              padding: EdgeInsets.all(16.0),
              color: Colors.black,
              textColor: Colors.white,
              child: Text(widget.arguments.receiverType == ReceiverType.SEND ? "Send" : "Request",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
          SizedBox(width: 20.0),
        ]
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
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(6.0),
            child:
               Center(
              child:
                Text(
                "€20", //"\$${EthAmountFormatter(tokenBalance).format()}",
                style: TextStyle(
                    fontFamily: 'ModernEra',
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    fontSize: 20)
              //style: Theme.of(context).textTheme.body2.apply(fontSizeDelta: 6),
              ),
            ),
            ),
            Text(
                "from DAI ▼",
                textAlign: TextAlign.center,//"\$${EthAmountFormatter(tokenBalance).format()}",
                style: TextStyle(
                    fontFamily: 'ModernEra',
                    fontWeight: FontWeight.w700,
                    color: Colors.grey,
                    fontSize: 12)
              //style: Theme.of(context).textTheme.body2.apply(fontSizeDelta: 6),
            ),

          ],
        ),
        new Align(alignment: Alignment.centerRight,
        child:
          Padding(
          padding: EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: Icon(Icons.clear, color: Colors.black),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context, false);
                }/* else {
                  SystemNavigator.pop();
                }*/
              },
            ),
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




