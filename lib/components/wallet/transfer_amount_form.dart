import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/components/form/address_input.dart';
import 'package:hermez/components/form/amount_input.dart';
import 'package:hermez/components/form/paper_form.dart';
import 'package:hermez/components/wallet/account_row.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';

class TransferAmountForm extends HookWidget {
  TransferAmountForm({
    this.token,
    this.amount,
    this.amountType,
    @required this.onSubmit,
  });

  final dynamic token;
  final int amount;
  final TransactionType amountType;
  final void Function(String token, String amount) onSubmit;

  @override
  Widget build(BuildContext context) {
    //final toController = useTextEditingController(text: token);
    final amountController = useTextEditingController();
    final addressController = useTextEditingController();

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
                : Container()
            /*PaperInput(
                controller: toController,
                labelText: 'To',
                hintText: 'Name, Phone, Email, Eth address',
              ),*/
            /*PaperInput(
                controller: toController,
                labelText: 'For',
                hintText: 'Add a message',
              ),
              PaperInput(
                controller: amountController,
                labelText: 'Amount',
                hintText: 'And amount',
              ),*/
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(
      BuildContext context, dynamic element, dynamic amountController) {
    // returns a row with the desired properties
    return Container(
        padding: EdgeInsets.only(bottom: 15.0),
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: HermezColors.blueyGreyThree,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.only(top: 20.0),
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    child: Text("EUR" /*element['name']*/,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.0),
                    child: AmountInput(
                      onChanged: (value) {},
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
                              icon: Image.asset("assets/arrows_up_down.png"),
                              label: Text(
                                "EUR",
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
            )));
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
