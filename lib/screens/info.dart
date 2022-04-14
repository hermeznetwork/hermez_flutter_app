import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hermez/utils/hermez_colors.dart';

class InfoArguments {
  final String imagePath;
  final bool showButton;
  final String message;
  final double iconSize;
  final Function onFinished;

  InfoArguments(this.imagePath, this.showButton, this.message,
      {this.iconSize = 150, this.onFinished});
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
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final InfoArguments args = ModalRoute.of(context).settings.arguments;
    if (args.showButton == false) {
      startTime(context);
    }
    return Scaffold(
      backgroundColor: HermezColors.quaternaryThree,
      body: Container(
          margin: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/' + args.imagePath,
                    width: args.iconSize,
                    height: args.iconSize,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: Text(args.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: HermezColors.dark,
                      fontSize: 20,
                      height: 1.5,
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
                            borderRadius: BorderRadius.circular(50.0),
                            side: BorderSide(color: HermezColors.secondary)),
                        onPressed: () {
                          route();
                        },
                        padding: EdgeInsets.all(15.0),
                        color: HermezColors.secondary,
                        textColor: Colors.white,
                        child: Text("Done",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                    )
                  : Container()
            ],
          )),
    );
  }

  startTime(BuildContext context) async {
    var duration = new Duration(seconds: 2);
    timer = Timer(duration, route);
  }

  route() {
    if (widget.arguments.onFinished != null) {
      widget.arguments.onFinished();
    } else if (Navigator.canPop(context)) {
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
