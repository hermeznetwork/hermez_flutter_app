import 'package:hermezwallet/components/form/paper_form.dart';
import 'package:hermezwallet/components/form/paper_input.dart';
import 'package:hermezwallet/components/form/paper_radio.dart';
import 'package:hermezwallet/components/form/paper_validation_summary.dart';
import 'package:hermezwallet/model/wallet_setup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ImportWalletForm extends HookWidget {
  ImportWalletForm({this.onImport, this.errors});

  final Function(WalletImportType type, String value) onImport;
  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    var importType = useState(WalletImportType.mnemonic);
    var inputController = useTextEditingController();

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
                    Row(
                      children: <Widget>[
                        PaperRadio(
                          "Seed",
                          groupValue: importType.value,
                          value: WalletImportType.mnemonic,
                          onChanged: (value) => importType.value = value,
                        ),
                        PaperRadio(
                          "Private Key",
                          groupValue: importType.value,
                          value: WalletImportType.privateKey,
                          onChanged: (value) => importType.value = value,
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Visibility(
                            child: fieldForm(
                                label: 'Private Key',
                                hintText: 'Type your private key',
                                controller: inputController),
                            visible: importType.value == WalletImportType.privateKey),
                        Visibility(
                            child: fieldForm(
                                label: 'Seed phrase',
                                hintText: 'Type your seed phrase',
                                controller: inputController),
                            visible: importType.value == WalletImportType.mnemonic),
                      ],
                    ),
                  ])
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
                      onPressed: this.onImport != null
                          ? () => this
                          .onImport(importType.value, inputController.value.text)
                          : null,
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
        ]);
  }

  Widget fieldForm({
    String label,
    String hintText,
    TextEditingController controller,
  }) {
    return Column(
      children: <Widget>[
        PaperValidationSummary(errors),
        PaperInput(
          labelText: label,
          hintText: hintText,
          maxLines: 3,
          controller: controller,
        ),
      ],
    );
  }
}
