import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hermez/components/form/address_input.dart';
import 'package:hermez/components/form/amount_input.dart';
import 'package:hermez/components/form/paper_form.dart';
import 'package:hermez/components/wallet/account_row.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/utils/address_utils.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';
import 'package:hermez_plugin/addresses.dart';
import 'package:hermez_plugin/model/account.dart';
import 'package:web3dart/web3dart.dart';

import '../../wallet_account_selector_page.dart';

class TransferAmountForm extends StatefulWidget {
  TransferAmountForm(
      {Key key,
      this.account,
      this.amount,
      this.store,
      this.amountType,
      @required this.onSubmit})
      : super(key: key);

  final Account account;
  final double amount;
  final WalletHandler store;
  final TransactionType amountType;
  final void Function(double amount, String token, String addressTo) onSubmit;

  @override
  _TransferAmountFormState createState() =>
      _TransferAmountFormState(account, amount, store, amountType, onSubmit);
}

class _TransferAmountFormState extends State<TransferAmountForm> {
  _TransferAmountFormState(
      this.account, this.amount, this.store, this.amountType, this.onSubmit);

  final Account account;
  final double amount;
  final WalletHandler store;
  final TransactionType amountType;
  final void Function(double amount, String token, String addressTo) onSubmit;
  bool amountIsValid = true;
  bool addressIsValid = true;
  bool defaultCurrencySelected = false;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

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
            EtherAmount fee =
                EtherAmount.fromUnitAndValue(EtherUnit.wei, estimatedFee);
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
                        SizedBox(
                          height: 52,
                          width: double.infinity,
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                                side: BorderSide(
                                    color: buttonIsEnabled()
                                        ? HermezColors.darkOrange
                                        : HermezColors.blueyGreyTwo)),
                            onPressed: buttonIsEnabled()
                                ? () {
                                    this.onSubmit(
                                        !defaultCurrencySelected
                                            ? double.parse(
                                                amountController.value.text)
                                            : double.parse(amountController
                                                    .value.text) /
                                                (currency == "EUR"
                                                    ? account.token.USD *
                                                        widget.store.state
                                                            .exchangeRatio
                                                    : account.token.USD),
                                        amountController.value.text,
                                        addressController.value.text);
                                  }
                                : null,
                            disabledColor: HermezColors.blueyGreyTwo,
                            padding: EdgeInsets.all(18.0),
                            color: HermezColors.darkOrange,
                            textColor: Colors.white,
                            child: Text(
                                amountType == TransactionType.DEPOSIT
                                    ? "Continue"
                                    : "Next",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w700,
                                )),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: 20.0),
                          child: Text(
                            defaultCurrencySelected
                                ? "Fee " +
                                    ((currency == "EUR"
                                                ? account.token.USD *
                                                    widget.store.state
                                                        .exchangeRatio
                                                : account.token.USD) *
                                            (estimatedFee.toDouble() /
                                                pow(10, 18)))
                                        .toString() +
                                    " " +
                                    currency
                                : "Fee " +
                                    (estimatedFee.toDouble() / pow(10, 18))
                                        .toString() +
                                    " ETH",
                            style: TextStyle(
                              color: HermezColors.blueyGreyTwo,
                              fontSize: 16,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                  children: <Widget>[
                    AccountRow(
                      account.token.name,
                      account.token.symbol,
                      currency == "EUR"
                          ? account.token.USD * widget.store.state.exchangeRatio
                          : account.token.USD,
                      currency,
                      double.parse(account.balance) / pow(10, 18),
                      true,
                      defaultCurrencySelected,
                      false,
                      (token, amount) async {
                        Navigator.of(context)
                            .pushReplacementNamed("/account_selector",
                                arguments: AccountSelectorArguments(
                                    /*txLevel,*/ amountType,
                                    widget.store));
                      },
                    ),
                    _buildAmountRow(
                        context, null, amountController, estimatedFee),
                    amountType == TransactionType.SEND
                        ? addressRow()
                        : Container()
                  ],
                ),
              ),
            );
          } else {
            // We can show the loading view until the data comes back.
            debugPrint('Step 1, build loading widget');
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
                                Navigator.of(context).pushNamed(
                                  "/qrcode_reader",
                                  arguments: (scannedAddress) async {
                                    setState(() {
                                      addressController.clear();
                                      addressController.text =
                                          scannedAddress.toString();
                                      addressIsValid = isAddressValid();
                                    });
                                  },
                                );
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
              color: amountIsValid
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
                    defaultCurrencySelected ? currency : account.token.symbol,
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
                      setState(() {
                        amountIsValid = value.isEmpty ||
                            double.parse(value) <=
                                (defaultCurrencySelected
                                    ? currency == "EUR"
                                        ? account.token.USD *
                                                double.parse(account.balance) /
                                                pow(10, 18) *
                                                widget
                                                    .store.state.exchangeRatio -
                                            (account.token.USD *
                                                    widget.store.state
                                                        .exchangeRatio) *
                                                (estimatedFee.toDouble() /
                                                    pow(10, 18))
                                        : account.token.USD *
                                                double.parse(account.balance) /
                                                pow(10, 18) -
                                            (account.token.USD *
                                                estimatedFee.toDouble() /
                                                pow(10, 18))
                                    : double.parse(account.balance) /
                                            pow(10, 18) -
                                        (estimatedFee.toDouble() /
                                            pow(10, 18)));
                      });
                    },
                    controller: amountController,
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Divider(
                  color: HermezColors.blueyGreyThree,
                  height: 2,
                  thickness: 2,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
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
                                amountIsValid = (defaultCurrencySelected
                                                ? currency == "EUR"
                                                    ? account.token.USD *
                                                            double.parse(account
                                                                .balance) /
                                                            pow(10, 18) *
                                                            widget.store.state
                                                                .exchangeRatio -
                                                        (account.token.USD *
                                                            widget.store.state
                                                                .exchangeRatio *
                                                            estimatedFee
                                                                .toDouble() /
                                                            pow(10, 18))
                                                    : account.token.USD *
                                                            double.parse(account
                                                                .balance) /
                                                            pow(10, 18) -
                                                        (account.token.USD *
                                                            estimatedFee
                                                                .toDouble() /
                                                            pow(10, 18))
                                                : double.parse(
                                                    account.balance)) /
                                            pow(10, 18) -
                                        (estimatedFee.toDouble() /
                                            pow(10, 18)) >
                                    0;
                                if (amountIsValid) {
                                  amountController.text =
                                      defaultCurrencySelected
                                          ? currency == "EUR"
                                              ? (account.token.USD *
                                                          double.parse(
                                                              account.balance) /
                                                          pow(10, 18) *
                                                          widget.store.state
                                                              .exchangeRatio -
                                                      (account.token.USD *
                                                          widget.store.state
                                                              .exchangeRatio *
                                                          estimatedFee
                                                              .toDouble() /
                                                          pow(10, 18)))
                                                  .toStringAsFixed(2)
                                              : (account.token.USD *
                                                          double.parse(
                                                              account.balance) /
                                                          pow(10, 18) -
                                                      (account.token.USD *
                                                          estimatedFee
                                                              .toDouble() /
                                                          pow(10, 18)))
                                                  .toStringAsFixed(2)
                                          : (double.parse(account.balance) /
                                                      pow(10, 18) -
                                                  (estimatedFee.toDouble() /
                                                      pow(10, 18)))
                                              .toString();
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
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
                              setState(() {
                                amountController.clear();
                                defaultCurrencySelected =
                                    !defaultCurrencySelected;
                              });
                            },
                            icon: Image.asset(
                              "assets/arrows_up_down.png",
                              color: HermezColors.blueyGreyTwo,
                            ),
                            label: Text(
                              defaultCurrencySelected
                                  ? account.token.symbol
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
                      ),
                    ],
                  ),
                ),
              ],
            ), //title to be name of the crypto
          ),
        ),
        amountIsValid
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
                      'You don’t have enough funds.',
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
    if (store.state.ethBalance.toDouble() > 0) {
      if (AddressUtils.isValidEthereumAddress(store.state.ethereumAddress)) {
        addressFrom = store.state.ethereumAddress;
      }
      if (AddressUtils.isValidEthereumAddress(addressController.value.text)) {
        addressTo = addressController.value.text;
      }
      BigInt estimatedFee = await store.getEstimatedFee(
          addressFrom, addressTo, BigInt.from(amount));
      return estimatedFee;
    } else {
      return BigInt.zero;
      // TODO handle showing error
    }
  }

  bool buttonIsEnabled() {
    if (amountType == TransactionType.SEND) {
      return amountIsValid &&
          amountController.value.text.isNotEmpty &&
          addressIsValid &&
          addressController.value.text.isNotEmpty;
    } else {
      return amountIsValid && amountController.value.text.isNotEmpty;
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
}
