import 'dart:collection';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/model/wallet.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';
import 'package:hermez_plugin/addresses.dart';
import 'package:hermez_plugin/model/account.dart';
import 'package:hermez_plugin/model/exit.dart';
import 'package:hermez_plugin/model/forged_transaction.dart';
import 'package:hermez_plugin/model/forged_transactions_response.dart';
import 'package:intl/intl.dart';

import '../../wallet_transaction_details_page.dart';

class ActivityArguments {
  final WalletHandler store;
  final Account account;
  final String address;
  final String symbol;
  final double exchangeRate;
  final WalletDefaultCurrency defaultCurrency;

  ActivityArguments(this.store, this.account, this.address, this.symbol,
      this.exchangeRate, this.defaultCurrency);
}

class Activity extends StatefulWidget {
  Activity({Key key, this.arguments}) : super(key: key);

  final ActivityArguments arguments;

  @override
  _ActivityState createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  final ScrollController _controller = ScrollController();

  bool _isLoading = false;
  List<String> _dummy = List.generate(20, (index) => 'Item $index');
  int fromItem = 0;
  int pendingItems = 0;
  List<ForgedTransaction> transactions = [];

  @override
  void initState() {
    _controller.addListener(_onScroll);
    fetchData();
    super.initState();
  }

  _onScroll() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange &&
        pendingItems > 0) {
      setState(() {
        _isLoading = true;
        fetchData();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /*return FutureBuilder<List<dynamic>>(
      future: fetchTransactions(),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(
                backgroundColor: HermezColors.orange,
              ),
            ),
          );
        } else {
          if (snapshot.hasError) {
            // while data is loading:
            return Container(
              color: Colors.white,
              child: Center(
                child: Text('There was an error:' + snapshot.error.toString()),
              ),
            );
          } else {
            if (snapshot.hasData && snapshot.data.length > 0) {
              return buildActivityList();
            } else {
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 60.0, right: 60.0, top: 50.0, bottom: 50.0),
                  color: Colors.white,
                  child: Text(
                    'Account transactions will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: HermezColors.blueyGrey,
                      fontSize: 16,
                      fontFamily: 'ModernEra',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }
          }
        }
      },
    );*/
    return buildActivityList();
  }

  //widget that builds the list
  Widget buildActivityList(/*List<dynamic> dataList*/) {
    return Container(
      color: Colors.white,
      child: RefreshIndicator(
        child: ListView.builder(
          controller: _controller,
          shrinkWrap: true,
          itemCount: _isLoading ? transactions.length + 1 : transactions.length,
          //set the item count so that index won't be out of range
          padding: const EdgeInsets.all(16.0),
          //add some padding to make it look good
          itemBuilder: (context, index) {
            if (transactions.length == index)
              return Center(child: CircularProgressIndicator());
            var title = "";
            var subtitle = "";
            dynamic element = transactions.elementAt(index);
            var type = 'type';
            var txType;
            var status = 'status';
            var timestamp = 0;
            var txHash = 'txHash';
            var addressFrom = 'from';
            var addressTo = 'to';
            var value = '0';
            if (element.runtimeType == LinkedHashMap) {
              LinkedHashMap event = element;
              type = event['type'];
              status = event['status'];
              timestamp = event['timestamp'];
              txHash = event['txHash'];
              addressFrom = event['from'];
              addressTo = event['to'];
              value = event['value'];
            } else if (element.runtimeType == ForgedTransaction) {
              ForgedTransaction transaction = element;
              if (transaction.type == "CreateAccountDeposit" ||
                  transaction.type == "Deposit") {
                type = "DEPOSIT";
                value = transaction.l1info.depositAmount.toString();
                if (transaction.l1info.depositAmountSuccess == true) {
                  status = "CONFIRMED";
                  final formatter = DateFormat(
                      "yyyy-MM-ddThh:mm:ssZ"); // "2021-03-18T10:42:01Z"
                  final DateTime dateTimeFromStr =
                      formatter.parse(transaction.timestamp);
                  timestamp = dateTimeFromStr.millisecondsSinceEpoch;
                }
                addressFrom =
                    getEthereumAddress(transaction.fromHezEthereumAddress);
                addressTo = transaction.fromHezEthereumAddress;
              } else if (transaction.type == "Exit" ||
                  transaction.type == "ForceExit") {
                type = "WITHDRAW";
                value = transaction.amount.toString();
                if (transaction.timestamp.isNotEmpty) {
                  status = "CONFIRMED";
                  final formatter = DateFormat(
                      "yyyy-MM-ddThh:mm:ssZ"); // "2021-03-18T10:42:01Z"
                  final DateTime dateTimeFromStr =
                      formatter.parse(transaction.timestamp);
                  timestamp = dateTimeFromStr.millisecondsSinceEpoch;
                }
                addressFrom = transaction.fromHezEthereumAddress;
                addressTo =
                    getEthereumAddress(transaction.fromHezEthereumAddress);
              } else if (transaction.type == "Transfer") {
                value = transaction.amount.toString();
                if (transaction.fromAccountIndex ==
                    widget.arguments.account.accountIndex) {
                  type = "SEND";
                  if (transaction.timestamp.isNotEmpty) {
                    status = "CONFIRMED";
                    final formatter = DateFormat(
                        "yyyy-MM-ddThh:mm:ssZ"); // "2021-03-18T10:42:01Z"
                    final DateTime dateTimeFromStr =
                        formatter.parse(transaction.timestamp);
                    timestamp = dateTimeFromStr.millisecondsSinceEpoch;
                  }
                  addressFrom = transaction.fromHezEthereumAddress;
                  addressTo = transaction.toHezEthereumAddress;
                } else if (transaction.toAccountIndex ==
                    widget.arguments.account.accountIndex) {
                  type = "RECEIVE";
                  if (transaction.timestamp.isNotEmpty) {
                    status = "CONFIRMED";
                    final formatter = DateFormat(
                        "yyyy-MM-ddThh:mm:ssZ"); // "2021-03-18T10:42:01Z"
                    final DateTime dateTimeFromStr =
                        formatter.parse(transaction.timestamp);
                    timestamp = dateTimeFromStr.millisecondsSinceEpoch;
                  }
                }
              } else {
                txHash = transaction.id;
              }
              txHash = transaction.id;
            }
            final String currency =
                widget.arguments.defaultCurrency.toString().split('.').last;

            var amount = double.parse(value) / pow(10, 18);
            /*EtherAmount.fromUnitAndValue(
                  EtherUnit.wei, ));*/
            var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
            //var format = DateFormat('dd MMM');
            var format = DateFormat('dd/MM/yyyy');
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
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          amount.toString() + " " + widget.arguments.symbol,
                          style: TextStyle(
                            color: HermezColors.black,
                            fontSize: 16,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Container(
                        //color: double.parse(element['value']) < 0 ? Colors.transparent : Color.fromRGBO(228, 244, 235, 1.0),
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          (isNegative ? "- " : "") +
                              (currency == "USD" ? "\$" : "€") +
                              (widget.arguments.exchangeRate * amount)
                                  .toStringAsFixed(2),
                          style: TextStyle(
                            color: isNegative
                                ? HermezColors.blueyGreyTwo
                                : HermezColors.green,
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
                          wallet: widget.arguments.store,
                          transactionType: txType,
                          status: TransactionStatus.CONFIRMED,
                          account: widget.arguments.account,
                          token: widget.arguments.account.token,
                          /*widget.arguments.store,
                            widget.arguments.amountType,
                            widget.arguments.account,*/
                          amount: amount,
                          transactionHash: txHash,
                          addressFrom: addressFrom,
                          addressTo: addressTo,
                          transactionDate: date));
                },
              ),
            );
          },
        ),
        onRefresh: _onRefresh,
      ),
    );
  }

  Future<void> _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));

    setState(() {
      fromItem = 0;
      _isLoading = true;
      transactions = [];
      fetchData();
    });
    // if failed,use refreshFailed()
    //_elements = widget.arguments.cryptoList;
    //_refreshController.refreshCompleted();
  }

  Future<void> fetchData() async {
    List<Exit> exits = await fetchExits(widget.arguments.account.token.id);
    ForgedTransactionsResponse response = await fetchHistoryTransactions();
    final filteredTransactions = filterExitsFromHistoryTransactions(
      response.transactions,
      exits,
      /*pendingWithdrawsAccount,
        pendingDelayedWithdrawsAccount,
        wallet,
        dispatch*/
    );
    setState(() {
      pendingItems = response.pendingItems;
      fromItem = filteredTransactions.last.itemId;
      transactions.addAll(filteredTransactions);
      _isLoading = false;
    });
  }

  Future<ForgedTransactionsResponse> fetchHistoryTransactions() async {
    return await widget.arguments.store.getHermezTransactionsByAddress(
        widget.arguments.store.state.ethereumAddress,
        widget.arguments.account,
        fromItem);
  }

  Future<List<Exit>> fetchExits(int tokenId) {
    return widget.arguments.store.getExits(tokenId: tokenId);
  }

  List<ForgedTransaction> filterExitsFromHistoryTransactions(
      List<ForgedTransaction> historyTransactions, List<Exit> exits) {
    List<ForgedTransaction> filteredTransactions =
        List.from(historyTransactions);
    filteredTransactions.removeWhere((ForgedTransaction transaction) {
      if (transaction.type == 'Exit') {
        final exitId =
            transaction.fromAccountIndex + transaction.batchNum.toString();
        Exit exitTx;
        exits.forEach((Exit exit) {
          if (exit.batchNum == transaction.batchNum &&
              exit.accountIndex == transaction.fromAccountIndex) {
            exitTx = exit;
          }
        });

        if (exitTx != null) {
          if (exitTx.instantWithdraw != null ||
              exitTx.delayedWithdraw != null) {
            /*const pendingWithdraw = pendingWithdraws.find((pendingWithdraw) => pendingWithdraw.id === exitId)
          if (pendingWithdraw) {
            dispatch(removePendingWithdraw(exitId))
          }

          const pendingDelayedWithdraw = pendingDelayedWithdraws.find((pendingDelayedWithdraw) => pendingDelayedWithdraw.id === exitId)
          if (pendingDelayedWithdraw) {
            dispatch(removePendingDelayedWithdraw(exitId))
          }*/
            return false;
          } else {
            return true;
          }
        }
      }

      return false;
    });
    return filteredTransactions;
  }

  /// Fetches the transactions details for the specified account index
  /// @param {string} accountIndex - Account index
  /// @returns {void}
  /*Future<List<dynamic>> fetchHistoryTransactions(Account account, int fromItem,
      {List<Exit> exits}) async {
    await widget.arguments.store
        .getTransactionsByAddress(
            widget.arguments.store.state.ethereumAddress, account, fromItem)
        .then((res) => {
              //List<ForgedTransaction> transactions = res.transactions;
              //transactions.remove
              //res.transactions as ForgedTransaction = res.transactions.
            });
  }*/

  // takes in an object and color and returns a circle avatar with first letter and required color
  CircleAvatar _getLeadingWidget(String icon, Color color) {
    return new CircleAvatar(
        radius: 23, backgroundColor: color, child: Image.asset(icon));
  }
}
