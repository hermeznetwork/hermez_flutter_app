import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hermez/components/form/address_input.dart';
import 'package:hermez/components/form/amount_input.dart';
import 'package:hermez/components/form/paper_form.dart';
import 'package:hermez/components/wallet/account_row.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';

class TransferAmountForm extends StatefulWidget {
  TransferAmountForm(
      {Key key,
      this.token,
      this.amount,
      this.amountType,
      @required this.onSubmit})
      : super(key: key);

  final dynamic token;
  final int amount;
  final TransactionType amountType;
  final void Function(String token, String amount) onSubmit;

  @override
  _TransferAmountFormState createState() =>
      _TransferAmountFormState(token, amount, amountType, onSubmit);
}

class _TransferAmountFormState extends State<TransferAmountForm> {
  _TransferAmountFormState(
      this.token, this.amount, this.amountType, this.onSubmit);

  final dynamic token;
  final int amount;
  final TransactionType amountType;
  final void Function(String token, String amount) onSubmit;
  bool amountIsValid = true;
  bool addressIsValid = true;

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

    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.white,
      child: SingleChildScrollView(
        child: PaperForm(
          actionButtons: <Widget>[
            Column(
              children: <Widget>[
                FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                      side:
                          BorderSide(color: Color.fromRGBO(211, 87, 46, 1.0))),
                  onPressed: () {
                    this.onSubmit(
                      //toController.value.text,
                      amountController.value.text,
                      amountController.value.text,
                    );
                  },
                  padding: EdgeInsets.all(15.0),
                  color: Color.fromRGBO(211, 87, 46, 1.0),
                  textColor: Colors.white,
                  child: Text(
                      amountType == TransactionType.DEPOSIT
                          ? "Continue"
                          : "Next",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      )),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(top: 20.0),
                  child: Text("Fee: €0.1" /*element['name']*/,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ],
            )
          ],
          children: <Widget>[
            //PaperValidationSummary(transferStore.state.errors.toList()),
            AccountRow(
              token['name'],
              token['symbol'],
              token['price'],
              token['value'],
              true,
              (token, amount) async {
                Navigator.of(context).pushReplacementNamed("/token_selector",
                    arguments: amountType);
              },
            ),
            _buildAmountRow(context, null, amountController),
            amountType == TransactionType.SEND
                ? _buildAddressToRow(context, null, addressController)
                : addressRow()
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
                    onChanged: (value) {
                      setState(() {
                        addressIsValid = value.isNotEmpty;
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
                    "EUR" /*element['name']*/,
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
                        amountIsValid = double.parse(value) < 100;
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
                            onPressed: () {},
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
                            onPressed: () {},
                            icon: Image.asset(
                              "assets/arrows_up_down.png",
                              color: HermezColors.blueyGreyTwo,
                            ),
                            label: Text(
                              token['symbol'],
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

  Widget _buildAddressToRow(
      BuildContext context, dynamic element, dynamic addressController) {
    // returns a row with the desired properties
    return Container(
        padding: EdgeInsets.only(bottom: 15.0),
        child: FlatButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: Color.fromRGBO(130, 130, 130, 1.0))),
          padding: EdgeInsets.all(10.0),
          color: Colors.transparent,
          textColor: Colors.black,
          child: ListTile(
              title: Row(
            children: <Widget>[
              Expanded(
                  child: AddressInput(
                controller: addressController,
              )),
              Container(
                child: FlatButton(
                  child: Text(
                    "Paste",
                    style: TextStyle(
                      color: Color.fromRGBO(130, 130, 130, 1.0),
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () {
                    getClipBoardData().then((String result) {
                      addressController.clear();
                      addressController.text = result;
                    });
                  },
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    "assets/scan.png",
                    color: Color.fromRGBO(130, 130, 130, 1.0),
                  )),
            ],
          )), //title to be name of the crypto
        ));
  }

  Future<String> getClipBoardData() async {
    ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
    return data.text;
  }
}
