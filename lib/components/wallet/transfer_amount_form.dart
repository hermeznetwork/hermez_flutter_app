import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hermez/components/form/address_input.dart';
import 'package:hermez/components/form/amount_input.dart';
import 'package:hermez/components/form/paper_form.dart';
import 'package:hermez/components/wallet/account_row.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/service/network/model/L1_account.dart';
import 'package:hermez/utils/address_utils.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';

import '../../wallet_token_selector_page.dart';

class TransferAmountForm extends StatefulWidget {
  TransferAmountForm(
      {Key key,
      this.account,
      this.amount,
      this.store,
      this.amountType,
      @required this.onSubmit})
      : super(key: key);

  final L1Account account;
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

  final L1Account account;
  final double amount;
  final WalletHandler store;
  final TransactionType amountType;
  final void Function(double amount, String token, String addressTo) onSubmit;
  bool amountIsValid = true;
  bool addressIsValid = true;
  bool defaultCurrencySelected = true;

  final amountController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final toController = useTextEditingController(text: token);

    //final transferStore = useWalletTransfer(context);

    /*useEffect(() {
      if (token != null) toController.value = TextEditingValue(text: token);
      return null;
    }, [token]);*/

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
                                    ? double.parse(amountController.value.text)
                                    : double.parse(
                                            amountController.value.text) /
                                        (currency == "EUR"
                                            ? account.USD *
                                                widget.store.state.exchangeRatio
                                            : account.USD),
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
                        ? "Fee 0.1 " + currency
                        : "Fee 0.1 " + account.tokenSymbol,
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
              account.publicKey,
              account.tokenSymbol,
              currency == "EUR"
                  ? account.USD * widget.store.state.exchangeRatio
                  : account.USD,
              currency,
              double.parse(account.balance),
              true,
              defaultCurrencySelected,
              (token, amount) async {
                Navigator.of(context).pushReplacementNamed("/token_selector",
                    arguments: TokenSelectorArguments(
                        /*txLevel,*/ amountType,
                        widget.store));
              },
            ),
            _buildAmountRow(context, null, amountController),
            amountType == TransactionType.SEND ? addressRow() : Container()
          ],
        ),
      ),
    );
  }

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
                            child: Image.asset(
                              "assets/scan.png",
                              color: HermezColors.blackTwo,
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

  Widget _buildAmountRow(
      BuildContext context, dynamic element, dynamic amountController) {
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
                    defaultCurrencySelected ? currency : account.tokenSymbol,
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
                        amountIsValid = double.parse(value) <=
                            (defaultCurrencySelected
                                ? currency == "EUR"
                                    ? account.USD *
                                        double.parse(account.balance) *
                                        widget.store.state.exchangeRatio
                                    : account.USD *
                                        double.parse(account.balance)
                                /*.replaceAll(RegExp('[^0-9.,]'), '')*/
                                : double.parse(account.balance));
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
                                amountController.text = defaultCurrencySelected
                                    ? currency == "EUR"
                                        ? (account.USD *
                                                double.parse(account.balance) *
                                                widget
                                                    .store.state.exchangeRatio)
                                            .toStringAsFixed(2)
                                        : (account.USD *
                                                double.parse(account.balance))
                                            .toStringAsFixed(2)
                                    //.replaceAll(RegExp('[^0-9.,]'), '')
                                    : double.parse(account.balance)
                                        .toStringAsFixed(2);
                                amountIsValid = (defaultCurrencySelected
                                        ? currency == "EUR"
                                            ? account.USD *
                                                double.parse(account.balance) *
                                                widget.store.state.exchangeRatio
                                            : account.USD *
                                                double.parse(account.balance)
                                        /*.replaceAll(RegExp('[^0-9.,]'), '')*/
                                        : double.parse(account.balance)) !=
                                    0;
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
                                  ? account.tokenSymbol
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

  bool buttonIsEnabled() {
    return amountIsValid &&
        addressIsValid &&
        amountController.value.text.isNotEmpty &&
        addressController.value.text.isNotEmpty;
  }

  bool isAddressValid() {
    return addressController.value.text.isEmpty ||
        AddressUtils.isValidEthereumAddress(addressController.value.text);
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
