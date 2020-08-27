import 'package:hermez/components/wallet/transfer_form.dart';
import 'package:hermez/context/transfer/wallet_transfer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'components/wallet/loading.dart';
import 'components/wallet/transfer_amount_form.dart';

enum AmountType {
  DEPOSIT,
  SEND,
  WITHDRAW
}

class AmountArguments {
  final AmountType amountType;
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
        title: Text(widget.arguments.amountType == AmountType.DEPOSIT ?  "Deposit" : "Send"),
        elevation: 0.0,
      ),
      body:  TransferAmountForm(
              token: widget.arguments.token,
              amountType: widget.arguments.amountType,
              onSubmit: (address, amount) async {
                //var success = await transferStore.transfer(address, amount);

                //if (success) {
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                //}
              },
            ),
    );
  }
}
