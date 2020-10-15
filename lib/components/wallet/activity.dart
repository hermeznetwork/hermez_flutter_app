import 'dart:collection';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/model/wallet.dart';
import 'package:hermez/service/network/model/L1_account.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';
import 'package:intl/intl.dart';

import '../../wallet_transaction_details_page.dart';

class Activity extends StatelessWidget {
  Activity(
      {this.store,
      this.account,
      this.address,
      this.symbol,
      this.exchangeRate,
      this.defaultCurrency,
      this.cryptoList});

  final WalletHandler store;
  final L1Account account;
  final String address;
  final String symbol;
  final double exchangeRate;
  final WalletDefaultCurrency defaultCurrency;
  final List cryptoList;

  final bool _loading = false;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      //return buildGroupedList();
      return buildActivityList();
    }
  }

  //widget that builds the list
  Widget buildActivityList() {
    return Container(
        color: Colors.white,
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: cryptoList.length,
            //set the item count so that index won't be out of range
            padding: const EdgeInsets.all(16.0),
            //add some padding to make it look good
            itemBuilder: (context, i) {
              var title = "";
              var subtitle = "";
              LinkedHashMap event = cryptoList.elementAt(i);
              var type = event['type'];
              var txType;
              var status = event['status'];
              var timestamp = event['timestamp'];
              var txHash = event['txHash'];
              var addressFrom = event['from'];
              var addressTo = event['to'];
              final String currency =
                  defaultCurrency.toString().split('.').last;

              var value = event['value'];
              var amount = double.parse(value) / pow(10, 18);
              /*EtherAmount.fromUnitAndValue(
                  EtherUnit.wei, ));*/
              var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
              var format = DateFormat('dd MMM');
              var icon = "";
              var isNegative = false;

              switch (type) {
                case "RECEIVE":
                  txType = TransactionType.RECEIVE;
                  title = "Received";
                  icon = "assets/tx_receive.png";
                  isNegative = false;
                  break;
                case "SEND":
                  txType = TransactionType.SEND;
                  title = "Sent";
                  icon = "assets/tx_send.png";
                  isNegative = true;
                  break;
                case "WITHDRAW":
                  txType = TransactionType.WITHDRAW;
                  title = "Withdrawn";
                  icon = "assets/tx_withdraw.png";
                  isNegative = true;
                  break;
                case "DEPOSIT":
                  txType = TransactionType.DEPOSIT;
                  title = "Deposited";
                  icon = "assets/tx_deposit.png";
                  isNegative = false;
                  break;
              }

              if (status == "CONFIRMED") {
                subtitle = format.format(date);
              }

              return Container(
                child: ListTile(
                  leading: _getLeadingWidget(
                      icon,
                      //element['status'] == 'invalid'
                      /*? Color.fromRGBO(255, 239, 241, 1.0)
                          :*/
                      /*Colors.grey[100]*/ null),
                  title: Container(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      title,
                      maxLines: 1,
                      style: TextStyle(
                        color: HermezColors.black,
                        fontSize: 16,
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  subtitle: Container(
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: HermezColors.blueyGreyTwo,
                        fontSize: 16,
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          //color: double.parse(element['value']) < 0 ? Colors.transparent : Color.fromRGBO(228, 244, 235, 1.0),
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                            (isNegative ? "- " : "") +
                                (currency == "USD" ? "\$" : "€") +
                                (exchangeRate * amount).toStringAsFixed(2),
                            style: TextStyle(
                              color: isNegative
                                  ? HermezColors.black
                                  : HermezColors.green,
                              fontSize: 16,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                            amount.toString() + " " + symbol,
                            style: TextStyle(
                              color: HermezColors.blueyGreyTwo,
                              fontSize: 16,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ]),
                  onTap: () async {
                    Navigator.pushNamed(context, "/transaction_details",
                        arguments: TransactionDetailsArguments(
                            store,
                            txType,
                            TransactionStatus.CONFIRMED,
                            account,
                            /*widget.arguments.store,
                            widget.arguments.amountType,
                            widget.arguments.account,*/
                            amount,
                            txHash,
                            addressFrom,
                            addressTo,
                            date));
                  },
                ),
              );
            }));
  }

  /*Widget buildGroupedList() {
    return Container(
      color: Colors.white,
      child: GroupedListView<dynamic, DateTime>(
          groupBy: (element) => element['date'],
          elements: cryptoList,
          order: GroupedListOrder.DESC,
          useStickyGroupSeparators: true,
          groupSeparatorBuilder: (DateTime value) => Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 30.0, bottom: 30.0, left: 20.0),
                  child: Text(
                    DateFormat('dd MMM yyyy').format(value),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54),
                  ),
                ),
              ),
          itemBuilder: (c, element) {
            var title = "";
            var subtitle = "";
            var type = element['type'];
            var status = element['status'];
            var icon = "";
            if (type == "deposit") {
              title = "Added";
              subtitle = "To your " + element['symbol'] + " account";
              icon = "assets/add.png";
            } else if (type == "send") {
              if (status == "done") {
                title = "Sent";
                icon = "assets/upload.png";
              } else if (status == "pending") {
                title = "Sending is in progress";
                icon = "assets/pending.png";
              } else if (status == "invalid") {
                title = "Sending failed";
                icon = "assets/warning.png";
              }
              subtitle = "To account " + element['to'];
            } else if (type == "withdraw") {
              if (status == "done") {
                title = "Withdrawn";
                icon = "assets/upload.png";
              } else if (status == "pending") {
                title = "Withdrawing is in progress";
                icon = "assets/pending.png";
              } else if (status == "invalid") {
                title = "Withdraw failed";
                icon = "assets/warning.png";
              }
              subtitle = "To your " + element['to'] + " address";
            } else if (type == "receive") {
              if (status == "done") {
                title = "Received";
                icon = "assets/deposit.png";
              } else if (status == "pending") {
                title = "Receiving is in progress";
                icon = "assets/pending.png";
              } else if (status == "invalid") {
                title = "Receiving failed";
                icon = "assets/warning.png";
              }
              subtitle = "From account " + element['to'];
            }
            return Container(
              child: ListTile(
                leading: _getLeadingWidget(
                    icon,
                    element['status'] == 'invalid'
                        ? Color.fromRGBO(255, 239, 241, 1.0)
                        : Colors.grey[100]),
                title: Container(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    title,
                    maxLines: 1,
                    style: TextStyle(
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w800,
                        fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                ),
                subtitle: Container(
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                ),
                trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        //color: double.parse(element['value']) < 0 ? Colors.transparent : Color.fromRGBO(228, 244, 235, 1.0),
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          "€36.45",
                          style: TextStyle(
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w800,
                              color: double.parse(element['value']) < 0
                                  ? Colors.black
                                  : Colors.green,
                              fontSize: 16),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          element['value'] + " " + element['symbol'],
                          style: TextStyle(
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                              fontSize: 16),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ]),
              ),
            );
          }),
    );
  }*/

  // takes in an object and color and returns a circle avatar with first letter and required color
  CircleAvatar _getLeadingWidget(String icon, Color color) {
    return new CircleAvatar(
        radius: 23, backgroundColor: color, child: Image.asset(icon));
  }
}
