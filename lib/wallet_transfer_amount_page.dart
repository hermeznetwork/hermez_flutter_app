import 'package:flutter/material.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/wallet_transaction_details_page.dart';
import 'package:hermez_plugin/addresses.dart';
import 'package:hermez_plugin/model/account.dart';

import 'components/wallet/transfer_amount_form.dart';
import 'context/wallet/wallet_handler.dart';

enum TransactionLevel { LEVEL1, LEVEL2 }

enum TransactionType { DEPOSIT, SEND, RECEIVE, WITHDRAW, EXIT, FORCEEXIT, MOVE }

enum TransactionStatus { DRAFT, PENDING, CONFIRMED, INVALID }

class AmountArguments {
  final WalletHandler store;
  final TransactionLevel txLevel;
  final TransactionType transactionType;
  final Account account;
  //final Token token;

  AmountArguments(
    this.store,
    this.txLevel,
    this.transactionType,
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
    String operation;
    if (widget.arguments.transactionType == TransactionType.SEND) {
      operation = "send";
    } else if (widget.arguments.transactionType == TransactionType.MOVE ||
        widget.arguments.transactionType == TransactionType.FORCEEXIT) {
      operation = "move";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        title: new Text(operation[0].toUpperCase() + operation.substring(1),
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
        amountType: widget.arguments.transactionType,
        txLevel: widget.arguments.txLevel,
        onSubmit: (amount, token, address) async {
          String addressTo;
          if (widget.arguments.transactionType == TransactionType.EXIT &&
              address.isEmpty) {
            addressTo =
                getEthereumAddress(widget.arguments.account.hezEthereumAddress);
          } else {
            addressTo = address;
          }
          //var success = await transferStore.transfer(address, amount);
          Navigator.pushReplacementNamed(context, "transaction_details",
              arguments: TransactionDetailsArguments(
                wallet: widget.arguments.store,
                transactionType: widget.arguments.transactionType,
                status: TransactionStatus.DRAFT,
                account: widget.arguments.account,
                token: widget.arguments.account.token,
                amount: amount,
                addressFrom: widget.arguments.account.hezEthereumAddress,
                addressTo: addressTo,
              ));
          //if (success) {
          //Navigator.popUntil(context, ModalRoute.withName('/'));
          //}
        },
      ),
    );
  }
}
