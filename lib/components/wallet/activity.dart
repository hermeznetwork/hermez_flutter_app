import 'dart:collection';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hermez/components/wallet/withdrawal_row.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/model/wallet.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_plugin/addresses.dart';
import 'package:hermez_plugin/model/account.dart';
import 'package:hermez_plugin/model/exit.dart';
import 'package:hermez_plugin/model/forged_transaction.dart';
import 'package:hermez_plugin/model/l1info.dart';
import 'package:hermez_plugin/model/pool_transaction.dart';
import 'package:hermez_plugin/model/token.dart';
import 'package:intl/intl.dart';

import '../../screens/transaction_details.dart';

class ActivityArguments {
  final WalletHandler store;
  final Account account;
  final String address;
  final String symbol;
  final double exchangeRate;
  final WalletDefaultCurrency defaultCurrency;
  final BuildContext parentContext;

  ActivityArguments(this.store, this.account, this.address, this.symbol,
      this.exchangeRate, this.defaultCurrency, this.parentContext);
}

class Activity extends StatefulWidget {
  Activity({Key key, this.arguments}) : super(key: key);

  final ActivityArguments arguments;

  @override
  _ActivityState createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  final ScrollController _controller = ScrollController();

  bool _isLoading = true;
  int fromItem = 0;
  int pendingItems = 0;
  List<dynamic> transactions = [];
  List<Exit> exits = [];
  List<dynamic> poolTxs = [];
  List<dynamic> pendingExits = [];
  List<dynamic> pendingWithdraws = [];
  List<dynamic> pendingDeposits = [];

  @override
  void initState() {
    _controller.addListener(_onScroll);
    fetchData();
    super.initState();
  }

  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
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

  Future<void> _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    fromItem = 0;
    exits = [];
    poolTxs = [];
    pendingExits = [];
    pendingWithdraws = [];
    pendingDeposits = [];
    transactions = [];

    setState(() {
      _isLoading = true;
      fetchData();
    });
    // if failed,use refreshFailed()
    //_elements = widget.arguments.cryptoList;
    //_refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildActivityList();
  }

  //widget that builds the list
  Widget buildActivityList() {
    if (_isLoading &&
        transactions.isEmpty &&
        poolTxs.isEmpty &&
        pendingExits.isEmpty &&
        exits.isEmpty &&
        pendingWithdraws.isEmpty) {
      return Container(
        color: Colors.white,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (!_isLoading &&
        transactions.isEmpty &&
        poolTxs.isEmpty &&
        pendingExits.isEmpty &&
        exits.isEmpty &&
        pendingWithdraws.isEmpty) {
      return Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(34.0),
          child: Text(
            'Account transactions will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: HermezColors.blueyGrey,
              fontSize: 16,
              fontFamily: 'ModernEra',
              fontWeight: FontWeight.w500,
            ),
          ));
    } else {
      return Container(
        color: Colors.white,
        child: RefreshIndicator(
          child: ListView.builder(
              controller: _controller,
              shrinkWrap: true,
              // To make listView scrollable
              // even if there is only a single item.
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: (pendingExits.isNotEmpty ||
                          exits.isNotEmpty ||
                          pendingWithdraws.isNotEmpty
                      ? 1
                      : 0) +
                  transactions.length +
                  (_isLoading ? 1 : 0),
              //set the item count so that index won't be out of range
              padding: const EdgeInsets.all(16.0),
              //add some padding to make it look good
              itemBuilder: (context, i) {
                if (i == 0 && pendingWithdraws.length > 0) {
                  final index = i;
                  final Token token =
                      Token.fromJson(pendingWithdraws[index]['token']);

                  final Exit exit = Exit(
                      hezEthereumAddress: pendingWithdraws[index]
                          ['hermezEthereumAddress'],
                      token: token,
                      balance: pendingWithdraws[index]['amount']
                          .toString()
                          .replaceAll('.0', ''));

                  final String currency = widget
                      .arguments.store.state.defaultCurrency
                      .toString()
                      .split('.')
                      .last;

                  return WithdrawalRow(exit, 3, currency,
                      widget.arguments.store.state.exchangeRatio, () {});
                } else if (i == 0 && exits.length > 0) {
                  final index = i;
                  final Exit exit = exits[index];

                  final String currency = widget
                      .arguments.store.state.defaultCurrency
                      .toString()
                      .split('.')
                      .last;

                  return WithdrawalRow(exit, 2, currency,
                      widget.arguments.store.state.exchangeRatio, () async {
                    Navigator.of(widget.arguments.parentContext)
                        .pushNamed("/transaction_details",
                            arguments: TransactionDetailsArguments(
                              wallet: widget.arguments.store,
                              transactionType: TransactionType.WITHDRAW,
                              status: TransactionStatus.DRAFT,
                              token: exit.token,
                              //account: widget.arguments.account,
                              exit: exit,
                              amount: double.parse(exit.balance) /
                                  pow(10, exit.token.decimals),
                              addressFrom: exit.hezEthereumAddress,
                              //addressTo: address,
                            ));
                  });
                } else if (i == 0 &&
                    pendingExits.length > 0 &&
                    i < pendingExits.length) {
                  final index = i;
                  final PoolTransaction transaction = pendingExits[index];

                  final Exit exit = Exit.fromTransaction(transaction);

                  final String currency = widget
                      .arguments.store.state.defaultCurrency
                      .toString()
                      .split('.')
                      .last;

                  return WithdrawalRow(exit, 1, currency,
                      widget.arguments.store.state.exchangeRatio, () async {});
                } // final index = i ~/ 2; //get the actual index excluding dividers.
                else if ((pendingExits.isNotEmpty || exits.isNotEmpty
                            /*||
                _pendingWithdraws.isNotEmpty*/
                            ? 1
                            : 0) +
                        transactions.length ==
                    i) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  Color statusColor = HermezColors.statusOrange;
                  Color statusBackgroundColor =
                      HermezColors.statusOrangeBackground;
                  var title = "";
                  var subtitle = "";
                  final index = i -
                      (pendingExits.isNotEmpty || exits.isNotEmpty //||
                          //_pendingWithdraws.isNotEmpty
                          ? 1
                          : 0);
                  dynamic element = transactions.elementAt(index);
                  var type = 'type';
                  var txType;
                  var status = 'status';
                  var timestamp = 0;
                  var txId;
                  var txHash;
                  var addressFrom = 'from';
                  var addressTo = 'to';
                  var value = '0';
                  if (element.runtimeType == ForgedTransaction) {
                    ForgedTransaction transaction = element;
                    if (transaction.id != null) {
                      txId = transaction.id;
                    }
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
                      } else if (transaction.timestamp.isNotEmpty) {
                        final formatter = DateFormat(
                            "yyyy-MM-ddThh:mm:ss"); // "2021-03-24T15:42:544802"
                        final DateTime dateTimeFromStr =
                            formatter.parse(transaction.timestamp);
                        timestamp = dateTimeFromStr.millisecondsSinceEpoch;
                        if (transaction.hash != null) {
                          txHash = transaction.hash;
                        }
                      }
                      addressFrom = getEthereumAddress(
                          transaction.fromHezEthereumAddress);
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
                      addressTo = getEthereumAddress(
                          transaction.fromHezEthereumAddress);
                    } else if (transaction.type == "Transfer") {
                      value = transaction.amount.toString();
                      if (transaction.fromAccountIndex ==
                          widget.arguments.account.accountIndex) {
                        type = "SEND";
                        if (transaction.batchNum != null) {
                          status = "CONFIRMED";
                          final formatter = DateFormat(
                              "yyyy-MM-ddThh:mm:ssZ"); // "2021-03-18T10:42:01Z"
                          final DateTime dateTimeFromStr =
                              formatter.parse(transaction.timestamp);
                          timestamp = dateTimeFromStr.millisecondsSinceEpoch;
                        } else if (transaction.timestamp.isNotEmpty) {
                          final formatter = DateFormat(
                              "yyyy-MM-ddThh:mm:ss"); // "2021-03-24T15:42:544802"
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
                        addressFrom = transaction.fromHezEthereumAddress;
                        addressTo = transaction.toHezEthereumAddress;
                      }
                    }
                  } else {
                    LinkedHashMap event = element;
                    type = event['type'];
                    status = event['status'];
                    timestamp = event['timestamp'];
                    txHash = event['txHash'];
                    addressFrom = event['from'];
                    addressTo = event['to'];
                    value = event['value'];
                  }
                  final String currency = widget.arguments.defaultCurrency
                      .toString()
                      .split('.')
                      .last;

                  String symbol = "";
                  if (currency == "EUR") {
                    symbol = "€";
                  } else if (currency == "CNY") {
                    symbol = "\¥";
                  } else {
                    symbol = "\$";
                  }

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
                      title = "Moved";
                      icon = "assets/tx_move.png";
                      isNegative = true;
                      break;
                    case "DEPOSIT":
                      txType = TransactionType.DEPOSIT;
                      title = "Moved";
                      icon = "assets/tx_move.png";
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
                      subtitle: status != "CONFIRMED"
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: statusBackgroundColor
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text("Pending",
                                        // On Hold, Pending
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 16,
                                          fontFamily: 'ModernEra',
                                          fontWeight: FontWeight.w500,
                                        )),
                                  )
                                ])
                          : Container(
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
                                amount.toString() +
                                    " " +
                                    widget.arguments.symbol,
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
                                    symbol +
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
                        Navigator.pushNamed(context, "transaction_details",
                            arguments: TransactionDetailsArguments(
                                wallet: widget.arguments.store,
                                transactionType: txType,
                                status: status != "CONFIRMED"
                                    ? TransactionStatus.PENDING
                                    : TransactionStatus.CONFIRMED,
                                account: widget.arguments.account,
                                token: widget.arguments.account.token,
                                amount: amount,
                                transactionId: txId,
                                transactionHash: txHash,
                                addressFrom: addressFrom,
                                addressTo: addressTo,
                                transactionDate: date));
                      },
                    ),
                  );
                }
              }),
          onRefresh: _onRefresh,
        ),
      );
    }
  }

  Future<void> fetchData() async {
    if (widget.arguments.store.state.txLevel == TransactionLevel.LEVEL2) {
      poolTxs =
          await fetchPoolTransactions(widget.arguments.account.accountIndex);
      final List<ForgedTransaction> pendingPoolTxs =
          poolTxs.map((poolTransaction) {
        return ForgedTransaction(
            id: poolTransaction.id,
            amount: poolTransaction.amount,
            type: poolTransaction.type,
            fromHezEthereumAddress: poolTransaction.fromHezEthereumAddress,
            fromAccountIndex: poolTransaction.fromAccountIndex,
            toAccountIndex: poolTransaction.toAccountIndex,
            toHezEthereumAddress: poolTransaction.toHezEthereumAddress,
            timestamp: poolTransaction.timestamp);
      }).toList();
      pendingExits =
          await fetchPendingExits(widget.arguments.account.accountIndex);
      exits = await fetchExits(widget.arguments.account.token.id);
      pendingWithdraws =
          await fetchPendingWithdraws(widget.arguments.account.token.id);
      pendingDeposits =
          await fetchPendingDeposits(widget.arguments.account.token.id);
      final List<ForgedTransaction> pendingDepositsTxs =
          pendingDeposits.map((pendingDeposit) {
        return ForgedTransaction(
            id: pendingDeposit['id'],
            hash: pendingDeposit['hash'],
            l1info: L1Info(depositAmount: pendingDeposit['amount'].toString()),
            type: pendingDeposit['type'],
            fromHezEthereumAddress: pendingDeposit['fromHezEthereumAddress'],
            timestamp: pendingDeposit['timestamp']);
      }).toList();
      if (transactions.isEmpty) {
        transactions.addAll(pendingPoolTxs);
        transactions.addAll(pendingDepositsTxs);
      }
      List<dynamic> historyTransactions = await fetchHistoryTransactions();
      final filteredTransactions = filterExitsFromHistoryTransactions(
        historyTransactions,
        exits,
      );
      setState(() {
        pendingItems = pendingItems;
        fromItem = filteredTransactions.last.itemId;
        transactions.addAll(filteredTransactions);
        _isLoading = false;
      });
    } else {
      List<dynamic> historyTransactions = await fetchHistoryTransactions();
      setState(() {
        pendingItems = 0;
        transactions.addAll(historyTransactions);
        _isLoading = false;
      });
    }
  }

  Future<List<dynamic>> fetchPoolTransactions(String accountIndex) async {
    List<PoolTransaction> poolTxs =
        await widget.arguments.store.getPoolTransactions(accountIndex);
    poolTxs.removeWhere((transaction) => transaction.type == 'Exit');
    return poolTxs;
  }

  Future<List<dynamic>> fetchPendingDeposits(int tokenId) async {
    final accountPendingDeposits =
        await widget.arguments.store.getPendingDeposits();
    accountPendingDeposits.removeWhere((pendingDeposit) =>
        Token.fromJson(pendingDeposit['token']).id != tokenId);
    return accountPendingDeposits;
  }

  Future<List<dynamic>> fetchPendingExits(String accountIndex) async {
    List<PoolTransaction> poolTxs =
        await widget.arguments.store.getPoolTransactions(accountIndex);
    poolTxs.removeWhere((transaction) => transaction.type != 'Exit');
    return poolTxs;
  }

  Future<List<Exit>> fetchExits(int tokenId) {
    return widget.arguments.store.getExits(tokenId: tokenId);
  }

  Future<List<dynamic>> fetchPendingWithdraws(int tokenId) async {
    final accountPendingWithdraws =
        await widget.arguments.store.getPendingWithdraws();
    accountPendingWithdraws.removeWhere((pendingWithdraw) =>
        Token.fromJson(pendingWithdraw['token']).id != tokenId);
    return accountPendingWithdraws;
  }

  Future<List<dynamic>> fetchHistoryTransactions() async {
    if (widget.arguments.store.state.txLevel == TransactionLevel.LEVEL1) {
      return await widget.arguments.store.getEthereumTransactionsByAddress(
          widget.arguments.store.state.ethereumAddress,
          widget.arguments.account,
          fromItem);
    } else {
      final transactionsResponse = await widget.arguments.store
          .getHermezTransactionsByAddress(
              widget.arguments.store.state.ethereumAddress,
              widget.arguments.account,
              fromItem);
      pendingItems = transactionsResponse.pendingItems;
      return transactionsResponse.transactions;
    }
  }

  List<ForgedTransaction> filterExitsFromHistoryTransactions(
      List<ForgedTransaction> historyTransactions, List<Exit> exits) {
    List<ForgedTransaction> filteredTransactions =
        List.from(historyTransactions);
    filteredTransactions.removeWhere((ForgedTransaction transaction) {
      if (transaction.type == 'Exit') {
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

  // takes in an object and color and returns a circle avatar with first letter and required color
  CircleAvatar _getLeadingWidget(String icon, Color color) {
    return new CircleAvatar(
        radius: 23, backgroundColor: color, child: Image.asset(icon));
  }
}
