import 'package:flutter/material.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/service/network/model/L1_account.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';

import 'components/wallet/transaction_details_form.dart';
import 'context/transfer/wallet_transfer_provider.dart';

class TransactionDetailsArguments {
  final WalletHandler store;
  final TransactionType amountType;
  final TransactionStatus status;
  final L1Account account;
  final double amount;
  final String transactionHash;
  final String addressFrom;
  final String addressTo;
  final DateTime transactionDate;

  TransactionDetailsArguments(
      this.store,
      this.amountType,
      this.status,
      this.account,
      this.amount,
      this.transactionHash,
      this.addressFrom,
      this.addressTo,
      this.transactionDate);
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
    final _scaffoldKey = GlobalKey<ScaffoldState>();

    var transferStore = useWalletTransfer(context);
    var title = "";
    switch (widget.arguments.amountType) {
      case TransactionType.SEND:
        title = "Send";
        break;
      case TransactionType.DEPOSIT:
        title = "Deposit";
        break;
      case TransactionType.WITHDRAW:
        title = "Withdraw";
        break;
      case TransactionType.RECEIVE:
        title = "Receive";
        break;
    }

    //var qrcodeAddress = useState();

    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(title,
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
              store: widget.arguments.store,
              account: widget.arguments.account,
              transactionHash: widget.arguments.transactionHash,
              transactionType: widget.arguments.amountType,
              status: widget.arguments.status,
              addressFrom: widget.arguments.addressFrom,
              addressTo: widget.arguments.addressTo,
              transactionDate: widget.arguments.transactionDate,
              onSubmit: (address, amount) async {
                var success = await transferStore.transferEth(
                    widget.arguments.store.state.privateKey, address, amount);
                //Navigator.pushNamedAndRemoveUntil(context, "/", (Route<dynamic> route) => false);
                if (success) {
                  Navigator.of(context)
                      .pushReplacementNamed("/transaction_info");
                } else {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(transferStore.state.errors.first),
                  ));
                }
              },
            ),
          ),
          widget.arguments.status == TransactionStatus.DRAFT
              ? Column(children: <Widget>[
                  Container(
                    height: 52,
                    margin: EdgeInsets.only(
                        left: 16.0, right: 16.0, top: 20.0, bottom: 20.0),
                    width: double.infinity,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                          side: BorderSide(color: HermezColors.darkOrange)),
                      onPressed: () async {
                        var success = await transferStore.transferEth(
                            widget.arguments.store.state.privateKey,
                            widget.arguments.addressTo,
                            widget.arguments.amount.toString());
                        //Navigator.pushNamedAndRemoveUntil(context, "/", (Route<dynamic> route) => false);
                        if (success) {
                          Navigator.of(context)
                              .pushReplacementNamed("/transaction_info");
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // return object of type Dialog
                              return AlertDialog(
                                title: new Text("Transfer Error"),
                                content:
                                    new Text(transferStore.state.errors.first),
                                actions: <Widget>[
                                  // usually buttons at the bottom of the dialog
                                  new FlatButton(
                                    textColor: HermezColors.orange,
                                    child: new Text("Close"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                          /*_scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text(transferStore.state.errors.first),
                          ));*/
                        }
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
              : Container()
        ],
      ),
    );
  }

  Widget _buildAmountRow() {
    final String currency =
        widget.arguments.store.state.defaultCurrency.toString().split('.').last;
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
                    currency == "EUR"
                        ? "€" +
                            (widget.arguments.amount *
                                    (widget.arguments.account.USD *
                                        widget.arguments.store.state
                                            .exchangeRatio))
                                .toStringAsFixed(2)
                        : '\$' +
                            (widget.arguments.amount *
                                    widget.arguments.account.USD)
                                .toStringAsFixed(2),
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
                  (widget.arguments.amount).toString() +
                      " " +
                      widget.arguments.account.tokenSymbol,
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
