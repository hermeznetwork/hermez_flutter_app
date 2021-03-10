import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/model/wallet.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';
import 'package:hermez_plugin/addresses.dart';
import 'package:hermez_plugin/model/account.dart';
import 'package:hermez_plugin/model/recommended_fee.dart';
import 'package:hermez_plugin/utils.dart';
import 'package:web3dart/web3dart.dart' as web3;

import 'components/wallet/transaction_details_form.dart';
import 'context/transfer/wallet_transfer_provider.dart';

class TransactionDetailsArguments {
  final WalletHandler wallet;
  final bool isTransactionBeingSigned;
  final TransactionType transactionType;
  final WalletDefaultCurrency preferredCurrency;
  final List<int> fiatExchangeRates;
  final Account account;
  final String addressFrom;
  final String addressTo;
  final double amount;
  final int fee;
  final bool instantWithdrawal;
  final bool completeDelayedWithdrawal;
  final String transactionHash;
  final TransactionStatus status;
  final DateTime transactionDate;

  TransactionDetailsArguments(
      {this.wallet,
      this.isTransactionBeingSigned,
      this.transactionType,
      this.preferredCurrency,
      this.fiatExchangeRates,
      this.account,
      this.addressFrom,
      this.addressTo,
      this.amount,
      this.fee,
      this.instantWithdrawal,
      this.completeDelayedWithdrawal,
      this.transactionHash,
      this.status,
      this.transactionDate});
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

    //var qrcodeAddress = useState();

    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(getTitleLabel(),
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
              store: widget.arguments.wallet,
              account: widget.arguments.account,
              transactionHash: widget.arguments.transactionHash,
              transactionType: widget.arguments.transactionType,
              status: widget.arguments.status,
              addressFrom: widget.arguments.addressFrom,
              addressTo: widget.arguments.addressTo,
              transactionDate: widget.arguments.transactionDate,
              onSubmit: (address, amount) async {
                var success = await transferStore.transferEth(
                    widget.arguments.wallet.state.ethereumPrivateKey,
                    address,
                    amount);
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
                        var success = false;
                        if (widget.arguments.wallet.state.txLevel ==
                            TransactionLevel.LEVEL1) {
                          success = await transferStore.transferEth(
                              widget.arguments.wallet.state.ethereumPrivateKey,
                              widget.arguments.addressTo,
                              widget.arguments.amount.toString());
                        } else {
                          success = await handleFormSubmit();
                        }

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
                                content: new Text(
                                    widget.arguments.wallet.state.txLevel ==
                                            TransactionLevel.LEVEL1
                                        ? transferStore.state.errors.first
                                        : ""),
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
                      child: Text(getButtonLabel(),
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
    final String currency = widget.arguments.wallet.state.defaultCurrency
        .toString()
        .split('.')
        .last;
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
                                    (widget.arguments.account.token.USD *
                                        widget.arguments.wallet.state
                                            .exchangeRatio))
                                .toStringAsFixed(2)
                        : '\$' +
                            (widget.arguments.amount *
                                    widget.arguments.account.token.USD)
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
                      widget.arguments.account.token.symbol,
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

  /// Converts the transaction type to a readable title label
  ///
  /// @returns {string} - Button label
  String getTitleLabel() {
    var title = "";
    switch (widget.arguments.transactionType) {
      case TransactionType.SEND:
        title = "Send";
        break;
      case TransactionType.DEPOSIT:
        title = "Deposit";
        break;
      case TransactionType.WITHDRAW:
        title = "Withdraw";
        break;
      case TransactionType.EXIT:
        title = 'Withdraw';
        break;
      case TransactionType.FORCEEXIT:
        title = 'Withdraw';
        break;
      case TransactionType.RECEIVE:
        title = "Receive";
        break;
    }
    return title;
  }

  /// Converts the transaction type to a readable button label
  ///
  /// @returns {string} - Button label
  String getButtonLabel() {
    switch (widget.arguments.transactionType) {
      case TransactionType.DEPOSIT:
        return 'Deposit';
      case TransactionType.SEND:
        return 'Send';
      case TransactionType.EXIT:
        return 'Withdraw';
      case TransactionType.WITHDRAW:
        return 'Withdraw';
      case TransactionType.FORCEEXIT:
        return 'Force Withdrawal';
      default:
        return '';
    }
  }

  /// Calculates the fee for the transaction.
  /// It takes the appropriate recomended fee in USD from the coordinator
  /// and converts it to token value.
  /// @param {Object} fees - The recommended Fee object returned by the Coordinator
  /// @param {Boolean} iExistingAccount - Whether it's a existingAccount transfer
  /// @returns {number} - Transaction fee
  double getFee(RecommendedFee fees, bool isExistingAccount) {
    if (widget.arguments.account.token.USD == 0) {
      return 0;
    }

    final fee = (isExistingAccount ||
            widget.arguments.transactionType == TransactionType.EXIT)
        ? fees.existingAccount
        : fees.createAccount;

    return fee / widget.arguments.account.token.USD;
  }

  /// Bubbles up an event to send the transaction accordingly
  /// @returns {void}
  Future<bool> handleFormSubmit() async {
    switch (widget.arguments.transactionType) {
      case TransactionType.DEPOSIT:
        {
          // check getCreateAccountAuth

          final amountDeposit =
              getTokenAmountBigInt(widget.arguments.amount, 18);

          final accounts = await widget.arguments.wallet.getAccounts();

          if (accounts == null || accounts.length == 0) {
            await widget.arguments.wallet.authorizeAccountCreation();
          }

          return await widget.arguments.wallet
              .deposit(amountDeposit, widget.arguments.account.token);
        }
        break;
      case TransactionType.FORCEEXIT:
        {
          widget.arguments.wallet.forceExit(
              web3.EtherAmount.fromUnitAndValue(
                      web3.EtherUnit.wei,
                      (widget.arguments.amount *
                              BigInt.from(10).pow(18).toDouble())
                          .toInt())
                  .getInWei,
              widget.arguments.account);
        }
        break;
      case TransactionType.WITHDRAW:
        {
          widget.arguments.wallet.withdraw(
              web3.EtherAmount.fromUnitAndValue(
                      web3.EtherUnit.wei,
                      (widget.arguments.amount *
                              BigInt.from(10).pow(18).toDouble())
                          .toInt())
                  .getInWei,
              widget.arguments.account,
              /*widget.arguments.exit*/ null,
              widget.arguments.completeDelayedWithdrawal,
              widget.arguments.instantWithdrawal);
        }
        break;
      case TransactionType.EXIT:
        {
          widget.arguments.wallet.exit(
              web3.EtherAmount.fromUnitAndValue(
                      web3.EtherUnit.wei,
                      (widget.arguments.amount *
                              BigInt.from(10).pow(18).toDouble())
                          .toInt())
                  .getInWei,
              widget.arguments.account,
              BigInt.zero);
        }
        break;
      default:
        {
          final ethereumAddress =
              getEthereumAddress(widget.arguments.addressTo);
          final accounts = await widget.arguments.wallet.getAccounts(
              ethereumAddress: ethereumAddress,
              tokenIds: [widget.arguments.account.token.id]);
          final accountCreated = await widget.arguments.wallet
              .getCreateAccountAuthorization(ethereumAddress);
          var receiverAccount;
          final fees = await widget.arguments.wallet.fetchFees();
          var transactionFee;
          if (accounts != null && accounts.length > 0 && accountCreated) {
            receiverAccount = accounts[0];
            transactionFee = getFee(fees, receiverAccount != null);
          } else {
            receiverAccount =
                Account(hezEthereumAddress: widget.arguments.addressTo);
            transactionFee = getFee(fees, false);
          }

          return await widget.arguments.wallet.transfer(
              widget.arguments.amount *
                  pow(10, widget.arguments.account.token.decimals),
              widget.arguments.account,
              receiverAccount,
              transactionFee);
        }
    }
  }
}
