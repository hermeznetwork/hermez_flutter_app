import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/utils/hermez_colors.dart';
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
    final addressController = useTextEditingController();
    final amountController = useTextEditingController();
    //final transferStore = useWalletTransfer(context);

    /*useEffect(() {
      if (token != null) toController.value = TextEditingValue(text: token);
      return null;
    }, [token]);*/

    return Column(
        children: ListTile.divideTiles(
            context: context,
            color: HermezColors.blueyGreyThree,
            tiles: [
          transactionType == TransactionType.DEPOSIT
              ? Container()
              : ListTile(
                  title: Text('Status',
                      style: TextStyle(
                        color: HermezColors.blackTwo,
                        fontSize: 16,
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w500,
                      )),
                  trailing: Text('Confirmed',
                      style: TextStyle(
                        color: HermezColors.black,
                        fontSize: 16,
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w700,
                      )),
                ),
          ListTile(
            contentPadding:
                EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 15),
            title: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('From',
                        style: TextStyle(
                          color: HermezColors.blackTwo,
                          fontSize: 16,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w500,
                        )),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('My Ethereum address',
                          style: TextStyle(
                            color: HermezColors.black,
                            fontSize: 16,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w700,
                          )),
                    )
                  ],
                ),
                SizedBox(height: 7),
                Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '0x8D70...461B5',
                      style: TextStyle(
                        color: HermezColors.blueyGreyTwo,
                        fontSize: 16,
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w500,
                      ),
                    ))
              ],
            ),
          ),
          ListTile(
            contentPadding:
                EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 15),
            title: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('To',
                        style: TextStyle(
                          color: HermezColors.blackTwo,
                          fontSize: 16,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w500,
                        )),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('My Hermez address',
                          style: TextStyle(
                            color: HermezColors.black,
                            fontSize: 16,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w700,
                          )),
                    )
                  ],
                ),
                SizedBox(height: 7),
                Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'hez:0x8D70...461B5',
                      style: TextStyle(
                        color: HermezColors.blueyGreyTwo,
                        fontSize: 16,
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w500,
                      ),
                    ))
              ],
            ),
          ),
          ListTile(
            contentPadding:
                EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 15),
            title: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Fee',
                        style: TextStyle(
                          color: HermezColors.blackTwo,
                          fontSize: 16,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w500,
                        )),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('€0.1',
                          style: TextStyle(
                            color: HermezColors.black,
                            fontSize: 16,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w700,
                          )),
                    )
                  ],
                ),
                SizedBox(height: 7),
                Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '0.119231 USDT',
                      style: TextStyle(
                        color: HermezColors.blueyGreyTwo,
                        fontSize: 16,
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w500,
                      ),
                    ))
              ],
            ),
          ),
          transactionDate != null
              ? ListTile(
                  title: Text('Date',
                      style: TextStyle(
                        color: HermezColors.blackTwo,
                        fontSize: 16,
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w500,
                      )),
                  trailing: Text('17 Aug 2020',
                      style: TextStyle(
                        color: HermezColors.black,
                        fontSize: 16,
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w700,
                      )),
                )
              : Container(),
        ]).toList());
  }
}
