import 'package:hermezwallet/components/form/paper_form.dart';
import 'package:hermezwallet/components/form/paper_input.dart';
import 'package:hermezwallet/components/form/paper_validation_summary.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ConfirmMnemonic extends HookWidget {
  ConfirmMnemonic(
      {this.mnemonic, this.errors, this.onConfirm, this.onGenerateNew});

  final String mnemonic;
  final List<String> errors;
  final Function onConfirm;
  final Function onGenerateNew;

  @override
  Widget build(BuildContext context) {
    var mnemonicController = useTextEditingController();

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
                        PaperValidationSummary(this.errors),
                        PaperInput(
                          labelText: 'Confirm your seed',
                          hintText: 'Please type your seed phrase again',
                          maxLines: 2,
                          controller: mnemonicController,
                        )
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
                    child: OutlineButton(
                      child: const Text('Generate New'),
                      onPressed: this.onGenerateNew,
                      textColor: Colors.black,
                      padding: const EdgeInsets.all(20.0),
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
                      child: const Text('Confirm'),
                      disabledTextColor: Colors.grey,
                      disabledColor: Colors.blueGrey,
                      textColor: Colors.white,
                      color:Colors.black54,
                      padding: const EdgeInsets.all(20.0),
                      onPressed: this.onConfirm != null
                          ? () => this.onConfirm(mnemonicController.value.text)
                          : null,
                    )
                )
            ),
          ),
        ]);
    return Center(
      child: Container(
        margin: EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: PaperForm(
            padding: 30,
            actionButtons: <Widget>[
              OutlineButton(
                child: const Text('Generate New'),
                onPressed: this.onGenerateNew,
              ),
              RaisedButton(
                child: const Text('Confirm'),
                onPressed: this.onConfirm != null
                    ? () => this.onConfirm(mnemonicController.value.text)
                    : null,
              )
            ],
            children: <Widget>[
              PaperValidationSummary(this.errors),
              PaperInput(
                labelText: 'Confirm your seed',
                hintText: 'Please type your seed phrase again',
                maxLines: 2,
                controller: mnemonicController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
