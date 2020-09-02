import 'package:hermez/components/wallet/transfer_form.dart';
import 'package:hermez/context/transfer/wallet_transfer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/wallet_transaction_details_page.dart';

import 'components/wallet/loading.dart';
import 'components/wallet/transfer_amount_form.dart';

enum TransactionType {
  DEPOSIT,
  SEND,
  WITHDRAW
}

enum TransactionStatus {
  PENDING,
  CONFIRMED,
  INVALID
}

class AmountArguments {
  final TransactionType amountType;
  final dynamic token;

  AmountArguments(this.amountType, this.token);
}

class WalletAmountPage extends StatefulWidget {
  WalletAmountPage({Key key, this.arguments}) : super(key : key);

  final AmountArguments arguments;

  @override
  _WalletAmountPageState createState() => _WalletAmountPageState();
}
class _WalletAmountPageState extends State<WalletAmountPage> {

  @override
  Widget build(BuildContext context) {
    //var transferStore = useWalletTransfer(context);
    //var qrcodeAddress = useState();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.arguments.amountType == TransactionType.DEPOSIT ?  "Deposit" : "Send"),
        elevation: 0.0,
      ),
      body:  TransferAmountForm(
              token: widget.arguments.token,
              amountType: widget.arguments.amountType,
              onSubmit: (address, amount) async {
                //var success = await transferStore.transfer(address, amount);
                Navigator.pushReplacementNamed(context, "/transaction_details", arguments: TransactionDetailsArguments(widget.arguments.amountType, widget.arguments.token, amount));
                //if (success) {
                  //Navigator.popUntil(context, ModalRoute.withName('/'));
                //}
              },
            ),
    );
  }
}
