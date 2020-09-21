import 'package:flutter/material.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';

import 'components/wallet/transaction_details_form.dart';

class TransactionDetailsArguments {
  final TransactionType amountType;
  final dynamic token;
  final String amount;

  TransactionDetailsArguments(this.amountType, this.token, this.amount);
}

class TransactionDetailsPage extends StatefulWidget {
  TransactionDetailsPage({Key key, this.arguments}) : super(key: key);

  final TransactionDetailsArguments arguments;

  @override
  _TransactionDetailsPageState createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  @override
  Widget build(BuildContext context) {
    // final amountController = useTextEditingController();
    //var transferStore = useWalletTransfer(context);
    //var qrcodeAddress = useState();

    return Scaffold(
      appBar: new AppBar(
        title: new Text(
            widget.arguments.amountType == TransactionType.DEPOSIT
                ? "Deposit"
                : "Send",
            style: TextStyle(
                fontFamily: 'ModernEra',
                color: HermezColors.blackTwo,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: HermezColors.lightOrange,
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(null),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildAmountRow(),
          Expanded(
            child: TransferSummaryForm(
              token: widget.arguments.token,
              transactionType: widget.arguments.amountType,
              onSubmit: (address, amount) async {
                //var success = await transferStore.transfer(address, amount);
                //Navigator.pushNamedAndRemoveUntil(context, "/", (Route<dynamic> route) => false);
                Navigator.of(context).pushReplacementNamed("/transaction_info");
                //if (success) {
                //Navigator.popUntil(context, ModalRoute.withName('/'));
                //}
              },
            ),
          ),
          //transactionDate == null
          /* ? */ Column(children: <Widget>[
            Container(
              height: 52,
              margin: EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 20.0, bottom: 20.0),
              width: double.infinity,
              child: FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                    side: BorderSide(color: HermezColors.darkOrange)),
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacementNamed("/transaction_info");
                  //this.onSubmit(
                  //amountController.value.text,
                  //amountController.value.text,
                  //addressController.value.text);
                },
                disabledColor: HermezColors.blueyGreyTwo,
                padding: EdgeInsets.all(18.0),
                color: HermezColors.darkOrange,
                textColor: Colors.white,
                child: Text("Send",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'ModernEra',
                      fontWeight: FontWeight.w700,
                    )),
              ),
            ),
          ])
          // : Container()
        ],
      ),
    );
  }

  Widget _buildAmountRow() {
    // returns a row with the desired properties
    return Container(
        color: HermezColors.lightOrange,
        padding: EdgeInsets.only(bottom: 15.0),
        child: ListTile(
          title: Column(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(top: 20.0),
                  child: Text(
                    "€26.31",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: HermezColors.blackTwo,
                      fontSize: 32.0,
                      fontFamily: 'ModernEra',
                      fontWeight: FontWeight.w800,
                    ),
                  )),
              Container(
                margin: EdgeInsets.only(top: 15.0, bottom: 30.0),
                child: Text(
                  "24.56 USDT",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: HermezColors.steel,
                    fontSize: 18,
                    fontFamily: 'ModernEra',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ), //title to be name of the crypto
        ));
  }
}
