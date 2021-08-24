import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hermez/context/transfer/wallet_transfer_handler.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/model/wallet.dart';
import 'package:hermez/screens/info.dart';
import 'package:hermez/screens/pin.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez/service/network/model/bitrefill_item.dart';
import 'package:hermez/utils/eth_amount_formatter.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/utils/pop_result.dart';
import 'package:hermez_sdk/model/account.dart';
import 'package:hermez_sdk/model/recommended_fee.dart';

import '../context/transfer/wallet_transfer_provider.dart';
import 'bitrefill_items.dart';

class BitrefillSummaryArguments {
  final WalletHandler store;
  final TransactionStatus status;
  final Account account;
  final double amount;
  final String email;
  final List<BitrefillItem> items;
  final WalletDefaultCurrency preferredCurrency;

  BitrefillSummaryArguments({
    this.store,
    this.status,
    this.account,
    this.amount,
    this.email,
    this.items,
    this.preferredCurrency,
  });
}

class BitrefillSummaryPage extends StatefulWidget {
  BitrefillSummaryPage({Key key, this.arguments}) : super(key: key);

  final BitrefillSummaryArguments arguments;

  @override
  _BitrefillSummaryPageState createState() => _BitrefillSummaryPageState();
}

class _BitrefillSummaryPageState extends State<BitrefillSummaryPage> {
  WalletTransferHandler transferStore;
  RecommendedFee fees;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    transferStore = useWalletTransfer(context);
    return Scaffold(
      backgroundColor: Colors.white,
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
              onPressed: () {
                if (widget.arguments.status == TransactionStatus.DRAFT) {
                  Navigator.popUntil(context, ModalRoute.withName("/home"));
                } else {
                  Navigator.of(context).pop(false);
                }
              }),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  _buildAmountRow(),
                  Expanded(
                      child: Container(
                          padding: EdgeInsets.all(16),
                          child: SingleChildScrollView(
                              child: Column(
                                  children: ListTile.divideTiles(
                                      context: context,
                                      color: HermezColors.blueyGreyThree,
                                      tiles: [
                                _buildStatusRow(),
                                _buildEmailRow(),
                                _buildItemsRow(),
                                _buildFeeRow(context),
                              ]).toList())))),
                  _buildLoadingRow(),
                  widget.arguments.status == TransactionStatus.DRAFT
                      ? Column(children: <Widget>[
                          Container(
                            margin: const EdgeInsets.all(16),
                            child: Align(
                              alignment: FractionalOffset.bottomCenter,
                              child: SizedBox(
                                width: double.infinity,
                                child: FlatButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                  onPressed: !isLoading
                                      ? () async {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          var pinSuccess =
                                              await Navigator.of(context)
                                                  .pushNamed(
                                                      "/pin",
                                                      arguments: PinArguments(
                                                          "Enter passcode",
                                                          false,
                                                          false));
                                          if (pinSuccess != null) {
                                            if (pinSuccess == true) {
                                              var success = true;
                                              //await handleFormSubmit();

                                              if (success) {
                                                Navigator.of(context)
                                                    .pushNamed("/info",
                                                        arguments: InfoArguments(
                                                            "success.png",
                                                            true,
                                                            "Your transaction is awaiting verification.",
                                                            iconSize: 300))
                                                    .then((value) {
                                                  Navigator.of(context).pop(
                                                    PopWithResults(
                                                      fromPage:
                                                          "/transaction_details",
                                                      toPage: "/home",
                                                      results: {
                                                        "pop_result": true
                                                      },
                                                    ),
                                                  );
                                                });
                                              }
                                            }
                                          } else {
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }
                                        }
                                      : null,
                                  padding: EdgeInsets.only(
                                      top: 18.0,
                                      bottom: 18.0,
                                      right: 24.0,
                                      left: 24.0),
                                  disabledColor: HermezColors.blueyGreyTwo,
                                  color: HermezColors.darkOrange,
                                  textColor: Colors.white,
                                  disabledTextColor: Colors.grey,
                                  child: Text(
                                    getButtonLabel(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ])
                      : Container()
                ],
              );
            } else {
              // We can show the loading view until the data comes back.
              //debugPrint('Step 1, build loading widget');
              return Column(children: [
                _buildAmountRow(),
                Expanded(
                  child: Center(
                    child: new CircularProgressIndicator(
                        color: HermezColors.orange),
                  ),
                )
              ]);
            }
          },
        ),
      ),
    );
  }

  /// Converts the transaction type to a readable title label
  ///
  /// @returns {string} - Button label
  String getTitleLabel() {
    var title = "Bitrefill";
    return title;
  }

  /// Converts the transaction type to a readable button label
  ///
  /// @returns {string} - Button label
  String getButtonLabel() {
    return 'Send';
  }

  Widget _buildAmountRow() {
    final String currency =
        widget.arguments.store.state.defaultCurrency.toString().split('.').last;

    String symbol = "";
    if (currency == "EUR") {
      symbol = "€";
    } else if (currency == "CNY") {
      symbol = "\¥";
    } else if (currency == "JPY") {
      symbol = "\¥";
    } else if (currency == "GBP") {
      symbol = "\£";
    } else {
      symbol = "\$";
    }

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
                    EthAmountFormatter.formatAmount(widget.arguments.amount,
                        widget.arguments.account.token.symbol),
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
                  EthAmountFormatter.formatAmount(
                      (widget.arguments.amount *
                          widget.arguments.account.token.USD *
                          (currency != "USD"
                              ? widget.arguments.store.state.exchangeRatio
                              : 1)),
                      currency),
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

  Widget _buildStatusRow() {
    var statusText = "";
    switch (widget.arguments.status) {
      case TransactionStatus.DRAFT:
        statusText = "Draft";
        break;
      case TransactionStatus.CONFIRMED:
        statusText = "Confirmed";
        break;
      case TransactionStatus.PENDING:
        statusText = "Pending";
        break;
      case TransactionStatus.INVALID:
        statusText = "Invalid";
        break;
    }

    return widget.arguments.status == TransactionStatus.DRAFT
        ? null
        : ListTile(
            contentPadding: EdgeInsets.only(top: 20, bottom: 20),
            title: Text('Status',
                style: TextStyle(
                  color: HermezColors.blackTwo,
                  fontSize: 16,
                  fontFamily: 'ModernEra',
                  fontWeight: FontWeight.w500,
                )),
            trailing: Text(statusText,
                style: TextStyle(
                  color: HermezColors.black,
                  fontSize: 16,
                  fontFamily: 'ModernEra',
                  fontWeight: FontWeight.w700,
                )),
          );
  }

  Widget _buildEmailRow() {
    return ListTile(
      contentPadding: EdgeInsets.only(top: 20, bottom: 20),
      title: Text('Email',
          style: TextStyle(
            color: HermezColors.blackTwo,
            fontSize: 16,
            fontFamily: 'ModernEra',
            fontWeight: FontWeight.w500,
          )),
      trailing: Text(widget.arguments.email,
          style: TextStyle(
            color: HermezColors.black,
            fontSize: 16,
            fontFamily: 'ModernEra',
            fontWeight: FontWeight.w700,
          )),
    );
  }

  Widget _buildItemsRow() {
    var statusText = widget.arguments.items.length.toString() +
        (widget.arguments.items.length != 1 ? " Items" : " Item");

    return ListTile(
        contentPadding: EdgeInsets.only(top: 20, bottom: 20),
        title: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Text(
                        'Items',
                        style: TextStyle(
                            fontFamily: 'ModernEra',
                            color: HermezColors.blackTwo,
                            fontWeight: FontWeight.w500,
                            height: 1.71,
                            fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          statusText,
                          style: TextStyle(
                              fontFamily: 'ModernEra',
                              color: HermezColors.blackTwo,
                              fontWeight: FontWeight.w700,
                              height: 1.73,
                              fontSize: 15),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(left: 6, top: 6),
                        child: SvgPicture.asset('assets/arrow_right.svg',
                            color: HermezColors.blackTwo,
                            semanticsLabel: 'fee_selector'),
                      )
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
        onTap: () async {
          Navigator.of(context).pushNamed("/bitrefill_items",
              arguments: BitrefillItemsArguments(widget.arguments.items));
        });

    return ListTile(
      contentPadding: EdgeInsets.only(top: 20, bottom: 20),
      title: Text('Items',
          style: TextStyle(
            color: HermezColors.blackTwo,
            fontSize: 16,
            fontFamily: 'ModernEra',
            fontWeight: FontWeight.w500,
          )),
      trailing: Text(statusText,
          style: TextStyle(
            color: HermezColors.black,
            fontSize: 16,
            fontFamily: 'ModernEra',
            fontWeight: FontWeight.w700,
          )),
    );
  }

  Widget _buildFeeRow(BuildContext context) {
    if (widget.arguments.status == TransactionStatus.DRAFT) {
      var transactionFee;
      transactionFee = getFee(fees, true);
      final String currency = widget.arguments.store.state.defaultCurrency
          .toString()
          .split('.')
          .last;
      String title = "";
      String subtitle = "";
      String currencyFee = "";
      String tokenFee = "";
      String speed = "Average";
      bool showSpeed = false;
      if (widget.arguments.status == TransactionStatus.DRAFT) {
        title = 'Hermez fee';
        //double fee =
        //    widget.arguments.gasLimit * widget.arguments.gasPrice.toDouble();
        currencyFee = EthAmountFormatter.formatAmount(
            transactionFee *
                (currency != "USD"
                    ? widget.arguments.store.state.exchangeRatio
                    : 1),
            currency);

        tokenFee = EthAmountFormatter.formatAmount(
            transactionFee / widget.arguments.account.token.USD,
            widget.arguments.account.token.symbol);
      }

      return ListTile(
        contentPadding: EdgeInsets.only(top: 20, bottom: 20),
        title: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Text(
                        title,
                        style: TextStyle(
                            fontFamily: 'ModernEra',
                            color: HermezColors.blackTwo,
                            fontWeight: FontWeight.w500,
                            height: 1.71,
                            fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      child: Text(
                        subtitle,
                        style: TextStyle(
                            fontFamily: 'ModernEra',
                            color: HermezColors.blueyGreyTwo,
                            fontWeight: FontWeight.w500,
                            height: 1.53,
                            fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    child: Text(
                      currencyFee,
                      style: TextStyle(
                          fontFamily: 'ModernEra',
                          color: HermezColors.blackTwo,
                          fontWeight: FontWeight.w700,
                          height: 1.71,
                          fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Container(
                    child: Text(
                      tokenFee,
                      style: TextStyle(
                          fontFamily: 'ModernEra',
                          color: HermezColors.blueyGreyTwo,
                          fontWeight: FontWeight.w500,
                          height: 1.53,
                          fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  showSpeed
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              child: Text(
                                speed,
                                style: TextStyle(
                                    fontFamily: 'ModernEra',
                                    color: HermezColors.blackTwo,
                                    fontWeight: FontWeight.w700,
                                    height: 1.73,
                                    fontSize: 15),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Container()
                          ],
                        )
                      : Container(),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return null;
    }
  }

  Widget _buildLoadingRow() {
    return widget.arguments.status == TransactionStatus.DRAFT && isLoading
        ? Container(
            padding: EdgeInsets.only(top: 80, bottom: 80),
            alignment: Alignment.center,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                    child: Center(
                  child: CircularProgressIndicator(color: HermezColors.orange),
                ))
              ],
            ),
          )
        : Container();
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

    final fee = isExistingAccount ? fees.existingAccount : fees.createAccount;

    return double.parse(fee.toStringAsFixed(6));
  }

  Future<bool> fetchData() async {
    //if (needRefresh == true) {
    /*if (widget.arguments.status == TransactionStatus.DRAFT) {
      ethereumAccount = await getEthereumAccount();
      gasPriceResponse = await getGasPriceResponse();
    } else if (widget.arguments.transactionLevel == TransactionLevel.LEVEL1 &&
        widget.arguments.transactionType != TransactionType.RECEIVE) {
      ethereumAccount = await getEthereumAccount();
    }*/

    //needRefresh = false;
    //}
    fees = await widget.arguments.store.fetchFees();
    return true;
  }
}
