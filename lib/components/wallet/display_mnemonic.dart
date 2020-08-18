import 'package:hermezwallet/components/copyButton/copy_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DisplayMnemonic extends HookWidget {
  DisplayMnemonic({this.mnemonic, this.onNext});

  final String mnemonic;
  final Function onNext;

  @override
  Widget build(BuildContext context) {
    return new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
              flex: 1,
              child:
              Container(
                  margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0, bottom: 40.0),
                  child:
                  new Center(child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Get a piece of paper, write down your seed phrase and keep it safe. This is the only way to recover your funds.",
                          textAlign: TextAlign.center, style: TextStyle(fontSize: 18.0)
                        ),
                        SizedBox(height: 40),
                        Container(
                          padding: EdgeInsets.all(30),
                          decoration: BoxDecoration(border: Border.all()),
                          child: Text(
                            this.mnemonic,
                            textAlign: TextAlign.center, style: TextStyle(fontSize: 23.0)
                          ),
                        ),
                      ])
                  )
              )
          ),
          Container(
            margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0, bottom: 0.0),
            child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: SizedBox(
                    width: double.infinity,
                    child: CopyButton(
                      text: const Text('Copy'),
                      value: this.mnemonic,
                      ),
                    )
                )
            ),
          Container(
            margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0, bottom: 40.0),
            child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                      onPressed: this.onNext,
                      disabledTextColor: Colors.grey,
                      disabledColor: Colors.blueGrey,
                      textColor: Colors.white,
                      color:Colors.black54,
                      padding: const EdgeInsets.all(20.0),
                      child: new Text(
                        "Next",
                      ),
                    )
                )
            ),
          ),
        ]);
    /*return Center(
      child: Container(
        margin: EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text(
                "Get a piece of paper, write down your seed phrase and keep it safe. This is the only way to recover your funds.",
                textAlign: TextAlign.center,
              ),
              Container(
                margin: EdgeInsets.all(25),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(border: Border.all()),
                child: Text(
                  this.mnemonic,
                  textAlign: TextAlign.center,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  CopyButton(
                    text: const Text('Copy'),
                    value: this.mnemonic,
                  ),
                  RaisedButton(
                    child: const Text('Next'),
                    onPressed: this.onNext,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );*/
  }
}
