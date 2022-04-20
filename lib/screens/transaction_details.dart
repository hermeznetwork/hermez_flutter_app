import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hermez/context/transfer/wallet_transfer_handler.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/environment.dart';
import 'package:hermez/model/wallet.dart';
import 'package:hermez/screens/info.dart';
import 'package:hermez/screens/pin.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez/service/network/model/gas_price_response.dart';
import 'package:hermez/utils/address_utils.dart';
import 'package:hermez/utils/eth_amount_formatter.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/utils/pop_result.dart';
import 'package:hermez_sdk/addresses.dart';
import 'package:hermez_sdk/environment.dart' as HermezSDK;
import 'package:hermez_sdk/model/account.dart';
import 'package:hermez_sdk/model/exit.dart';
import 'package:hermez_sdk/model/recommended_fee.dart';
import 'package:hermez_sdk/model/token.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../context/transfer/wallet_transfer_provider.dart';
import 'fee_selector.dart';
import 'move_info.dart';

class TransactionDetailsArguments {
  final WalletHandler store;
  final TransactionType transactionType;
  final TransactionLevel transactionLevel;
  final TransactionStatus status;
  final Account account;
  final Token token;
  final Exit exit;
  final String transactionId;
  final String transactionHash;

  final double amount;
  final String addressFrom;
  final String addressTo;
  final DateTime transactionDate;

  double fee;
  final double withdrawEstimatedFee;
  WalletDefaultFee selectedFeeSpeed;
  WalletDefaultFee selectedWithdrawFeeSpeed;

  final int gasLimit;
  final int gasPrice;
  final LinkedHashMap<String, BigInt> depositGasLimit;

  final bool isTransactionBeingSigned;
  final WalletDefaultCurrency preferredCurrency;
  final List<int> fiatExchangeRates;

  final bool instantWithdrawal;
  final bool completeDelayedWithdrawal;

  TransactionDetailsArguments({
    this.store,
    this.transactionType,
    this.transactionLevel,
    this.status,
    this.account,
    this.token,
    this.exit,
    this.amount,
    this.addressFrom,
    this.addressTo,
    this.transactionDate,
    this.transactionId,
    this.transactionHash,
    this.fee,
    this.withdrawEstimatedFee,
    this.selectedFeeSpeed,
    this.selectedWithdrawFeeSpeed,
    this.gasLimit,
    this.gasPrice,
    this.depositGasLimit,
    this.isTransactionBeingSigned,
    this.preferredCurrency,
    this.fiatExchangeRates,
    this.instantWithdrawal,
    this.completeDelayedWithdrawal,
  });
}

class TransactionDetailsPage extends StatefulWidget {
  TransactionDetailsPage({Key key, this.arguments}) : super(key: key);

  final TransactionDetailsArguments arguments;

  @override
  _TransactionDetailsPageState createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  Account ethereumAccount;
  GasPriceResponse gasPriceResponse;
  WalletTransferHandler transferStore;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.arguments.fee == null &&
        widget.arguments.status == TransactionStatus.DRAFT) {
      widget.arguments.fee = widget.arguments.gasLimit.toInt() *
          widget.arguments.gasPrice.toDouble();
    }
    if (widget.arguments.selectedFeeSpeed == null) {
      widget.arguments.selectedFeeSpeed =
          widget.arguments.store.state.defaultFee;
    }
    if (widget.arguments.selectedWithdrawFeeSpeed == null) {
      widget.arguments.selectedWithdrawFeeSpeed =
          widget.arguments.store.state.defaultFee;
    }
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
                color: HermezColors.darkTwo,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: HermezColors.quaternaryThree,
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
              bool enoughFee = isFeeEnough();
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
                                      color: HermezColors.quaternaryThree,
                                      tiles: [
                                _buildExitInfoRow(context),
                                _buildStatusRow(),
                                _buildFromRow(),
                                _buildToRow(),
                                _buildFeeRow(context),
                                _buildWithdrawFeeRow(context),
                                _buildDateRow(),
                                _buildViewExplorerRow()
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
                                  onPressed: enoughFee && !isLoading
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
                                              var success =
                                                  await handleFormSubmit();

                                              if (success) {
                                                if (widget.arguments
                                                        .transactionType ==
                                                    TransactionType.EXIT) {
                                                  Navigator.of(context)
                                                      .pushNamed("/info",
                                                          arguments: InfoArguments(
                                                              "success.png",
                                                              true,
                                                              "Withdrawal has been initiated and will require additional confirmation in a few minutes.",
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
                                                } else if (widget.arguments
                                                        .transactionType ==
                                                    TransactionType.WITHDRAW) {
                                                  Navigator.of(context)
                                                      .pushNamed("/info",
                                                          arguments: InfoArguments(
                                                              "success.png",
                                                              true,
                                                              "Your withdrawal is awaiting verification.",
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
                                                } else if (widget.arguments
                                                        .transactionType ==
                                                    TransactionType.FORCEEXIT) {
                                                  Navigator.of(context)
                                                      .pushNamed("/info",
                                                          arguments: InfoArguments(
                                                              "success.png",
                                                              true,
                                                              "Withdrawal has been initiated and will require additional confirmation in a few minutes.",
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
                                                } else {
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
                                              } else {
                                                Navigator.of(context)
                                                    .pushNamed(
                                                  "/info",
                                                  arguments: InfoArguments(
                                                      "info_tx_failure.png",
                                                      true,
                                                      "There has been an error with your transaction.",
                                                      iconSize: 250),
                                                )
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
                                            } else {
                                              Navigator.popUntil(context,
                                                  ModalRoute.withName("/home"));
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
                                  disabledColor: HermezColors.quaternaryTwo,
                                  color: HermezColors.secondary,
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
                        color: HermezColors.secondary),
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
    var title = "";
    switch (widget.arguments.transactionType) {
      case TransactionType.SEND:
        title = "Send";
        break;
      case TransactionType.DEPOSIT:
        title = "Move";
        break;
      case TransactionType.WITHDRAW:
        title = "Move";
        break;
      case TransactionType.EXIT:
        title = 'Move';
        break;
      case TransactionType.FORCEEXIT:
        title = 'Move';
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
        return 'Move';
      case TransactionType.SEND:
        return 'Send';
      case TransactionType.EXIT:
        return 'Move';
      case TransactionType.WITHDRAW:
        return 'Move';
      case TransactionType.FORCEEXIT:
        return 'Move';
      default:
        return '';
    }
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
        color: HermezColors.quaternaryThree,
        padding: EdgeInsets.only(bottom: 15.0),
        child: ListTile(
          title: Column(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(top: 20.0),
                  child: Text(
                    EthAmountFormatter.formatAmount(
                        widget.arguments.amount, widget.arguments.token.symbol),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: HermezColors.darkTwo,
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
                          widget.arguments.token.USD *
                          (currency != "USD"
                              ? widget.arguments.store.state.exchangeRatio
                              : 1)),
                      currency),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: HermezColors.quaternary,
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

  Widget _buildExitInfoRow(BuildContext context) {
    if ((widget.arguments.transactionType == TransactionType.EXIT ||
            widget.arguments.transactionType == TransactionType.FORCEEXIT) &&
        widget.arguments.status == TransactionStatus.DRAFT) {
      return Card(
        margin: EdgeInsets.only(bottom: 15),
        color: HermezColors.darkTwo,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: EdgeInsets.only(top: 16, bottom: 16, right: 24, left: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 8, right: 12),
                child: SvgPicture.asset("assets/info.svg",
                    color: HermezColors.quaternaryThree,
                    alignment: Alignment.topLeft,
                    height: 20),
              ),
              Flexible(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Moving funds has 2 steps. Once initiated it can’t be canceled.',
                        style: TextStyle(
                          color: HermezColors.quaternaryThree,
                          fontFamily: 'ModernEra',
                          fontSize: 15,
                          height: 1.7,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: HermezColors.quaternary.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed("/move_info",
                              arguments: MoveInfoArguments(
                                  transactionType:
                                      widget.arguments.transactionType));
                        },
                        child: Container(
                          padding: EdgeInsets.only(right: 6, left: 6),
                          child: Text(
                            'More info',
                            style: TextStyle(
                              color: HermezColors.quaternaryThree,
                              fontSize: 15,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      );
    } else {
      return null;
    }
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
                  color: HermezColors.darkTwo,
                  fontSize: 16,
                  fontFamily: 'ModernEra',
                  fontWeight: FontWeight.w500,
                )),
            trailing: Text(statusText,
                style: TextStyle(
                  color: HermezColors.dark,
                  fontSize: 16,
                  fontFamily: 'ModernEra',
                  fontWeight: FontWeight.w700,
                )),
          );
  }

  Widget _buildFromRow() {
    return ListTile(
      contentPadding: EdgeInsets.only(top: 20, bottom: 20),
      title: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('From',
                  style: TextStyle(
                    color: HermezColors.darkTwo,
                    fontSize: 16,
                    fontFamily: 'ModernEra',
                    fontWeight: FontWeight.w500,
                  )),
              (widget.arguments.addressFrom.toLowerCase() ==
                          widget.arguments.store.state.ethereumAddress
                              .toLowerCase() ||
                      widget.arguments.addressFrom.toLowerCase() ==
                          getHermezAddress(
                                  widget.arguments.store.state.ethereumAddress)
                              .toLowerCase() ||
                      widget.arguments.addressFrom.toLowerCase() ==
                          HermezSDK.getCurrentEnvironment()
                              .contracts['Hermez']
                              .toLowerCase())
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                          widget.arguments.transactionType ==
                                      TransactionType.DEPOSIT ||
                                  (widget.arguments.transactionType ==
                                          TransactionType.SEND &&
                                      widget.arguments.store.state.txLevel ==
                                          TransactionLevel.LEVEL1)
                              ? 'My Ethereum address'
                              : 'My Hermez address',
                          style: TextStyle(
                            color: HermezColors.dark,
                            fontSize: 16,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w700,
                          )),
                    )
                  : Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        (widget.arguments.store.state.txLevel ==
                                    TransactionLevel.LEVEL1
                                ? "0x" +
                                    AddressUtils.strip0x(widget.arguments.addressFrom
                                            .substring(0, 6))
                                        .toUpperCase()
                                : isHermezEthereumAddress(
                                        widget.arguments.addressFrom)
                                    ? "hez:0x" +
                                        AddressUtils.stripHez0x(widget
                                                .arguments.addressFrom
                                                .substring(0, 10))
                                            .toUpperCase()
                                    : "hez:" +
                                        AddressUtils.stripHez0x(widget
                                                .arguments.addressFrom
                                                .substring(0, 8))
                                            .toUpperCase()) +
                            " ･･･ " +
                            widget.arguments.addressFrom
                                .substring(
                                    widget.arguments.addressFrom.length - 4,
                                    widget.arguments.addressFrom.length)
                                .toUpperCase(),
                        style: TextStyle(
                          color: HermezColors.dark,
                          fontSize: 16,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w700,
                        ),
                      ))
            ],
          ),
          SizedBox(height: 7),
          (widget.arguments.addressFrom ==
                      widget.arguments.store.state.ethereumAddress ||
                  widget.arguments.addressFrom.toLowerCase() ==
                      getHermezAddress(
                              widget.arguments.store.state.ethereumAddress)
                          .toLowerCase())
              ? Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    (widget
                                        .arguments.transactionType ==
                                    TransactionType.DEPOSIT ||
                                (widget
                                            .arguments.transactionType ==
                                        TransactionType.SEND &&
                                    widget
                                            .arguments.store.state.txLevel ==
                                        TransactionLevel.LEVEL1)
                            ? "0x"
                            : "hez:0x") +
                        AddressUtils
                                .strip0x(widget
                                    .arguments.store.state.ethereumAddress
                                    .substring(0, 6))
                            .toUpperCase() +
                        " ･･･ " +
                        widget
                            .arguments.store.state.ethereumAddress
                            .substring(
                                widget.arguments.store.state.ethereumAddress
                                        .length -
                                    4,
                                widget.arguments.store.state.ethereumAddress
                                    .length)
                            .toUpperCase(),
                    style: TextStyle(
                      color: HermezColors.quaternaryTwo,
                      fontSize: 16,
                      fontFamily: 'ModernEra',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : widget.arguments.addressFrom.toLowerCase() ==
                          widget.arguments.store.state.ethereumAddress
                              .toLowerCase() ||
                      widget.arguments.addressFrom.toLowerCase() ==
                          HermezSDK.getCurrentEnvironment()
                              .contracts['Hermez']
                              .toLowerCase()
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "0x" +
                            AddressUtils.strip0x(widget.arguments.addressFrom
                                    .substring(0, 6))
                                .toUpperCase() +
                            " ･･･ " +
                            widget.arguments.addressFrom
                                .substring(
                                    widget.arguments.addressFrom.length - 4,
                                    widget.arguments.addressFrom.length)
                                .toUpperCase(),
                        style: TextStyle(
                          color: HermezColors.quaternaryTwo,
                          fontSize: 16,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : Container(),
        ],
      ),
    );
  }

  Widget _buildToRow() {
    return ListTile(
      contentPadding: EdgeInsets.only(top: 20, bottom: 20),
      title: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('To',
                  style: TextStyle(
                    color: HermezColors.darkTwo,
                    fontSize: 16,
                    fontFamily: 'ModernEra',
                    fontWeight: FontWeight.w500,
                  )),
              (widget.arguments.addressTo.toLowerCase() ==
                          widget.arguments.store.state.ethereumAddress
                              .toLowerCase() ||
                      widget.arguments.addressTo.toLowerCase() ==
                          getHermezAddress(
                                  widget.arguments.store.state.ethereumAddress)
                              .toLowerCase() ||
                      widget.arguments.addressTo.toLowerCase() ==
                          HermezSDK.getCurrentEnvironment()
                              .contracts['Hermez']
                              .toLowerCase())
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                          widget.arguments.transactionType ==
                                      TransactionType.DEPOSIT ||
                                  (widget.arguments.transactionType ==
                                          TransactionType.RECEIVE &&
                                      widget.arguments.store.state.txLevel ==
                                          TransactionLevel.LEVEL2)
                              ? 'My Hermez address'
                              : 'My Ethereum address',
                          style: TextStyle(
                            color: HermezColors.dark,
                            fontSize: 16,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w700,
                          )),
                    )
                  : Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        (widget.arguments.store.state.txLevel ==
                                    TransactionLevel.LEVEL1
                                ? "0x" +
                                    AddressUtils.strip0x(widget.arguments.addressTo
                                            .substring(0, 6))
                                        .toUpperCase()
                                : isHermezEthereumAddress(
                                        widget.arguments.addressTo)
                                    ? "hez:0x" +
                                        AddressUtils.stripHez0x(widget
                                                .arguments.addressTo
                                                .substring(0, 10))
                                            .toUpperCase()
                                    : "hez:" +
                                        AddressUtils.stripHez0x(widget
                                                .arguments.addressTo
                                                .substring(0, 8))
                                            .toUpperCase()) +
                            " ･･･ " +
                            widget.arguments.addressTo
                                .substring(
                                    widget.arguments.addressTo.length - 4,
                                    widget.arguments.addressTo.length)
                                .toUpperCase(),
                        style: TextStyle(
                          color: HermezColors.dark,
                          fontSize: 16,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w700,
                        ),
                      ))
            ],
          ),
          SizedBox(height: 7),
          (widget.arguments.addressTo.toLowerCase() ==
                      widget.arguments.store.state.ethereumAddress
                          .toLowerCase() ||
                  widget.arguments.addressTo.toLowerCase() ==
                      getHermezAddress(
                              widget.arguments.store.state.ethereumAddress)
                          .toLowerCase() ||
                  widget.arguments.addressTo.toLowerCase() ==
                      HermezSDK.getCurrentEnvironment()
                          .contracts['Hermez']
                          .toLowerCase())
              ? Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    (widget
                                        .arguments.transactionType ==
                                    TransactionType.DEPOSIT ||
                                (widget
                                            .arguments.transactionType ==
                                        TransactionType.RECEIVE &&
                                    widget
                                            .arguments.store.state.txLevel ==
                                        TransactionLevel.LEVEL2)
                            ? "hez:0x"
                            : "0x") +
                        AddressUtils
                                .strip0x(widget
                                    .arguments.store.state.ethereumAddress
                                    .substring(0, 6))
                            .toUpperCase() +
                        " ･･･ " +
                        widget
                            .arguments.store.state.ethereumAddress
                            .substring(
                                widget.arguments.store.state.ethereumAddress
                                        .length -
                                    4,
                                widget.arguments.store.state.ethereumAddress
                                    .length)
                            .toUpperCase(),
                    style: TextStyle(
                      color: HermezColors.quaternaryTwo,
                      fontSize: 16,
                      fontFamily: 'ModernEra',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  Widget _buildFeeRow(BuildContext context) {
    if (widget.arguments.status == TransactionStatus.DRAFT ||
        (widget.arguments.status != TransactionStatus.DRAFT &&
            widget.arguments.transactionType != TransactionType.DEPOSIT &&
            widget.arguments.transactionType != TransactionType.RECEIVE &&
            widget.arguments.transactionType != TransactionType.FORCEEXIT)) {
      bool enoughFee = isFeeEnough();
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
      bool allowSelectSpeed =
          widget.arguments.transactionType == TransactionType.WITHDRAW &&
              widget.arguments.status == TransactionStatus.DRAFT;
      if (widget.arguments.status == TransactionStatus.DRAFT) {
        if (widget.arguments.transactionType == TransactionType.FORCEEXIT ||
            widget.arguments.transactionType == TransactionType.DEPOSIT ||
            widget.arguments.transactionType == TransactionType.WITHDRAW ||
            (widget.arguments.transactionType == TransactionType.SEND &&
                widget.arguments.transactionLevel == TransactionLevel.LEVEL1)) {
          title = 'Ethereum fee';
          BigInt gasPrice = BigInt.one;
          switch (widget.arguments.selectedFeeSpeed) {
            case WalletDefaultFee.SLOW:
              int gasPriceFloor = gasPriceResponse.safeLow * pow(10, 8);
              gasPrice = BigInt.from(gasPriceFloor);
              break;
            case WalletDefaultFee.AVERAGE:
              int gasPriceFloor = gasPriceResponse.average * pow(10, 8);
              gasPrice = BigInt.from(gasPriceFloor);
              break;
            case WalletDefaultFee.FAST:
              int gasPriceFloor = gasPriceResponse.fast * pow(10, 8);
              gasPrice = BigInt.from(gasPriceFloor);
              break;
          }
          double fee = widget.arguments.gasLimit * gasPrice.toDouble();
          currencyFee = EthAmountFormatter.formatAmount(
              fee.toDouble() /
                  pow(10, ethereumAccount.token.decimals) *
                  (ethereumAccount.token.USD *
                      (currency != "USD"
                          ? widget.arguments.store.state.exchangeRatio
                          : 1)),
              currency);

          tokenFee = EthAmountFormatter.formatAmount(
              fee.toDouble() / pow(10, ethereumAccount.token.decimals),
              ethereumAccount.token.symbol);
          showSpeed = true;
          speed = widget.arguments.selectedFeeSpeed
                  .toString()
                  .split(".")
                  .last
                  .substring(0, 1) +
              widget.arguments.selectedFeeSpeed
                  .toString()
                  .split(".")
                  .last
                  .substring(1)
                  .toLowerCase();
        } else {
          title = 'Hermez fee';
          //double fee =
          //    widget.arguments.gasLimit * widget.arguments.gasPrice.toDouble();
          currencyFee = EthAmountFormatter.formatAmount(
              widget.arguments.fee /
                  pow(10, widget.arguments.account.token.decimals) *
                  (widget.arguments.account.token.USD *
                      (currency != "USD"
                          ? widget.arguments.store.state.exchangeRatio
                          : 1)),
              currency);

          tokenFee = EthAmountFormatter.formatAmount(
              widget.arguments.fee /
                  pow(10, widget.arguments.account.token.decimals),
              widget.arguments.account.token.symbol);
        }
      } else {
        if (widget.arguments.transactionLevel == TransactionLevel.LEVEL2) {
          title = 'Hermez fee';
          double fee = widget.arguments.fee;
          currencyFee = EthAmountFormatter.formatAmount(
              fee.toDouble() /
                  pow(10, widget.arguments.account.token.decimals) *
                  (widget.arguments.account.token.USD *
                      (currency != "USD"
                          ? widget.arguments.store.state.exchangeRatio
                          : 1)),
              currency);

          tokenFee = EthAmountFormatter.formatAmount(
              fee.toDouble() / pow(10, widget.arguments.account.token.decimals),
              widget.arguments.account.token.symbol);
          showSpeed = false;
        } else {
          title = 'Ethereum fee';
          double fee = widget.arguments.fee;
          currencyFee = EthAmountFormatter.formatAmount(
              fee.toDouble() /
                  pow(10, ethereumAccount.token.decimals) *
                  (ethereumAccount.token.USD *
                      (currency != "USD"
                          ? widget.arguments.store.state.exchangeRatio
                          : 1)),
              currency);

          tokenFee = EthAmountFormatter.formatAmount(
              fee.toDouble() / pow(10, ethereumAccount.token.decimals),
              ethereumAccount.token.symbol);
          showSpeed = false;
        }
      }

      if (widget.arguments.transactionType == TransactionType.FORCEEXIT ||
          widget.arguments.transactionType == TransactionType.EXIT) {
        subtitle = 'Step 1';
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
                            color: HermezColors.darkTwo,
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
                            color: HermezColors.quaternaryTwo,
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
                          color: HermezColors.darkTwo,
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
                          color: HermezColors.quaternaryTwo,
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
                                    color: HermezColors.darkTwo,
                                    fontWeight: FontWeight.w700,
                                    height: 1.73,
                                    fontSize: 15),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            allowSelectSpeed
                                ? Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.only(left: 6, top: 4),
                                    child: SvgPicture.asset(
                                        'assets/arrow_right.svg',
                                        color: HermezColors.darkTwo,
                                        semanticsLabel: 'fee_selector'),
                                  )
                                : Container()
                          ],
                        )
                      : Container(),
                  !enoughFee && !isLoading
                      ? Text(
                          'Insufficient ETH to cover gas fee.',
                          style: TextStyle(
                            color: HermezColors.error,
                            height: 1.73,
                            fontSize: 15,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : Container(),
                ],
              ),
            ],
          ),
        ),
        onTap: allowSelectSpeed
            ? () async {
                GasPriceResponse gasPriceResponse =
                    await widget.arguments.store.getGasPrice();
                Navigator.of(context).pushNamed("/fee_selector",
                    arguments: FeeSelectorArguments(widget.arguments.store,
                        selectedFee: widget.arguments.selectedFeeSpeed,
                        ethereumToken: ethereumAccount.token,
                        estimatedGas: BigInt.from(widget.arguments.gasLimit),
                        gasPriceResponse: gasPriceResponse,
                        onFeeSelected: (selectedFee) {
                      setState(() {
                        widget.arguments.selectedFeeSpeed = selectedFee;
                      });
                    }));
              }
            : null,
      );
    } else {
      return null;
    }
  }

  Widget _buildWithdrawFeeRow(BuildContext context) {
    if ((widget.arguments.transactionType == TransactionType.EXIT ||
            widget.arguments.transactionType == TransactionType.FORCEEXIT) &&
        widget.arguments.transactionDate == null) {
      bool enoughFee = isFeeEnough();
      final String currency = widget.arguments.store.state.defaultCurrency
          .toString()
          .split('.')
          .last;

      String title = "Ethereum fee\n(estimated)";

      String currencyFee = EthAmountFormatter.formatAmount(
          widget.arguments.withdrawEstimatedFee.toDouble() /
              pow(10, ethereumAccount.token.decimals) *
              (ethereumAccount.token.USD *
                  (currency != "USD"
                      ? widget.arguments.store.state.exchangeRatio
                      : 1)),
          currency);

      String tokenFee = EthAmountFormatter.formatAmount(
          widget.arguments.withdrawEstimatedFee.toDouble() /
              pow(10, ethereumAccount.token.decimals),
          ethereumAccount.token.symbol);

      String speed = widget.arguments.selectedWithdrawFeeSpeed
              .toString()
              .split(".")
              .last
              .substring(0, 1) +
          widget.arguments.selectedWithdrawFeeSpeed
              .toString()
              .split(".")
              .last
              .substring(1)
              .toLowerCase();
      String subtitle = "Step 2";

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
                            color: HermezColors.darkTwo,
                            fontWeight: FontWeight.w500,
                            height: 1.6,
                            fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      child: Text(
                        subtitle,
                        style: TextStyle(
                            fontFamily: 'ModernEra',
                            color: HermezColors.quaternaryTwo,
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
                          color: HermezColors.darkTwo,
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
                          color: HermezColors.quaternaryTwo,
                          fontWeight: FontWeight.w500,
                          height: 1.53,
                          fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          speed,
                          style: TextStyle(
                              fontFamily: 'ModernEra',
                              color: HermezColors.darkTwo,
                              fontWeight: FontWeight.w700,
                              height: 1.73,
                              fontSize: 15),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  !enoughFee && !isLoading
                      ? Text(
                          'Insufficient ETH to cover gas fee.',
                          style: TextStyle(
                            color: HermezColors.error,
                            height: 1.73,
                            fontSize: 15,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w500,
                          ),
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

  Widget _buildDateRow() {
    var date = "";
    if (widget.arguments.transactionDate != null) {
      var format = DateFormat('dd/MM/yyyy, hh:mm:ss a');
      date = format.format(widget.arguments.transactionDate);
    }
    return widget.arguments.transactionDate != null &&
            widget.arguments.status != TransactionStatus.DRAFT
        ? ListTile(
            contentPadding: EdgeInsets.only(top: 20, bottom: 20),
            title: Text('Date',
                style: TextStyle(
                  color: HermezColors.darkTwo,
                  fontSize: 16,
                  fontFamily: 'ModernEra',
                  fontWeight: FontWeight.w500,
                )),
            trailing: Text(date,
                style: TextStyle(
                  color: HermezColors.dark,
                  fontSize: 16,
                  fontFamily: 'ModernEra',
                  fontWeight: FontWeight.w700,
                )),
          )
        : null;
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
                  child: CircularProgressIndicator(color: HermezColors.secondary),
                ))
              ],
            ),
          )
        : Container();
  }

  Widget _buildViewExplorerRow() {
    return widget.arguments.status != TransactionStatus.DRAFT
        ? ListTile(
            contentPadding: EdgeInsets.only(top: 20, bottom: 20),
            onTap: () async {
              var url;
              if (widget.arguments.transactionId != null) {
                url = HermezSDK.getCurrentEnvironment().batchExplorerUrl +
                    '/transaction/' +
                    widget.arguments.transactionId;
              } else {
                url = getCurrentEnvironment().etherscanUrl +
                    "/tx/" +
                    widget.arguments.transactionHash;
              }
              if (await canLaunch(url))
                await launch(url);
              else
                // can't launch url, there is some error
                throw "Could not launch $url";
            },
            title: Container(
              alignment: Alignment.center,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    height: 20,
                    child: Image.asset("assets/show_explorer.png"),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    'View in explorer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: HermezColors.quaternaryTwo,
                      fontSize: 16,
                      fontFamily: 'ModernEra',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
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
    if (widget.arguments.token.USD == 0) {
      return 0;
    }

    final fee = (isExistingAccount ||
            widget.arguments.transactionType == TransactionType.EXIT)
        ? fees.existingAccount
        : fees.createAccount;

    return double.parse((fee / widget.arguments.token.USD).toStringAsFixed(6));
  }

  /// Bubbles up an event to send the transaction accordingly
  /// @returns {void}
  Future<bool> handleFormSubmit() async {
    if (widget.arguments.store.state.txLevel == TransactionLevel.LEVEL1 &&
        widget.arguments.transactionType == TransactionType.SEND) {
      return await transferStore.transfer(
          widget.arguments.store.state.ethereumPrivateKey,
          widget.arguments.addressTo,
          widget.arguments.amount.toString(),
          widget.arguments.token,
          gasLimit: widget.arguments.gasLimit,
          gasPrice: widget.arguments.gasPrice);
    } else {
      switch (widget.arguments.transactionType) {
        case TransactionType.DEPOSIT:
          {
            // check getCreateAccountAuth
            final double amountDeposit = widget.arguments.amount *
                pow(10, widget.arguments.token.decimals);

            final accounts = await widget.arguments.store.getL2Accounts();

            if (accounts == null || accounts.length == 0) {
              await widget.arguments.store.authorizeAccountCreation();
            }

            return await widget.arguments.store.deposit(
                amountDeposit, widget.arguments.token,
                approveGasLimit:
                    widget.arguments.depositGasLimit['approveGasLimit'],
                depositGasLimit:
                    widget.arguments.depositGasLimit['depositGasLimit'],
                gasPrice: widget.arguments.gasPrice);
          }
          break;
        case TransactionType.FORCEEXIT:
          {
            final double amountExit = widget.arguments.amount *
                pow(10, widget.arguments.token.decimals);

            return await widget.arguments.store.forceExit(
                amountExit, widget.arguments.account,
                gasLimit: BigInt.from(widget.arguments.gasLimit),
                gasPrice: widget.arguments.gasPrice);
          }
          break;
        case TransactionType.WITHDRAW:
          {
            final amountWithdraw = widget.arguments.amount *
                pow(10, widget.arguments.token.decimals);

            return await widget.arguments.store.withdraw(
                amountWithdraw,
                widget.arguments.account,
                widget.arguments.exit,
                widget.arguments.completeDelayedWithdrawal,
                widget.arguments.instantWithdrawal,
                gasLimit: BigInt.from(widget.arguments.gasLimit),
                gasPrice: widget.arguments.gasPrice);
          }
          break;
        case TransactionType.EXIT:
          {
            final fees = await widget.arguments.store.fetchFees();
            final transactionFee = getFee(fees, true);

            final double amountExit = widget.arguments.amount *
                pow(10, widget.arguments.token.decimals);

            return await widget.arguments.store
                .exit(amountExit, widget.arguments.account, transactionFee);
          }
          break;
        default:
          {
            final accounts = await widget.arguments.store.getL2Accounts(
                hezAddress: widget.arguments.addressTo,
                tokenIds: [widget.arguments.token.id]);
            bool accountCreated = true;
            if (isHermezEthereumAddress(widget.arguments.addressTo)) {
              final ethereumAddress =
                  getEthereumAddress(widget.arguments.addressTo);
              accountCreated = await widget.arguments.store
                  .getCreateAccountAuthorization(ethereumAddress);
            }
            var receiverAccount;
            final fees = await widget.arguments.store.fetchFees();
            var transactionFee;
            if (accounts != null && accounts.length > 0 && accountCreated) {
              receiverAccount = accounts[0];
              transactionFee = getFee(fees, receiverAccount != null);
            } else {
              receiverAccount =
                  Account(hezEthereumAddress: widget.arguments.addressTo);
              transactionFee = getFee(fees, false);
            }

            final double amountTransfer = widget.arguments.amount *
                pow(10, widget.arguments.token.decimals);

            return await widget.arguments.store.transfer(amountTransfer,
                widget.arguments.account, receiverAccount, transactionFee);
          }
      }
    }
  }

  bool isFeeEnough() {
    if (widget.arguments.transactionType == TransactionType.SEND &&
        widget.arguments.transactionLevel == TransactionLevel.LEVEL2) {
      return true;
    }
    if (widget.arguments.status == TransactionStatus.DRAFT) {
      BigInt gasPrice = BigInt.one;
      switch (widget.arguments.selectedFeeSpeed) {
        case WalletDefaultFee.SLOW:
          int gasPriceFloor = gasPriceResponse.safeLow * pow(10, 8);
          gasPrice = BigInt.from(gasPriceFloor);
          break;
        case WalletDefaultFee.AVERAGE:
          int gasPriceFloor = gasPriceResponse.average * pow(10, 8);
          gasPrice = BigInt.from(gasPriceFloor);
          break;
        case WalletDefaultFee.FAST:
          int gasPriceFloor = gasPriceResponse.fast * pow(10, 8);
          gasPrice = BigInt.from(gasPriceFloor);
          break;
      }
      double fee = widget.arguments.gasLimit * gasPrice.toDouble();
      if (widget.arguments.transactionType == TransactionType.EXIT) {
        fee = widget.arguments.withdrawEstimatedFee;
      } else if (widget.arguments.transactionType ==
          TransactionType.FORCEEXIT) {
        fee = widget.arguments.fee + widget.arguments.withdrawEstimatedFee;
      }
      if (fee != null && ethereumAccount != null) {
        return BigInt.parse(ethereumAccount.balance) > BigInt.from(fee);
      } else {
        return true;
      }
    } else {
      return true;
    }
  }

  Future<bool> fetchData() async {
    //if (needRefresh == true) {
    if (widget.arguments.status == TransactionStatus.DRAFT) {
      ethereumAccount = await getEthereumAccount();
      gasPriceResponse = await getGasPriceResponse();
    } else if (widget.arguments.transactionLevel == TransactionLevel.LEVEL1 &&
        widget.arguments.transactionType != TransactionType.RECEIVE) {
      ethereumAccount = await getEthereumAccount();
    }

    //needRefresh = false;
    //}
    return true;
  }

  Future<Account> getEthereumAccount() async {
    Account ethereumAccount = await widget.arguments.store.getL1Account(0);
    return ethereumAccount;
  }

  // TODO: call it here
  Future<GasPriceResponse> getGasPriceResponse() async {
    GasPriceResponse gasPriceResponse =
        await widget.arguments.store.getGasPrice();
    return gasPriceResponse;
  }
}
