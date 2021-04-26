import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hermez/components/form/address_input.dart';
import 'package:hermez/components/form/amount_input.dart';
import 'package:hermez/components/form/paper_form.dart';
import 'package:hermez/components/wallet/account_row.dart';
import 'package:hermez/components/wallet/move_row.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/screens/scanner.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez/utils/address_utils.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_plugin/addresses.dart';
import 'package:hermez_plugin/model/account.dart';
import 'package:hermez_plugin/model/recommended_fee.dart';
import 'package:hermez_plugin/model/state_response.dart';
import 'package:hermez_plugin/model/token.dart';

import '../../screens/account_selector.dart';

class TransferAmountForm extends StatefulWidget {
  TransferAmountForm(
      {Key key,
      @required this.txLevel,
      @required this.transactionType,
      this.account,
      this.token,
      this.amount,
      this.addressTo,
      @required this.store,
      @required this.onSubmit})
      : super(key: key);

  final TransactionLevel txLevel;
  final TransactionType transactionType;
  final Account account;
  final Token token;
  final double amount;
  final String addressTo;
  final WalletHandler store;
  final void Function(double amount, String token, String addressTo) onSubmit;

  @override
  _TransferAmountFormState createState() => _TransferAmountFormState(txLevel,
      transactionType, account, token, amount, addressTo, store, onSubmit);
}

class _TransferAmountFormState extends State<TransferAmountForm> {
  _TransferAmountFormState(this.txLevel, this.transactionType, this.account,
      this.token, this.amount, this.addressTo, this.store, this.onSubmit);

  final TransactionLevel txLevel;
  final TransactionType transactionType;
  final Account account;
  final Token token;
  final double amount;
  final String addressTo;
  final WalletHandler store;
  final void Function(double amount, String token, String addressTo) onSubmit;
  bool amountIsValid = true;
  bool addressIsValid = true;
  bool defaultCurrencySelected;
  Token ethereumToken;
  Account ethereumAccount;
  bool enoughGas;
  BigInt estimatedFee;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    defaultCurrencySelected = false;
  }

  @override
  void dispose() {
    amountController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: getEstimatedFee(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            BigInt estimatedFee = snapshot.data;
            /*EtherAmount fee =
                EtherAmount.fromUnitAndValue(EtherUnit.wei, estimatedFee);*/
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
                                                        (currency != "USD"
                                                            ? account
                                                                    .token.USD *
                                                                widget
                                                                    .store
                                                                    .state
                                                                    .exchangeRatio
                                                            : account
                                                                .token.USD))
                                                    .toStringAsFixed(6)),
                                            amountController.value.text,
                                            addressController.value.text);
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
                                child: Text("Continue",
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
                        transactionType != TransactionType.RECEIVE
                            ? Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(top: 20.0),
                                child: Text(
                                  defaultCurrencySelected
                                      ? "Fee " +
                                          ((currency != "USD"
                                                      ? ethereumToken.USD *
                                                          widget.store.state
                                                              .exchangeRatio
                                                      : ethereumToken.USD) *
                                                  (estimatedFee.toDouble() /
                                                      pow(
                                                          10,
                                                          ethereumToken
                                                              .decimals)))
                                              .toStringAsFixed(2) +
                                          " " +
                                          currency
                                      : "Fee " +
                                          (estimatedFee.toDouble() /
                                                  pow(10,
                                                      ethereumToken.decimals))
                                              .toStringAsFixed(6) +
                                          " ETH",
                                  style: TextStyle(
                                    color: HermezColors.blueyGreyTwo,
                                    fontSize: 16,
                                    fontFamily: 'ModernEra',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
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
                            /*() async {
                              setState(() {
                                txLevel = txLevel == TransactionLevel.LEVEL1
                                    ? TransactionLevel.LEVEL2
                                    : TransactionLevel.LEVEL1;
                              });
                            }*/
                            null,
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
                                      widget.store));
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
                                        txLevel, transactionType, store));
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
                    layerOne: store.state.txLevel == TransactionLevel.LEVEL1,
                    onChanged: (value) {
                      setState(() {
                        addressIsValid = isAddressValid();
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
                                        type: store.state.txLevel ==
                                                TransactionLevel.LEVEL1
                                            ? QRCodeScannerType.ETHEREUM_ADDRESS
                                            : QRCodeScannerType.HERMEZ_ADDRESS,
                                        onScanned: (scannedAddress) async {
                                          setState(() {
                                            addressController.clear();
                                            addressController.text =
                                                scannedAddress.toString();
                                            addressIsValid = isAddressValid();
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
                          amountIsValid = value.isEmpty ||
                              (account != null
                                  ? (double.parse(value) <=
                                      (defaultCurrencySelected
                                          ? currency != "USD"
                                              ? account.token.USD *
                                                      double.parse(
                                                          account.balance) /
                                                      pow(
                                                          10,
                                                          account
                                                              .token.decimals) *
                                                      widget.store.state
                                                          .exchangeRatio -
                                                  (account.token.USD *
                                                          widget.store.state
                                                              .exchangeRatio) *
                                                      (estimatedFee.toDouble() /
                                                          pow(
                                                              10,
                                                              account.token
                                                                  .decimals))
                                              : account.token.USD * double.parse(account.balance) / pow(10, account.token.decimals) -
                                                  (account.token.USD *
                                                      estimatedFee.toDouble() /
                                                      pow(
                                                          10,
                                                          account
                                                              .token.decimals))
                                          : double.parse(account.balance) /
                                                  pow(10, account.token.decimals) -
                                              (estimatedFee.toDouble() / pow(10, account.token.decimals))))
                                  : true);
                        },
                      );
                    },
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
                                        if (currency != 'USD') {
                                          if (account.token.id == 0) {
                                            amount = account.token.USD *
                                                    double.parse(
                                                        account.balance) /
                                                    pow(
                                                        10,
                                                        account
                                                            .token.decimals) *
                                                    widget.store.state
                                                        .exchangeRatio -
                                                (account.token.USD *
                                                    widget.store.state
                                                        .exchangeRatio *
                                                    estimatedFee.toDouble() /
                                                    pow(
                                                        10,
                                                        account
                                                            .token.decimals));
                                          } else {
                                            amount = account.token.USD *
                                                double.parse(account.balance) /
                                                pow(10,
                                                    account.token.decimals) *
                                                widget
                                                    .store.state.exchangeRatio;
                                          }
                                        } else {
                                          if (account.token.id == 0) {
                                            amount = account.token.USD *
                                                    (double.parse(
                                                            account.balance) /
                                                        pow(
                                                            10,
                                                            account.token
                                                                .decimals)) -
                                                (account.token.USD *
                                                    (estimatedFee.toDouble() /
                                                        pow(
                                                            10,
                                                            account.token
                                                                .decimals)));
                                          } else {
                                            amount = account.token.USD *
                                                (double.parse(account.balance) /
                                                    pow(
                                                        10,
                                                        account
                                                            .token.decimals));
                                          }
                                        }
                                      } else {
                                        if (account.token.id == 0) {
                                          amount = ((double.parse(
                                                      account.balance) /
                                                  pow(10,
                                                      account.token.decimals)) -
                                              (estimatedFee.toDouble() /
                                                  pow(10,
                                                      account.token.decimals)));
                                        } else {
                                          amount = (double.parse(
                                                  account.balance) /
                                              pow(10, account.token.decimals));
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
                          : 'You don’t have enough funds to pay gas',
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

  Future<BigInt> getEstimatedFee() async {
    if (store.state.txLevel == TransactionLevel.LEVEL2) {
      StateResponse state = await store.getState();
      RecommendedFee fees = state.recommendedFee;
      return BigInt.from(fees.createAccount);
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
      //if (account.balance. > 0) {
      if (AddressUtils.isValidEthereumAddress(store.state.ethereumAddress)) {
        addressFrom = store.state.ethereumAddress;
      }
      if (AddressUtils.isValidEthereumAddress(addressController.value.text)) {
        addressTo = addressController.value.text;
      }
      BigInt fee = await store.getEstimatedFee(
          addressFrom, addressTo, BigInt.from(amount));
      estimatedFee = fee;
      ethereumToken = await getEthereumToken();
      ethereumAccount = await getEthereumAccount();
      enoughGas = await isEnoughGas();

      return fee;
      /*} else {
        return BigInt.zero;
        // TODO handle showing error
      }*/
    }
  }

  bool buttonIsEnabled() {
    if (txLevel == TransactionLevel.LEVEL1) {
      if (transactionType == TransactionType.SEND) {
        return amountIsValid &&
            enoughGas &&
            amountController.value.text.isNotEmpty &&
            addressIsValid &&
            addressController.value.text.isNotEmpty;
      } else {
        return amountIsValid &&
            enoughGas &&
            amountController.value.text.isNotEmpty;
      }
    } else {
      if (transactionType == TransactionType.SEND) {
        return amountIsValid &&
            amountController.value.text.isNotEmpty &&
            addressIsValid &&
            addressController.value.text.isNotEmpty;
      } else {
        return amountIsValid && amountController.value.text.isNotEmpty;
      }
    }
  }

  bool isAddressValid() {
    return addressController.value.text.isEmpty ||
        (store.state.txLevel == TransactionLevel.LEVEL1 &&
            AddressUtils.isValidEthereumAddress(
                addressController.value.text)) ||
        (store.state.txLevel == TransactionLevel.LEVEL2 &&
            isHermezEthereumAddress(addressController.value.text));
    /*final regex = RegExp(store.state.txLevel == TransactionLevel.LEVEL1
        ? '^(0?[xX]?)[a-fA-F0-9]{0,}\$' /*'^0x[a-fA-F0-9]{40}\$'*/
        : '^([hH]?[eE]?[zZ]?:?0?[xX]?)[a-fA-F0-9]{0,}\$' /*'^hez:0x[a-fA-F0-9]{40}\$'*/);
    try {
      final matches = regex.allMatches(addressController.value.text);
      for (Match match in matches) {
        if (match.start == 0 &&
            match.end == addressController.value.text.length) {
          return true;
        }
      }
      return false;
    } catch (e) {
      // Invalid regex
      assert(false, e.toString());
      return true;
    }*/
  }

  Future<bool> isEnoughGas() async {
    if (txLevel == TransactionLevel.LEVEL1) {
      if (ethereumAccount != null) {
        return double.parse(ethereumAccount.balance) >= estimatedFee.toDouble();
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
    List<Account> accounts = await widget.store.getL1Accounts();
    Account ethereumAccount;
    for (Account account in accounts) {
      if (account.token.id == 0) {
        ethereumAccount = account;
        break;
      }
    }
    return ethereumAccount;
  }

  String removeDecimalZeroFormat(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1);
  }
}
