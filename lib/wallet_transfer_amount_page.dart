import 'package:flutter/material.dart';
import 'package:hermez/service/network/model/L1_account.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/wallet_transaction_details_page.dart';

import 'components/wallet/transfer_amount_form.dart';
import 'context/wallet/wallet_handler.dart';

enum TransactionLevel { LEVEL1, LEVEL2 }

enum TransactionType { DEPOSIT, SEND, RECEIVE, WITHDRAW }

enum TransactionStatus { DRAFT, PENDING, CONFIRMED, INVALID }

class AmountArguments {
  final WalletHandler store;
  final TransactionType amountType;
  final L1Account account;
  //final Token token;

  AmountArguments(
    this.store,
    this.amountType,
    this.account,
    //this.token,
  );
}

class WalletAmountPage extends StatefulWidget {
  WalletAmountPage({Key key, this.arguments}) : super(key: key);

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
      appBar: new AppBar(
        title: new Text('Amount',
            style: TextStyle(
                fontFamily: 'ModernEra',
                color: HermezColors.blackTwo,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        centerTitle: true,
        elevation: 0.0,
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(null),
          ),
        ],
      ),
      body: TransferAmountForm(
        account: widget.arguments.account,
        store: widget.arguments.store,
        amountType: widget.arguments.amountType,
        onSubmit: (amount, token, address) async {
          //var success = await transferStore.transfer(address, amount);
          Navigator.pushReplacementNamed(context, "/transaction_details",
              arguments: TransactionDetailsArguments(
                  widget.arguments.store,
                  widget.arguments.amountType,
                  TransactionStatus.DRAFT,
                  widget.arguments.account,
                  amount,
                  widget.arguments.account.ethereumAddress,
                  address,
                  null));
          //if (success) {
          //Navigator.popUntil(context, ModalRoute.withName('/'));
          //}
        },
      ),
    );
  }
}
