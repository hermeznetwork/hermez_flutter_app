import 'package:flutter/services.dart';
import 'package:hermez/components/form/address_input.dart';
import 'package:hermez/components/form/amount_input.dart';
import 'package:hermez/components/form/paper_form.dart';
import 'package:hermez/components/form/paper_validation_summary.dart';
import 'package:hermez/components/wallet/account_row.dart';
import 'package:hermez/context/transfer/wallet_transfer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';

class TransferSummaryForm extends HookWidget {
  TransferSummaryForm({
    this.token,
    this.amount,
    this.amountType,
    @required this.onSubmit,
  });

  final dynamic token;
  final int amount;
  final AmountType amountType;
  final void Function(String token, String amount) onSubmit;

  @override
  Widget build(BuildContext context) {
    //final toController = useTextEditingController(text: token);
    final amountController = useTextEditingController();
    final addressController = useTextEditingController();


    //final transferStore = useWalletTransfer(context);

    /*useEffect(() {
      if (token != null) toController.value = TextEditingValue(text: token);
      return null;
    }, [token]);*/

    return Container(
        padding: EdgeInsets.all(10),
        color: Colors.white,
          child:
              ListView(
                children: ListTile.divideTiles(
                    context: context,
                    color: Colors.black,
                    tiles: [
                      ListTile(
                        title: Text('From'),
                        trailing: Text('From'),
                      ),
                      ListTile(
                        title: Text('To'),
                      ),
                      ListTile(
                        title: Text('Fee'),
                      ),
                      _buildAmountRow(context, null, amountController),
                    ]
                ).toList(),
              ),
    );
  }

  Widget _buildAmountRow(BuildContext context, dynamic element, dynamic amountController) {
    // returns a row with the desired properties
    return Container(
        padding: EdgeInsets.only(bottom: 15.0),
        child:FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: BorderSide(color: Color.fromRGBO(130, 130, 130, 1.0))),
            padding: EdgeInsets.all(10.0),
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
                    margin: EdgeInsets.only(top: 10.0),
                    child:
                    AmountInput(
                      controller: amountController,
                    ),
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

  Future<String> getClipBoardData() async {
    ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
    return data.text;
  }
}
