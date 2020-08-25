import 'package:hermez/components/form/paper_form.dart';
import 'package:hermez/components/form/paper_input.dart';
import 'package:hermez/components/form/paper_validation_summary.dart';
import 'package:hermez/context/transfer/wallet_transfer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class TransferAmountForm extends HookWidget {
  TransferAmountForm({
    this.token,
    this.amount,
    @required this.onSubmit,
  });

  final String token;
  final int amount;
  final void Function(String token, String amount) onSubmit;

  @override
  Widget build(BuildContext context) {
    final toController = useTextEditingController(text: token);
    final amountController = useTextEditingController();
    final transferStore = useWalletTransfer(context);

    useEffect(() {
      if (token != null) toController.value = TextEditingValue(text: token);
      return null;
    }, [token]);

    return Container(
        padding: EdgeInsets.all(10),
        color: Colors.white,
        child: SingleChildScrollView(
          child: PaperForm(
            actionButtons: <Widget>[
              RaisedButton(
                child: const Text('Confirm'),
                onPressed: () {
                  this.onSubmit(
                    toController.value.text,
                    amountController.value.text,
                  );
                },
              )
            ],
            children: <Widget>[
              PaperValidationSummary(transferStore.state.errors.toList()),
              _buildTokenRow(context, null),
              _buildAmountRow(context, null),
              /*PaperInput(
                controller: toController,
                labelText: 'To',
                hintText: 'Name, Phone, Email, Eth address',
              ),*/
              /*PaperInput(
                controller: toController,
                labelText: 'For',
                hintText: 'Add a message',
              ),
              PaperInput(
                controller: amountController,
                labelText: 'Amount',
                hintText: 'And amount',
              ),*/
            ],
          ),
        ),
    );
  }


  Widget _buildTokenRow(BuildContext context, dynamic element) {
    // returns a row with the desired properties
    return Container(
        padding: EdgeInsets.only(bottom: 15.0),
        child:FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: BorderSide(color: Color.fromRGBO(245, 245, 245, 1.0))),
            onPressed: () {
              //Navigator.of(context).pushNamed("/account_details", arguments: WalletAccountDetailsArguments(element, color));
            },
            padding: EdgeInsets.all(20.0),
            color: Color.fromRGBO(245, 245, 245, 1.0),
            textColor: Colors.black,
            child: Row(
                children: <Widget>[
                  Expanded(child:
                  Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        child:
                        Text("Tether"/*element['name']*/,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24.0,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(top: 15.0),
                        child: Text("USDT",
                          style: TextStyle(
                            color: Color.fromRGBO(130, 130, 130, 1.0),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    ],
                  ),
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          child: Text("€998.45",
                            style: TextStyle(fontFamily: 'ModernEra',
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontSize: 24)
                            ,textAlign: TextAlign.right,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 15.0),
                          child: Text("100.345646 USDT",
                            style: TextStyle(fontFamily: 'ModernEra',
                                color: Color.fromRGBO(130, 130, 130, 1.0),
                                fontSize: 16,
                                fontWeight: FontWeight.w500)
                            ,textAlign: TextAlign.right,
                          ),
                        ),
                      ]),
                  //SizedBox(width: 10,),
                  //_getLeadingWidget("assets/arrow_down.png")
                ],
              ), //title to be name of the crypto
        ));
  }


  Widget _buildAmountRow(BuildContext context, dynamic element) {
    // returns a row with the desired properties
    return Container(
        padding: EdgeInsets.only(bottom: 15.0),
        child:FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: BorderSide(color: Color.fromRGBO(130, 130, 130, 1.0))),
            onPressed: () {
              //Navigator.of(context).pushNamed("/account_details", arguments: WalletAccountDetailsArguments(element, color));
            },
            padding: EdgeInsets.all(15.0),
            color: Colors.transparent,
            textColor: Colors.black,
            child: ListTile(
              title: Column(
                children: <Widget>[
                  Container(
                    child:
                    Text("EUR"/*element['name']*/,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                  Container(
                    child:
                    Text("50"/*element['name']*/,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 48.0,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                  Divider(
                    color: Colors.grey[150],
                    height: 40,
                    thickness: 1,
                  ),
                  Row(
                    children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Image.asset("assets/arrows_up_down.png")
                    ),
                    Expanded(
                      child: Text("59,658680 USDT",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromRGBO(130, 130, 130, 1.0),
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      child: Text("Max",
                        style: TextStyle(
                          color: Color.fromRGBO(130, 130, 130, 1.0),
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  ],)
                ],
              ), //title to be name of the crypto
            )
        ));
  }

  // takes in an object and color and returns a circle avatar with first letter and required color
  CircleAvatar _getLeadingWidget(String icon) {
    return new CircleAvatar(
        backgroundColor: Colors.white,
        child: Image.asset(icon)
    );
  }
}
