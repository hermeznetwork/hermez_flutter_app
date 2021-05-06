import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez/utils/address_utils.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_plugin/addresses.dart';
import 'package:hermez_plugin/environment.dart';
import 'package:hermez_plugin/model/account.dart';
import 'package:hermez_plugin/model/token.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class TransferSummaryForm extends HookWidget {
  TransferSummaryForm({
    this.store,
    this.status,
    this.transactionType,
    this.account,
    this.fee,
    this.feeToken,
    this.gasLimit,
    this.currency,
    this.transactionId,
    this.transactionHash,
    this.transactionDate,
    this.addressFrom,
    this.addressTo,
    @required this.onSubmit,
  });

  final WalletHandler store;
  final Account account;
  final double fee;
  final Token feeToken;
  final int gasLimit;
  final String currency;
  final String transactionId;
  final String transactionHash;
  final TransactionType transactionType;
  final TransactionStatus status;
  final DateTime transactionDate;
  final String addressFrom;
  final String addressTo;
  final void Function(String token, String amount) onSubmit;

  @override
  Widget build(BuildContext context) {
    var format = DateFormat('dd/MM/yyyy, hh:mm:ss a');
    var date = "";
    if (transactionDate != null) {
      date = format.format(transactionDate);
    }

    var statusText = "";
    switch (status) {
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

    return Container(
        child: SingleChildScrollView(
            child: Column(
                children: ListTile.divideTiles(
                    context: context,
                    color: HermezColors.blueyGreyThree,
                    tiles: [
          status == TransactionStatus.DRAFT
              ? Container()
              : ListTile(
                  contentPadding:
                      EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 15),
                  title: Text('Status',
                      style: TextStyle(
                        color: HermezColors.blackTwo,
                        fontSize: 16,
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w500,
                      )),
                  trailing: Text(statusText,
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
                    (addressFrom.toLowerCase() ==
                                store.state.ethereumAddress.toLowerCase() ||
                            addressFrom.toLowerCase() ==
                                getHermezAddress(store.state.ethereumAddress)
                                    .toLowerCase())
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                                transactionType == TransactionType.DEPOSIT ||
                                        (transactionType ==
                                                TransactionType.SEND &&
                                            store.state.txLevel ==
                                                TransactionLevel.LEVEL1)
                                    ? 'My Ethereum address'
                                    : 'My Hermez address',
                                style: TextStyle(
                                  color: HermezColors.black,
                                  fontSize: 16,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w700,
                                )),
                          )
                        : Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              (store.state.txLevel == TransactionLevel.LEVEL1
                                      ? "0x" +
                                          AddressUtils.strip0x(
                                                  addressFrom.substring(0, 6))
                                              .toUpperCase()
                                      : "hez:0x" +
                                          AddressUtils.stripHez0x(
                                                  addressFrom.substring(0, 10))
                                              .toUpperCase()) +
                                  " ･･･ " +
                                  addressFrom
                                      .substring(addressFrom.length - 5,
                                          addressFrom.length)
                                      .toUpperCase(),
                              style: TextStyle(
                                color: HermezColors.black,
                                fontSize: 16,
                                fontFamily: 'ModernEra',
                                fontWeight: FontWeight.w700,
                              ),
                            ))
                  ],
                ),
                SizedBox(height: 7),
                (addressFrom == store.state.ethereumAddress ||
                        addressFrom.toLowerCase() ==
                            getHermezAddress(store.state.ethereumAddress)
                                .toLowerCase())
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          (transactionType == TransactionType.DEPOSIT ||
                                      (transactionType ==
                                              TransactionType.SEND &&
                                          store.state.txLevel ==
                                              TransactionLevel.LEVEL1)
                                  ? "0x"
                                  : "hez:0x") +
                              AddressUtils.strip0x(store.state.ethereumAddress
                                      .substring(0, 6))
                                  .toUpperCase() +
                              " ･･･ " +
                              store.state.ethereumAddress
                                  .substring(
                                      store.state.ethereumAddress.length - 5,
                                      store.state.ethereumAddress.length)
                                  .toUpperCase(),
                          style: TextStyle(
                            color: HermezColors.blueyGreyTwo,
                            fontSize: 16,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : addressFrom.toLowerCase() ==
                                store.state.ethereumAddress.toLowerCase() ||
                            addressFrom.toLowerCase() ==
                                getCurrentEnvironment()
                                    .contracts['Hermez']
                                    .toLowerCase()
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "0x" +
                                  AddressUtils.strip0x(
                                          addressFrom.substring(0, 6))
                                      .toUpperCase() +
                                  " ･･･ " +
                                  addressFrom
                                      .substring(addressFrom.length - 5,
                                          addressFrom.length)
                                      .toUpperCase(),
                              style: TextStyle(
                                color: HermezColors.blueyGreyTwo,
                                fontSize: 16,
                                fontFamily: 'ModernEra',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : Container(),
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
                    (addressTo.toLowerCase() ==
                                store.state.ethereumAddress.toLowerCase() ||
                            addressTo.toLowerCase() ==
                                getHermezAddress(store.state.ethereumAddress)
                                    .toLowerCase() ||
                            addressTo.toLowerCase() ==
                                getCurrentEnvironment()
                                    .contracts['Hermez']
                                    .toLowerCase())
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                                transactionType == TransactionType.DEPOSIT ||
                                        (transactionType ==
                                                TransactionType.RECEIVE &&
                                            store.state.txLevel ==
                                                TransactionLevel.LEVEL2)
                                    ? 'My Hermez address'
                                    : 'My Ethereum address',
                                style: TextStyle(
                                  color: HermezColors.black,
                                  fontSize: 16,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w700,
                                )),
                          )
                        : Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              (store.state.txLevel == TransactionLevel.LEVEL1
                                      ? "0x" +
                                          AddressUtils.strip0x(
                                                  addressTo.substring(0, 6))
                                              .toUpperCase()
                                      : "hez:0x" +
                                          AddressUtils.stripHez0x(
                                                  addressTo.substring(0, 10))
                                              .toUpperCase()) +
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
                  ],
                ),
                SizedBox(height: 7),
                (addressTo.toLowerCase() ==
                            store.state.ethereumAddress.toLowerCase() ||
                        addressTo.toLowerCase() ==
                            getHermezAddress(store.state.ethereumAddress)
                                .toLowerCase() ||
                        addressTo.toLowerCase() ==
                            getCurrentEnvironment()
                                .contracts['Hermez']
                                .toLowerCase())
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          (transactionType == TransactionType.DEPOSIT ||
                                      (transactionType ==
                                              TransactionType.RECEIVE &&
                                          store.state.txLevel ==
                                              TransactionLevel.LEVEL2)
                                  ? "hez:0x"
                                  : "0x") +
                              AddressUtils.strip0x(store.state.ethereumAddress
                                      .substring(0, 6))
                                  .toUpperCase() +
                              " ･･･ " +
                              store.state.ethereumAddress
                                  .substring(
                                      store.state.ethereumAddress.length - 5,
                                      store.state.ethereumAddress.length)
                                  .toUpperCase(),
                          style: TextStyle(
                            color: HermezColors.blueyGreyTwo,
                            fontSize: 16,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : Container()
              ],
            ),
          ),
          transactionDate != null
              ? Container()
              : ListTile(
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
                            child: Text(
                                (feeToken.USD *
                                            (currency != "USD"
                                                ? store.state.exchangeRatio
                                                : 1) *
                                            (fee.toDouble() /
                                                pow(10, feeToken.decimals)))
                                        .toStringAsFixed(2) +
                                    " " +
                                    currency,
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
                            (fee.toDouble() / pow(10, feeToken.decimals))
                                    .toStringAsFixed(6) +
                                " " +
                                feeToken.symbol,
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
          transactionDate != null && status != TransactionStatus.DRAFT
              ? ListTile(
                  contentPadding:
                      EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 15),
                  title: Text('Date',
                      style: TextStyle(
                        color: HermezColors.blackTwo,
                        fontSize: 16,
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w500,
                      )),
                  trailing: Text(date,
                      style: TextStyle(
                        color: HermezColors.black,
                        fontSize: 16,
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w700,
                      )),
                )
              : Container(),
          status != TransactionStatus.DRAFT
              ? ListTile(
                  contentPadding:
                      EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 15),
                  onTap: () async {
                    var url;
                    if (transactionId != null) {
                      url = getCurrentEnvironment().batchExplorerUrl +
                          '/transaction/' +
                          transactionId;
                    } else {
                      url = getCurrentEnvironment().etherscanUrl +
                          "/tx/" +
                          transactionHash;
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
                            color: HermezColors.blueyGreyTwo,
                            fontSize: 16,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
        ]).toList())));
  }
}
