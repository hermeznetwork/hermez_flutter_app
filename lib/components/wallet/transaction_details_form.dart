import 'package:flutter/services.dart';
import 'package:hermez/components/form/address_input.dart';
import 'package:hermez/components/form/amount_input.dart';
import 'package:hermez/components/form/paper_form.dart';
import 'package:hermez/components/form/paper_validation_summary.dart';
import 'package:hermez/components/wallet/account_row.dart';
import 'package:hermez/context/transfer/wallet_transfer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';

class TransferSummaryForm extends HookWidget {
  TransferSummaryForm({
    this.token,
    this.amount,
    this.transactionType,
    this.transactionDate,
    @required this.onSubmit,
  });

  final dynamic token;
  final int amount;
  final TransactionType transactionType;
  final DateTime transactionDate;
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
      color: Colors.white,
          child:
              ListView(
                children: ListTile.divideTiles(
                    context: context,
                    color: Colors.black54,
                    tiles: [
                      _buildAmountRow(context, null, amountController),
                      transactionType == TransactionType.DEPOSIT ?
                       Container(): ListTile(
                        title: Text('Status',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            )),
                        trailing: Text('Confirmed',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 15),
                        title: Column(children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                            Text('From',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                )),
                              Align(
                                alignment: Alignment.centerRight,
                              child:
                                Text('My Ethereum address',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                )),
                            )
                          ],),
                          SizedBox(height: 7),
                          Align(
                            alignment: Alignment.centerRight,
                            child:
                            Text('0x8D70...461B5',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                          ))
                        ],),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 15),
                        title: Column(children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('To',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                  )),
                              Align(
                                alignment: Alignment.centerRight,
                                child:
                                Text('My Hermez address',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    )),
                              )
                            ],),
                          SizedBox(height: 7),
                          Align(
                              alignment: Alignment.centerRight,
                              child:
                              Text('hez:0x8D70...461B5',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ))
                        ],),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 15),
                        title: Column(children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Fee',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                  )),
                              Align(
                                alignment: Alignment.centerRight,
                                child:
                                Text('€0.1',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    )),
                              )
                            ],),
                          SizedBox(height: 7),
                          Align(
                              alignment: Alignment.centerRight,
                              child:
                              Text('0.119231 USDT',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ))
                        ],),
                      ),
                      transactionDate != null ?
                      ListTile(
                        title: Text('Date',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                        )),
                        trailing: Text('17 Aug 2020',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            )),
                      ) : Container(),
                      transactionDate == null ?
                       Column(
                    children: <Widget>[
                      SizedBox(height: 20),
                      FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.0),
                            side: BorderSide(color: Color.fromRGBO(211, 87, 46, 1.0))),
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
                        child: Text("Send",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                      SizedBox(height: 20),
                  ]) : Container()
                    ]
                ).toList(),
              ),
    );
  }

  Widget _buildAmountRow(BuildContext context, dynamic element, dynamic amountController) {
    // returns a row with the desired properties
    return Container(
      color: Color.fromRGBO(243, 243, 243, 1.0),
        padding: EdgeInsets.only(bottom: 15.0),
        child: ListTile(
              title: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 10.0),
                    child:
                    Text("€5",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 48.0,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15.0, bottom: 30.0),
                    child: Text("5,899510 USDT",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromRGBO(130, 130, 130, 1.0),
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ), //title to be name of the crypto
            )
        );
  }
}
