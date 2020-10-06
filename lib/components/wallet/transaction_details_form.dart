import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/context/transfer/wallet_transfer_provider.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/service/network/model/L1_account.dart';
import 'package:hermez/utils/address_utils.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';

class TransferSummaryForm extends HookWidget {
  TransferSummaryForm({
    this.store,
    this.account,
    this.amount,
    this.transactionType,
    this.transactionDate,
    this.addressTo,
    @required this.onSubmit,
  });

  final WalletHandler store;
  final L1Account account;
  final int amount;
  final TransactionType transactionType;
  final DateTime transactionDate;
  final String addressTo;
  final void Function(String token, String amount) onSubmit;

  @override
  Widget build(BuildContext context) {
    //final toController = useTextEditingController(text: token);
    final addressController = useTextEditingController();
    final amountController = useTextEditingController();
    final transferStore = useWalletTransfer(context);

    /*useEffect(() {
      if (token != null) toController.value = TextEditingValue(text: token);
      return null;
    }, [token]);*/

    return Column(
        children: ListTile.divideTiles(
            context: context,
            color: HermezColors.blueyGreyThree,
            tiles: [
          transactionDate == null
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
                    transactionType == TransactionType.SEND
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: Text('My Ethereum address',
                                style: TextStyle(
                                  color: HermezColors.black,
                                  fontSize: 16,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w700,
                                )),
                          )
                        : Container()
                  ],
                ),
                SizedBox(height: 7),
                Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      transactionType == TransactionType.SEND
                          ? "0x" +
                              AddressUtils.strip0x(
                                      store.state.address.substring(0, 6))
                                  .toUpperCase() +
                              " ･･･ " +
                              store.state.address
                                  .substring(store.state.address.length - 5,
                                      store.state.address.length)
                                  .toUpperCase()
                          : '0x8D70...461B5',
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
                    transactionType == TransactionType.SEND
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "0x" +
                                  AddressUtils.strip0x(
                                          addressTo.substring(0, 6))
                                      .toUpperCase() +
                                  " ･･･ " +
                                  addressTo
                                      .substring(addressTo.length - 5,
                                          addressTo.length)
                                      .toUpperCase(),
                              style: TextStyle(
                                color: HermezColors.black,
                                fontSize: 16,
                                fontFamily: 'ModernEra',
                                fontWeight: FontWeight.w700,
                              ),
                            ))
                        : Align(
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
                transactionType == TransactionType.SEND
                    ? Container()
                    : Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          addressTo.substring(0, 6) +
                              " ･･･ " +
                              addressTo.substring(
                                  addressTo.length - 5, addressTo.length),
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
