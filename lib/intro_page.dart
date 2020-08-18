import 'package:flutter/material.dart';

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title:  Text("Hermez"),
            elevation: 0),
        body: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Expanded(
                  flex: 1,
                  child:
                  new Center(child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset('assets/hermes.png', width: 120, height: 120,),
                        SizedBox(height: 20),
                        Padding(
                          padding: EdgeInsets.all(30.0),
                          child: new Text("Lets start by creating a new wallet or restoring the existing one",
                              textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0)),
                        )
                      ])
                  )
              ),
              Container(
                margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0, bottom: 0.0),
                child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: SizedBox(
                        width: double.infinity,
                        child: RaisedButton(
                          onPressed: () async {
                            Navigator.of(context).pushNamed("/create");
                          },
                          disabledTextColor: Colors.grey,
                          disabledColor: Colors.blueGrey,
                          textColor: Colors.white,
                          color:Colors.black54,
                          padding: const EdgeInsets.all(20.0),
                          child: new Text(
                            "Create new wallet",
                          ),
                        )
                    )
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0, bottom: 40.0),
                child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: SizedBox(
                        width: double.infinity,
                        child: RaisedButton(
                          onPressed: () async {
                            Navigator.of(context).pushNamed("/import");
                          },
                          disabledTextColor: Colors.grey,
                          disabledColor: Colors.blueGrey,
                          textColor: Colors.white,
                          color:Colors.black54,
                          padding: const EdgeInsets.all(20.0),
                          child: new Text(
                            "Import wallet",
                          ),
                        )
                    )
                ),
              ),
            ]
        )
    );
  }
}
