import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hermez/utils/hermez_colors.dart';

class InfoArguments {
  final String imagePath;
  final bool showButton;
  final String message;

  InfoArguments(this.imagePath, this.showButton, this.message);
}

class InfoPage extends StatefulWidget {
  InfoPage({Key key, this.arguments}) : super(key: key);

  final InfoArguments arguments;

  @override
  _InfoPageState createState() => _InfoPageState();
}

Timer timer;

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    final InfoArguments args = ModalRoute.of(context).settings.arguments;
    if (args.showButton == false) {
      startTime(context);
    }
    return Scaffold(
      backgroundColor: HermezColors.lightOrange,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 65, right: 65),
            child: Align(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/' + args.imagePath,
                width: 150,
                height: 150,
              ),
            ),
          ),
          SizedBox(height: 32),
          Align(
            alignment: Alignment.center,
            child: Text(args.message,
                style: TextStyle(
                  color: HermezColors.black,
                  fontSize: 20,
                  fontFamily: 'ModernEra',
                  fontWeight: FontWeight.w700,
                )),
          ),
          SizedBox(height: 72),
          args.showButton
              ? Align(
                  alignment: Alignment.center,
                  child: FlatButton(
                    minWidth: 152.0,
                    height: 56,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: BorderSide(color: HermezColors.darkOrange)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    padding: EdgeInsets.all(15.0),
                    color: HermezColors.darkOrange,
                    textColor: Colors.white,
                    child: Text("Done",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  startTime(BuildContext context) async {
    var duration = new Duration(seconds: 2);
    timer = Timer(duration, route);
  }

  route() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    if (timer != null) {
      timer.cancel();
    }
    super.dispose();
  }
}
