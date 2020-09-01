import 'package:hermez/components/wallet/transfer_form.dart';
import 'package:hermez/context/transfer/wallet_transfer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';

import 'components/wallet/loading.dart';
import 'components/wallet/transfer_amount_form.dart';
import 'components/wallet/transaction_details_form.dart';

class TransactionDetailsArguments {
  final AmountType amountType;
  final dynamic token;
  final String amount;

  TransactionDetailsArguments(this.amountType, this.token, this.amount);
}

class TransactionDetailsPage extends StatefulWidget {
  TransactionDetailsPage({Key key, this.arguments}) : super(key : key);

  final TransactionDetailsArguments arguments;

  @override
  _TransactionDetailsPageState createState() => _TransactionDetailsPageState();
}
class _TransactionDetailsPageState extends State<TransactionDetailsPage> {

  @override
  Widget build(BuildContext context) {
    //var transferStore = useWalletTransfer(context);
    //var qrcodeAddress = useState();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.arguments.amountType == AmountType.DEPOSIT ?  "Deposit" : "Send"),
        elevation: 0.0,
      ),
      body:  TransferSummaryForm(
              token: widget.arguments.token,
              //amountType: widget.arguments.amountType,
              onSubmit: (address, amount) async {
                //var success = await transferStore.transfer(address, amount);
                  //Navigator.pushNamed(context, "/transfer_summary", arguments: TransactionDetailsArguments(widget.arguments.amountType, widget.arguments.token, amount));
                //if (success) {
                  //Navigator.popUntil(context, ModalRoute.withName('/'));
                //}
              },
            ),
    );
  }
}
