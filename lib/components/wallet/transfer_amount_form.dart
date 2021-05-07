import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hermez/components/form/address_input.dart';
import 'package:hermez/components/form/amount_input.dart';
import 'package:hermez/components/form/paper_form.dart';
import 'package:hermez/components/wallet/account_row.dart';
import 'package:hermez/components/wallet/move_row.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/model/wallet.dart';
import 'package:hermez/screens/fee_selector.dart';
import 'package:hermez/screens/scanner.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez/service/network/model/gas_price_response.dart';
import 'package:hermez/utils/address_utils.dart';
import 'package:hermez/utils/eth_amount_formatter.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_plugin/addresses.dart';
import 'package:hermez_plugin/constants.dart';
import 'package:hermez_plugin/environment.dart';
import 'package:hermez_plugin/model/account.dart';
import 'package:hermez_plugin/model/recommended_fee.dart';
import 'package:hermez_plugin/model/state_response.dart';
import 'package:hermez_plugin/model/token.dart';
import 'package:hermez_plugin/utils.dart';

import '../../screens/account_selector.dart';

class TransferAmountForm extends StatefulWidget {
  TransferAmountForm(
      {Key key,
      @required this.txLevel,
      @required this.transactionType,
      this.allowChangeLevel = false,
      this.account,
      this.token,
      this.amount,
      this.addressTo,
      @required this.store,
      @required this.onSubmit})
      : super(key: key);

  final TransactionLevel txLevel;
  final TransactionType transactionType;
  final bool allowChangeLevel;
  final Account account;
  final Token token;
  final double amount;
  final String addressTo;
  final WalletHandler store;
  final void Function(
      double amount,
      Token token,
      double fee,
      Token feeToken,
      String addressTo,
      int gasLimit,
      int gasPrice,
      LinkedHashMap<String, List<BigInt>> depositGasLimit) onSubmit;

  @override
  _TransferAmountFormState createState() => _TransferAmountFormState(
      txLevel,
      transactionType,
      allowChangeLevel,
      account,
      token,
      amount,
      addressTo,
      store,
      onSubmit);
}

class _TransferAmountFormState extends State<TransferAmountForm> {
  _TransferAmountFormState(
      this.txLevel,
      this.transactionType,
      this.allowChangeLevel,
      this.account,
      this.token,
      this.amount,
      this.addressTo,
      this.store,
      this.onSubmit);

  TransactionLevel txLevel;
  final TransactionType transactionType;
  Account account;
  bool allowChangeLevel;
  final Token token;
  final double amount;
  final String addressTo;
  final WalletHandler store;
  final void Function(
      double amount,
      Token token,
      double fee,
      Token feeToken,
      String addressTo,
      int gasLimit,
      int gasPrice,
      LinkedHashMap<String, List<BigInt>> depositGasLimit) onSubmit;
  bool needRefresh = true;
  bool amountIsValid = true;
  bool addressIsValid = true;
  bool defaultCurrencySelected;
  Token ethereumToken;
  Account ethereumAccount;
  bool enoughGas;
  LinkedHashMap<String, List<BigInt>> depositGasLimit;
  BigInt gasLimit;
  WalletDefaultFee selectedFeeSpeed;
  GasPriceResponse gasPriceResponse;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    defaultCurrencySelected = false;
    enoughGas = true;
    if (widget.amount != null && widget.amount > 0) {
      amountController.text =
          EthAmountFormatter.removeDecimalZeroFormat(widget.amount);
    }
    if (widget.addressTo != null && widget.addressTo.isNotEmpty) {
      addressController.value = TextEditingValue(text: widget.addressTo);
    }
    needRefresh = true;
    selectedFeeSpeed = widget.store.state.defaultFee;
  }

  @override
  void dispose() {
    amountController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            String feeText = getFeeText();
            BigInt estimatedFee = getEstimatedFee(); //snapshot.data;
            final String currency =
                widget.store.state.defaultCurrency.toString().split('.').last;

            return Container(
              padding: EdgeInsets.all(10),
              color: Colors.white,
              child: SingleChildScrollView(
                child: PaperForm(
                  actionButtons: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          child: Align(
                            alignment: FractionalOffset.bottomCenter,
                            child: SizedBox(
                              width: double.infinity,
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                onPressed: buttonIsEnabled()
                                    ? () {
                                        this.onSubmit(
                                            !defaultCurrencySelected
                                                ? double.parse(
                                                    amountController.value.text)
                                                : double.parse((double.parse(
                                                            amountController
                                                                .value.text) /
                                                        (account != null
                                                            ? account.token.USD
                                                            : token.USD) *
                                                        (currency != "USD"
                                                            ? widget.store.state
                                                                .exchangeRatio
                                                            : 1))
                                                    .toStringAsFixed(6)),
                                            account != null
                                                ? account.token
                                                : token,
                                            estimatedFee.toDouble(),
                                            txLevel == TransactionLevel.LEVEL1
                                                ? ethereumToken
                                                : account != null
                                                    ? account.token
                                                    : token,
                                            addressController.value.text,
                                            gasLimit.toInt(),
                                            getGasPrice().toInt(),
                                            depositGasLimit);
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
                                    transactionType != TransactionType.RECEIVE
                                        ? "Continue"
                                        : "Request",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w700,
                                    )),
                              ),
                            ),
                          ),
                        ),
                        account != null
                            ? Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(top: 24.0),
                                child: TextButton(
                                  onPressed: ((txLevel ==
                                                      TransactionLevel.LEVEL2 &&
                                                  transactionType ==
                                                      TransactionType.SEND) ||
                                              transactionType ==
                                                  TransactionType.EXIT) ||
                                          snapshot.connectionState !=
                                              ConnectionState.done
                                      ? null
                                      : () {
                                          Navigator.of(context).pushNamed(
                                              "/fee_selector",
                                              arguments: FeeSelectorArguments(
                                                  widget.store,
                                                  selectedFee: selectedFeeSpeed,
                                                  ethereumToken: ethereumToken,
                                                  estimatedGas: gasLimit,
                                                  gasPriceResponse:
                                                      gasPriceResponse,
                                                  onFeeSelected: (selectedFee) {
                                                setState(() {
                                                  amountController.clear();
                                                  selectedFeeSpeed =
                                                      selectedFee;
                                                });
                                              }));
                                        },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        feeText,
                                        style: TextStyle(
                                          color: ((txLevel ==
                                                              TransactionLevel
                                                                  .LEVEL2 &&
                                                          transactionType ==
                                                              TransactionType
                                                                  .SEND) ||
                                                      transactionType ==
                                                          TransactionType
                                                              .EXIT) ||
                                                  snapshot.connectionState !=
                                                      ConnectionState.done
                                              ? HermezColors.blueyGreyTwo
                                              : HermezColors.blackTwo,
                                          fontSize: 16,
                                          fontFamily: 'ModernEra',
                                          fontWeight: ((txLevel ==
                                                              TransactionLevel
                                                                  .LEVEL2 &&
                                                          transactionType ==
                                                              TransactionType
                                                                  .SEND) ||
                                                      transactionType ==
                                                          TransactionType
                                                              .EXIT) ||
                                                  snapshot.connectionState !=
                                                      ConnectionState.done
                                              ? FontWeight.w500
                                              : FontWeight.w700,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      (txLevel == TransactionLevel.LEVEL2 &&
                                                  transactionType ==
                                                      TransactionType.SEND) ||
                                              transactionType ==
                                                  TransactionType.EXIT
                                          ? Container()
                                          : snapshot.connectionState ==
                                                  ConnectionState.done
                                              ? Container(
                                                  alignment: Alignment.center,
                                                  margin: EdgeInsets.only(
                                                      left: 6, bottom: 2),
                                                  child: SvgPicture.asset(
                                                      'assets/fee_arrow.svg',
                                                      color:
                                                          HermezColors.blackTwo,
                                                      semanticsLabel:
                                                          'fee_selector'),
                                                )
                                              : Container(
                                                  alignment: Alignment.center,
                                                  margin: EdgeInsets.only(
                                                      left: 6, bottom: 1),
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        new AlwaysStoppedAnimation<
                                                                Color>(
                                                            HermezColors
                                                                .blueyGrey),
                                                    strokeWidth: 2,
                                                  ),
                                                  width: 10,
                                                  height: 10),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ],
                  children: <Widget>[
                    transactionType != TransactionType.SEND &&
                            transactionType != TransactionType.RECEIVE
                        ? MoveRow(
                            txLevel,
                            allowChangeLevel
                                ? () async {
                                    setState(() {
                                      txLevel =
                                          (txLevel == TransactionLevel.LEVEL1)
                                              ? TransactionLevel.LEVEL2
                                              : TransactionLevel.LEVEL1;
                                      defaultCurrencySelected = true;
                                      account = null;
                                      amountController.clear();
                                    });
                                  }
                                : null,
                          )
                        : Container(),
                    account != null || token != null
                        ? AccountRow(
                            account != null ? account.token.name : token.name,
                            account != null
                                ? account.token.symbol
                                : token.symbol,
                            currency != "USD"
                                ? (account != null
                                        ? account.token.USD
                                        : token.USD) *
                                    widget.store.state.exchangeRatio
                                : account != null
                                    ? account.token.USD
                                    : token.USD,
                            currency,
                            account != null
                                ? double.parse(account.balance) /
                                    pow(10, account.token.decimals)
                                : 0,
                            true,
                            defaultCurrencySelected,
                            false,
                            token != null,
                            (token, amount) async {
                              Navigator.of(context).pushReplacementNamed(
                                  "/account_selector",
                                  arguments: AccountSelectorArguments(
                                      widget.txLevel,
                                      transactionType,
                                      widget.store,
                                      allowChangeLevel:
                                          widget.allowChangeLevel));
                            },
                          )
                        : Container(
                            padding: EdgeInsets.only(bottom: 15.0),
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  side: BorderSide(
                                      color: HermezColors.lightGrey)),
                              onPressed: () {
                                Navigator.of(context).pushReplacementNamed(
                                    "/account_selector",
                                    arguments: AccountSelectorArguments(
                                        txLevel, transactionType, store,
                                        allowChangeLevel:
                                            widget.allowChangeLevel));
                              },
                              padding: EdgeInsets.all(20.0),
                              color: HermezColors.lightGrey,
                              textColor: HermezColors.blackTwo,
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Select token',
                                            style: TextStyle(
                                              color: HermezColors.blackTwo,
                                              fontSize: 16,
                                              fontFamily: 'ModernEra',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ), //title to be name of the crypto
                            )),
                    _buildAmountRow(
                        context, null, amountController, estimatedFee),
                    transactionType == TransactionType.SEND
                        ? addressRow()
                        : Container()
                  ],
                ),
              ),
            );
          } else {
            // We can show the loading view until the data comes back.
            //debugPrint('Step 1, build loading widget');
            return new Center(
              child: new CircularProgressIndicator(),
            );
          }
        },
      );

  Widget addressRow() {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: addressIsValid
                  ? HermezColors.blueyGreyThree
                  : HermezColors.redError,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding:
              EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
          child: Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: AddressInput(
                    controller: addressController,
                    layerOne: txLevel == TransactionLevel.LEVEL1,
                    onChanged: (value) {
                      setState(() {
                        addressIsValid = isAddressValid();
                        if (addressIsValid) {
                          amountController.clear();
                          needRefresh = true;
                        }
                      });
                    },
                  ),
                ),
                addressController.value.text.isEmpty
                    ? Row(
                        children: <Widget>[
                          Container(
                            child: FlatButton(
                              child: Text(
                                'Paste',
                                style: TextStyle(
                                  color: HermezColors.blackTwo,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              onPressed: () {
                                getClipBoardData().then((String result) {
                                  setState(() {
                                    addressController.clear();
                                    addressController.text = result;
                                    addressIsValid = isAddressValid();
                                    if (addressIsValid) {
                                      amountController.clear();
                                      needRefresh = true;
                                    }
                                  });
                                });
                              },
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed("/scanner",
                                    arguments: QRCodeScannerArguments(
                                        store: store,
                                        type: txLevel == TransactionLevel.LEVEL1
                                            ? QRCodeScannerType.ETHEREUM_ADDRESS
                                            : QRCodeScannerType.HERMEZ_ADDRESS,
                                        onScanned: (scannedAddress) async {
                                          setState(() {
                                            addressController.clear();
                                            addressController.text =
                                                scannedAddress.toString();
                                            addressIsValid = isAddressValid();
                                            if (addressIsValid) {
                                              amountController.clear();
                                              needRefresh = true;
                                            }
                                          });
                                        }));
                              }, // handle your image tap here
                              child: Image.asset(
                                "assets/scan.png",
                                color: HermezColors.blackTwo,
                              ),
                            ),
                          ),
                        ],
                      )
                    : IconButton(
                        icon: new Icon(Icons.close),
                        onPressed: () => setState(() {
                          addressController.clear();
                          addressIsValid = isAddressValid();
                          if (addressIsValid) {
                            amountController.clear();
                            needRefresh = true;
                          }
                        }),
                      ),
              ],
            ),
          ),
        ),
        addressIsValid
            ? SizedBox(
                height: 40,
              )
            : Container(
                padding: EdgeInsets.only(top: 10, bottom: 15),
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 8.0, right: 8.0),
                      height: 16,
                      width: 16,
                      decoration: BoxDecoration(
                        color: HermezColors.redError,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          '!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'Please enter a valid address.',
                      style: TextStyle(
                        color: HermezColors.redError,
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildAmountRow(BuildContext context, dynamic element,
      dynamic amountController, BigInt estimatedFee) {
    final String currency =
        widget.store.state.defaultCurrency.toString().split('.').last;
    // returns a row with the desired properties
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: amountIsValid && enoughGas
                  ? HermezColors.blueyGreyThree
                  : HermezColors.redError,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.only(top: 20.0),
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  child: Text(
                    defaultCurrencySelected || account == null && token == null
                        ? currency
                        : account != null
                            ? account.token.symbol
                            : token.symbol,
                    style: TextStyle(
                      color: HermezColors.black,
                      fontSize: 16,
                      fontFamily: 'ModernEra',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                  child: AmountInput(
                    onChanged: (value) {
                      setState(
                        () {
                          amountIsValid = isAmountValid(value);
                        },
                      );
                    },
                    enabled: account != null ||
                        transactionType == TransactionType.RECEIVE,
                    controller: amountController,
                    decimals: defaultCurrencySelected ? 2 : 6,
                  ),
                ),
                SizedBox(
                  height: account != null || token != null ? 16.0 : 25,
                ),
                account != null || token != null
                    ? Divider(
                        color: HermezColors.blueyGreyThree,
                        height: 2,
                        thickness: 2,
                      )
                    : Container(),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      account != null ||
                              token != null &&
                                  transactionType != TransactionType.RECEIVE
                          ? Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  border: Border(
                                      top: BorderSide.none,
                                      right: BorderSide(
                                          color: HermezColors.blueyGreyThree,
                                          width: 1),
                                      bottom: BorderSide.none,
                                      left: BorderSide.none),
                                ),
                                child: FlatButton(
                                  child: Text(
                                    "Send All",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: HermezColors.blueyGreyTwo,
                                      fontSize: 16,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      amountController.clear();
                                      amountIsValid = false;
                                      double amount = 0;
                                      if (defaultCurrencySelected) {
                                        if (account.token.id == 0 ||
                                            txLevel ==
                                                TransactionLevel.LEVEL2) {
                                          double balance = double.parse(
                                              (double.parse(account.balance) /
                                                      pow(
                                                          10,
                                                          account
                                                              .token.decimals))
                                                  .toStringAsFixed(6));
                                          amount = account.token.USD *
                                                  balance *
                                                  (currency != 'USD'
                                                      ? widget.store.state
                                                          .exchangeRatio
                                                      : 1) -
                                              (account.token.USD *
                                                  (currency != 'USD'
                                                      ? widget.store.state
                                                          .exchangeRatio
                                                      : 1) *
                                                  estimatedFee.toDouble() /
                                                  pow(10,
                                                      account.token.decimals));
                                        } else {
                                          double balance = double.parse(
                                              (double.parse(account.balance) /
                                                      pow(
                                                          10,
                                                          account
                                                              .token.decimals))
                                                  .toStringAsFixed(6));
                                          amount = account.token.USD *
                                              balance *
                                              (currency != 'USD'
                                                  ? widget
                                                      .store.state.exchangeRatio
                                                  : 1);
                                        }
                                      } else {
                                        if (account.token.id == 0 ||
                                            txLevel ==
                                                TransactionLevel.LEVEL2) {
                                          double balance = double.parse(
                                              (double.parse(account.balance) /
                                                      pow(
                                                          10,
                                                          account
                                                              .token.decimals))
                                                  .toStringAsFixed(6));
                                          amount = balance -
                                              (estimatedFee.toDouble() /
                                                  pow(10,
                                                      account.token.decimals));
                                        } else {
                                          amount = double.parse(
                                              (double.parse(account.balance) /
                                                      pow(
                                                          10,
                                                          account
                                                              .token.decimals))
                                                  .toStringAsFixed(6));
                                        }
                                      }
                                      amountIsValid = amount > 0;
                                      if (amountIsValid) {
                                        amountController.text =
                                            amount.toStringAsFixed(
                                                defaultCurrencySelected
                                                    ? amount.truncateToDouble() ==
                                                            amount
                                                        ? 0
                                                        : 2
                                                    : amount.truncateToDouble() ==
                                                            amount
                                                        ? 0
                                                        : 6);
                                        amountController.selection =
                                            TextSelection.fromPosition(
                                                TextPosition(
                                                    offset: amountController
                                                        .text.length));
                                      }
                                    });
                                  },
                                ),
                              ),
                            )
                          : Container(),
                      account != null || token != null
                          ? Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  border: Border(
                                      top: BorderSide.none,
                                      right: BorderSide.none,
                                      bottom: BorderSide.none,
                                      left: BorderSide(
                                          color: HermezColors.blueyGreyThree,
                                          width: 1)),
                                ),
                                child: FlatButton.icon(
                                  onPressed: () {
                                    if (account != null || token != null) {
                                      setState(() {
                                        amountController.clear();
                                        defaultCurrencySelected =
                                            !defaultCurrencySelected;
                                      });
                                    }
                                  },
                                  icon: Image.asset(
                                    "assets/arrows_up_down.png",
                                    color: HermezColors.blueyGreyTwo,
                                  ),
                                  label: Text(
                                    defaultCurrencySelected
                                        ? account != null
                                            ? account.token.symbol
                                            : token.symbol
                                        : currency,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: HermezColors.blueyGreyTwo,
                                      fontSize: 16,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ],
            ), //title to be name of the crypto
          ),
        ),
        amountIsValid && enoughGas
            ? SizedBox(
                height: 40,
              )
            : Container(
                padding: EdgeInsets.only(top: 10, bottom: 15),
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 8.0, right: 8.0),
                      height: 16,
                      width: 16,
                      decoration: BoxDecoration(
                        color: HermezColors.redError,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          '!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      enoughGas
                          ? 'You don’t have enough funds.'
                          : 'Insufficient ETH to cover gas fee.',
                      style: TextStyle(
                        color: HermezColors.redError,
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  Future<String> getClipBoardData() async {
    ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
    return data.text;
  }

  Future<bool> fetchData() async {
    if (needRefresh == true) {
      BigInt gasPrice = BigInt.zero;
      if (transactionType == TransactionType.RECEIVE) {
        gasLimit = BigInt.zero;
      } else if ((txLevel == TransactionLevel.LEVEL2 &&
              transactionType == TransactionType.SEND) ||
          transactionType == TransactionType.EXIT) {
        double amount = 0;
        if (account != null) {
          if (amountController.value.text.isNotEmpty) {
            amount = !defaultCurrencySelected
                ? double.parse(amountController.value.text)
                : double.parse(amountController.value.text) /
                    /*(currency == "EUR"
                ? account.USD * widget.store.state.exchangeRatio*
                :*/
                    account.token.USD /*)*/;
          }

          StateResponse state = await store.getState();
          RecommendedFee fees = state.recommendedFee;
          gasLimit = BigInt.from(fees.existingAccount /
              account.token.USD *
              pow(10, account.token.decimals));
          if (transactionType == TransactionType.EXIT) {
            BigInt ethGasLimit = BigInt.from(
                GAS_LIMIT_WITHDRAW_DEFAULT + (GAS_LIMIT_WITHDRAW_SIBLING * 4));
            if (account.token.id != 0) {
              ethGasLimit += BigInt.from(GAS_STANDARD_ERC20_TX);
            }
            ethereumToken = await getEthereumToken();
            ethereumAccount = await getEthereumAccount();
            enoughGas = await isEnoughGas(ethGasLimit + gasPrice);

            ethereumAccount = await getEthereumAccount();
          } else {}
        } else {
          gasLimit = BigInt.zero;
        }

        enoughGas = await isEnoughGas(gasLimit);
        amountIsValid =
            isAmountValid(EthAmountFormatter.removeDecimalZeroFormat(amount));
      } else {
        double amount = 0;
        if (amountController.value.text.isNotEmpty) {
          amount = !defaultCurrencySelected
              ? double.parse(amountController.value.text)
              : double.parse(amountController.value.text) /
                  /*(currency == "EUR"
                ? account.USD * widget.store.state.exchangeRatio*
                :*/
                  account.token.USD /*)*/;
        }
        String addressFrom;
        String addressTo;
        Uint8List data;
        if (AddressUtils.isValidEthereumAddress(store.state.ethereumAddress)) {
          addressFrom = store.state.ethereumAddress;
        }
        gasPriceResponse = await store.getGasPrice();
        switch (selectedFeeSpeed) {
          case WalletDefaultFee.SLOW:
            double gasPriceFloor = double.parse(
                (gasPriceResponse.safeLow / pow(10, 10)).toStringAsFixed(6));
            gasPrice = BigInt.from(gasPriceFloor * pow(10, 18));
            break;
          case WalletDefaultFee.AVERAGE:
            double gasPriceFloor = double.parse(
                (gasPriceResponse.average / pow(10, 10)).toStringAsFixed(6));
            gasPrice = BigInt.from(gasPriceFloor * pow(10, 18));
            break;
          case WalletDefaultFee.FAST:
            double gasPriceFloor = double.parse(
                (gasPriceResponse.fast / pow(10, 10)).toStringAsFixed(6));
            gasPrice = BigInt.from(gasPriceFloor * pow(10, 18));
            break;
        }
        if (transactionType == TransactionType.DEPOSIT) {
          addressTo = getCurrentEnvironment().contracts['Hermez'];
          BigInt amountToEstimate = BigInt.one;
          depositGasLimit =
              await store.depositGasLimit(amountToEstimate, account.token);
          gasLimit = BigInt.zero;
          depositGasLimit.forEach((String key, List<BigInt> value) {
            value.forEach((gas) {
              gasLimit += gas;
            });
          });
        } else if (transactionType == TransactionType.WITHDRAW) {
          try {
            addressTo = getCurrentEnvironment().contracts['Hermez'];
            BigInt amountToEstimate = BigInt.one;
            BigInt ethAmountToEstimate = BigInt.one;
            int offset = GAS_LIMIT_OFFSET;
            if (account.token.id != 0) {
              offset = GAS_STANDARD_ERC20_TX;
              ethAmountToEstimate = BigInt.zero;
            }
            /*data = await store.signWithdraw(
              amountToEstimate, account, exit, false, true);*/
            /*gasLimit = await store.getGasLimit(
              addressFrom, addressTo, ethAmountToEstimate,
              data: data);*/
            gasLimit = BigInt.from(GAS_LIMIT_HIGH);
            gasLimit += BigInt.from(offset);
          } catch (e) {
            print(e.toString());
            gasLimit = BigInt.from(GAS_LIMIT_HIGH);
          }
        } else if (AddressUtils.isValidEthereumAddress(
            addressController.value.text)) {
          addressTo = addressController.value.text;
          try {
            BigInt maxGas = await store.getGasLimit(addressFrom, addressTo,
                getTokenAmountBigInt(amount, account.token.decimals),
                data: data);
            gasLimit = maxGas;
          } catch (e) {
            print(e.toString());
            gasLimit = BigInt.zero;
          }
        } else {
          try {
            BigInt maxGas = await store.getGasLimit(addressFrom, addressTo,
                getTokenAmountBigInt(amount, account.token.decimals),
                data: data);
            gasLimit = maxGas;
          } catch (e) {
            print(e.toString());
            gasLimit = BigInt.zero;
          }
        }

        ethereumToken = await getEthereumToken();
        ethereumAccount = await getEthereumAccount();
        enoughGas = await isEnoughGas(gasLimit * gasPrice);
        amountIsValid =
            isAmountValid(EthAmountFormatter.removeDecimalZeroFormat(amount));
      }
      needRefresh = false;
    }
    return true;
  }

  bool buttonIsEnabled() {
    if (transactionType == TransactionType.RECEIVE) {
      return amountIsValid &&
          amountController.value.text.isNotEmpty &&
          double.parse(amountController.value.text) > 0 &&
          token != null;
    } else if (txLevel == TransactionLevel.LEVEL1) {
      if (transactionType == TransactionType.SEND) {
        return amountIsValid &&
            enoughGas &&
            amountController.value.text.isNotEmpty &&
            double.parse(amountController.value.text) > 0 &&
            addressIsValid &&
            addressController.value.text.isNotEmpty &&
            needRefresh == false;
      } else {
        return amountIsValid &&
            enoughGas &&
            amountController.value.text.isNotEmpty &&
            double.parse(amountController.value.text) > 0;
      }
    } else {
      if (transactionType == TransactionType.SEND) {
        return amountIsValid &&
            amountController.value.text.isNotEmpty &&
            double.parse(amountController.value.text) > 0 &&
            addressIsValid &&
            addressController.value.text.isNotEmpty;
      } else {
        return amountIsValid &&
            amountController.value.text.isNotEmpty &&
            double.parse(amountController.value.text) > 0;
      }
    }
  }

  bool isAddressValid() {
    return addressController.value.text.isEmpty ||
        (txLevel == TransactionLevel.LEVEL1 &&
            AddressUtils.isValidEthereumAddress(
                addressController.value.text)) ||
        (txLevel == TransactionLevel.LEVEL2 &&
            isHermezEthereumAddress(addressController.value.text));
  }

  bool isAmountValid(String value) {
    BigInt estimatedFee = getEstimatedFee();
    final String currency =
        widget.store.state.defaultCurrency.toString().split('.').last;
    double balance = 1;
    if (account != null) {
      balance = double.parse(
          (double.parse(account.balance) / pow(10, account.token.decimals))
              .toStringAsFixed(6));
    }
    return value.isEmpty ||
        (account != null
            ? (double.parse(value) <=
                (defaultCurrencySelected
                    ? currency != "USD"
                        ? account.token.USD *
                                balance *
                                widget.store.state.exchangeRatio -
                            (account.token.USD *
                                    widget.store.state.exchangeRatio) *
                                (estimatedFee.toDouble() /
                                    pow(10, account.token.decimals))
                        : account.token.USD * balance -
                            (account.token.USD *
                                estimatedFee.toDouble() /
                                pow(10, account.token.decimals))
                    : balance -
                        (estimatedFee.toDouble() /
                            pow(10, account.token.decimals))))
            : true);
  }

  Future<bool> isEnoughGas(BigInt gasFee) async {
    if ((txLevel == TransactionLevel.LEVEL1 &&
            transactionType !=
                TransactionType
                    .RECEIVE) /*||
        transactionType == TransactionType.EXIT*/
        ) {
      if (ethereumAccount != null) {
        return double.parse(ethereumAccount.balance) >= gasFee.toDouble();
      }
      return false;
    } else {
      return true;
    }
  }

  Future<Token> getEthereumToken() async {
    return await widget.store.getTokenById(0);
  }

  Future<Account> getEthereumAccount() async {
    List<Account> accounts = await widget.store.getL1Accounts(true);
    Account ethereumAccount;
    for (Account account in accounts) {
      if (account.token.id == 0) {
        ethereumAccount = account;
        break;
      }
    }
    return ethereumAccount;
  }

  BigInt getEstimatedFee() {
    BigInt gasPrice = getGasPrice();
    return gasLimit * gasPrice;
  }

  BigInt getGasPrice() {
    BigInt gasPrice = BigInt.one;
    if (gasPriceResponse != null && selectedFeeSpeed != null) {
      switch (selectedFeeSpeed) {
        case WalletDefaultFee.SLOW:
          gasPrice = BigInt.from(gasPriceResponse.safeLow * pow(10, 8));
          break;
        case WalletDefaultFee.AVERAGE:
          gasPrice = BigInt.from(gasPriceResponse.average * pow(10, 8));
          break;
        case WalletDefaultFee.FAST:
          gasPrice = BigInt.from(gasPriceResponse.fast * pow(10, 8));
          break;
      }
    }
    return gasPrice;
  }

  String getFeeText() {
    if (transactionType == TransactionType.RECEIVE) {
      return "";
    } else {
      BigInt estimatedFee = getEstimatedFee();

      final String currency =
          widget.store.state.defaultCurrency.toString().split('.').last;

      return defaultCurrencySelected
          ? "Fee " +
              (((txLevel == TransactionLevel.LEVEL2 &&
                                  transactionType == TransactionType.SEND) ||
                              transactionType == TransactionType.EXIT
                          ? account.token.USD
                          : ethereumToken.USD) *
                      (currency != "USD"
                          ? widget.store.state.exchangeRatio
                          : 1) *
                      (estimatedFee.toDouble() /
                          pow(
                              10,
                              ((txLevel == TransactionLevel.LEVEL2 &&
                                          transactionType ==
                                              TransactionType.SEND) ||
                                      transactionType == TransactionType.EXIT
                                  ? account.token.decimals
                                  : ethereumToken.decimals))))
                  .toStringAsFixed(2) +
              " " +
              currency
          : "Fee " +
              (estimatedFee.toDouble() /
                      pow(
                          10,
                          (txLevel == TransactionLevel.LEVEL1
                              ? ethereumToken.decimals
                              : account != null
                                  ? account.token.decimals
                                  : 18)))
                  .toStringAsFixed(6) +
              " " +
              (txLevel == TransactionLevel.LEVEL1
                  ? ethereumToken.symbol
                  : account.token.symbol);
    }
  }
}
