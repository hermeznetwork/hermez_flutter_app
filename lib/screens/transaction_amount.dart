import 'package:flutter/material.dart';
import 'package:hermez/screens/transaction_details.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_plugin/addresses.dart';
import 'package:hermez_plugin/environment.dart';
import 'package:hermez_plugin/model/account.dart';
import 'package:hermez_plugin/model/token.dart';

import '../components/wallet/transfer_amount_form.dart';
import '../context/wallet/wallet_handler.dart';
import 'qrcode.dart';

enum TransactionLevel { LEVEL1, LEVEL2 }

enum TransactionType { DEPOSIT, SEND, RECEIVE, WITHDRAW, EXIT, FORCEEXIT }

enum TransactionStatus { DRAFT, PENDING, CONFIRMED, INVALID }

class TransactionAmountArguments {
  final TransactionLevel txLevel;
  final TransactionType transactionType;
  final Account account;
  final Token token;
  final double amount;
  final String addressTo;
  final bool allowChangeLevel;
  final WalletHandler store;

  TransactionAmountArguments(this.store, this.txLevel, this.transactionType,
      {this.account,
      this.token,
      this.amount,
      this.addressTo,
      this.allowChangeLevel});
}

class TransactionAmountPage extends StatefulWidget {
  TransactionAmountPage({Key key, this.arguments}) : super(key: key);

  final TransactionAmountArguments arguments;

  @override
  _TransactionAmountPageState createState() => _TransactionAmountPageState();
}

class _TransactionAmountPageState extends State<TransactionAmountPage> {
  @override
  Widget build(BuildContext context) {
    String operation = getTitle();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        title: widget.arguments.transactionType == TransactionType.RECEIVE
            ? Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text(
                      'Amount',
                      style: TextStyle(
                          fontFamily: 'ModernEra',
                          color: HermezColors.blackTwo,
                          fontWeight: FontWeight.w800,
                          fontSize: 20),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          color: HermezColors.steel),
                      padding: EdgeInsets.only(
                          left: 12.0, right: 12.0, top: 4, bottom: 4),
                      child: Text(
                        widget.arguments.txLevel == TransactionLevel.LEVEL1
                            ? "L1"
                            : "L2",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : new Text(operation[0].toUpperCase() + operation.substring(1),
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
        txLevel: widget.arguments.txLevel,
        transactionType: widget.arguments.transactionType,
        account: widget.arguments.account,
        token: widget.arguments.token,
        amount: widget.arguments.amount,
        allowChangeLevel: widget.arguments.allowChangeLevel,
        addressTo: widget.arguments.addressTo,
        store: widget.arguments.store,
        onSubmit: (amount, token, fee, feeToken, address, gasLimit, gasPrice,
            depositGasLimit) async {
          if (widget.arguments.transactionType == TransactionType.RECEIVE) {
            Navigator.of(context).pushReplacementNamed("/qrcode",
                arguments: QRCodeArguments(
                    qrCodeType: QRCodeType.REQUEST_PAYMENT,
                    code: widget.arguments.txLevel == TransactionLevel.LEVEL1
                        ? widget.arguments.store.state.ethereumAddress
                        : getHermezAddress(
                            widget.arguments.store.state.ethereumAddress),
                    store: widget.arguments.store,
                    amount: amount,
                    token: token,
                    isReceive: true));
          } else {
            String addressTo;
            if (widget.arguments.transactionType == TransactionType.DEPOSIT) {
              addressTo = getCurrentEnvironment().contracts['Hermez'];
            } else if (widget.arguments.transactionType ==
                    TransactionType.EXIT &&
                address.isEmpty) {
              addressTo = getEthereumAddress(
                  widget.arguments.account.hezEthereumAddress);
            } else {
              addressTo = address;
            }
            //var success = await transferStore.transfer(address, amount);
            Navigator.pushReplacementNamed(context, "/transaction_details",
                arguments: TransactionDetailsArguments(
                    wallet: widget.arguments.store,
                    transactionType: widget.arguments.transactionType,
                    status: TransactionStatus.DRAFT,
                    account: widget.arguments.account,
                    token: widget.arguments.account.token,
                    amount: amount,
                    addressFrom: widget.arguments.account.hezEthereumAddress,
                    addressTo: addressTo,
                    fee: fee,
                    gasLimit: gasLimit,
                    gasPrice: gasPrice,
                    feeToken: feeToken,
                    depositGasLimit: depositGasLimit));
          }
        },
      ),
    );
  }

  String getTitle() {
    String operation = "amount";
    if (widget.arguments.transactionType == TransactionType.SEND) {
      operation = "send";
    } else if (widget.arguments.transactionType == TransactionType.EXIT ||
        widget.arguments.transactionType == TransactionType.FORCEEXIT ||
        widget.arguments.transactionType == TransactionType.DEPOSIT ||
        widget.arguments.transactionType == TransactionType.WITHDRAW) {
      operation = "move";
    } else if (widget.arguments.transactionType == TransactionType.RECEIVE) {
      operation = "receive";
    }
    return operation;
  }
}
