import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hermez/components/wallet/withdrawal_row.dart';
import 'package:hermez/model/wallet.dart';
import 'package:hermez/screens/qrcode.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez/screens/transaction_details.dart';
import 'package:hermez/service/network/model/gas_price_response.dart';
import 'package:hermez/utils/balance_utils.dart';
import 'package:hermez/utils/blinking_text_animation.dart';
import 'package:hermez/utils/eth_amount_formatter.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/utils/pop_result.dart';
import 'package:hermez_sdk/addresses.dart';
import 'package:hermez_sdk/constants.dart';
import 'package:hermez_sdk/environment.dart';
import 'package:hermez_sdk/model/account.dart';
import 'package:hermez_sdk/model/exit.dart';
import 'package:hermez_sdk/model/forged_transaction.dart';
import 'package:hermez_sdk/model/l1info.dart';
import 'package:hermez_sdk/model/l2info.dart';
import 'package:hermez_sdk/model/pool_transaction.dart';
import 'package:hermez_sdk/model/state_response.dart';
import 'package:hermez_sdk/model/token.dart';
import 'package:hermez_sdk/tx_utils.dart';
import 'package:intl/intl.dart';

import '../context/wallet/wallet_handler.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class AccountDetailsArguments {
  final WalletHandler store;
  Account account;
  BuildContext parentContext;

  AccountDetailsArguments(this.store, this.account, this.parentContext);
}

class AccountDetailsPage extends StatefulWidget {
  AccountDetailsPage({Key key, this.arguments}) : super(key: key);

  final AccountDetailsArguments arguments;

  @override
  _AccountDetailsPageState createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  StateResponse _stateResponse;
  bool _isLoading = true;
  bool _needRefresh = false;
  int fromItem = 0;
  int pendingItems = 0;
  List<dynamic> historyTransactions = [];
  List<dynamic> transactions = [];
  List<Exit> exits = [];
  List<Exit> filteredExits = [];
  List<bool> allowedInstantWithdraws = [];

  List<dynamic> pendingExits = [];
  List<dynamic> pendingForceExits = [];
  List<dynamic> pendingWithdraws = [];
  List<dynamic> pendingDeposits = [];
  List<dynamic> pendingTransfers = [];

  final ScrollController _controller = ScrollController();

  double balance = 0.0;

  Future<void> _onRefresh() {
    fromItem = 0;
    exits = [];
    filteredExits = [];
    pendingWithdraws = [];
    transactions = [];
    //pendingTransfers = []; // Transfers
    //pendingExits = []; // L2 Exits
    //pendingDeposits = [];
    setState(() {
      _isLoading = true;
      _needRefresh = true;
      fetchData();
    });
    return Future.value(null);
  }

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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HermezColors.neutralMedium,
      child: Scaffold(
        body: NestedScrollView(
          body: Container(
            color: HermezColors.light,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(child: _buildTransactionsList()),
                SafeArea(
                  top: false,
                  bottom: true,
                  child: Container(
                    //height: kBottomNavigationBarHeight,
                    color: HermezColors.light,
                  ),
                ),
              ],
            ),
          ),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                floating: true,
                pinned: true,
                snap: false,
                collapsedHeight: kToolbarHeight,
                expandedHeight: 340.0,
                backgroundColor: HermezColors.neutralLight,
                elevation: 0,
                title: Container(
                  padding: EdgeInsets.only(bottom: 20, top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(widget.arguments.account.token.name, // name
                              style: TextStyle(
                                  fontFamily: 'ModernEra',
                                  color: HermezColors.dark,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20))
                        ],
                      )),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            color: HermezColors.neutral),
                        padding: EdgeInsets.only(
                            left: 12.0, right: 12.0, top: 4, bottom: 4),
                        child: Text(
                          widget.arguments.store.state.txLevel ==
                                  TransactionLevel.LEVEL1
                              ? "L1"
                              : "L2",
                          style: TextStyle(
                            color: HermezColors.neutralLight,
                            fontSize: 15,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  // here the desired height*/
                  background: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                          height: MediaQuery.of(context).padding.top +
                              kToolbarHeight +
                              40),
                      SizedBox(
                          width: double.infinity,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                _isLoading
                                    ? BlinkingTextAnimation(
                                        arguments:
                                            BlinkingTextAnimationArguments(
                                                HermezColors.dark,
                                                calculateBalance(widget
                                                    .arguments
                                                    .account
                                                    .token
                                                    .symbol),
                                                32,
                                                FontWeight.w800))
                                    : Text(
                                        calculateBalance(widget
                                            .arguments.account.token.symbol),
                                        style: TextStyle(
                                            color: HermezColors.dark,
                                            fontFamily: 'ModernEra',
                                            fontWeight: FontWeight.w800,
                                            fontSize: 32)),
                              ])),
                      SizedBox(height: 10),
                      _isLoading
                          ? BlinkingTextAnimation(
                              arguments: BlinkingTextAnimationArguments(
                                  HermezColors.neutral,
                                  calculateBalance(widget
                                      .arguments.store.state.defaultCurrency
                                      .toString()
                                      .split('.')
                                      .last),
                                  18,
                                  FontWeight.w500),
                            )
                          : Text(
                              calculateBalance(widget
                                  .arguments.store.state.defaultCurrency
                                  .toString()
                                  .split('.')
                                  .last),
                              style: TextStyle(
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w500,
                                  color: HermezColors.neutral,
                                  fontSize: 18)),
                      SizedBox(height: 30),
                      buildButtonsRow(context),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ];
          },
        ),
      ),
    );
  }

  buildButtonsRow(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <
        Widget>[
      SizedBox(width: 20.0),
      Expanded(
        child: FlatButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            onPressed: () async {
              var results = await Navigator.pushNamed(
                widget.arguments.parentContext,
                "/transaction_amount",
                arguments: TransactionAmountArguments(widget.arguments.store,
                    widget.arguments.store.state.txLevel, TransactionType.SEND,
                    account: widget.arguments.account, allowChangeLevel: false),
              );
              if (results is PopWithResults) {
                PopWithResults popResult = results;
                if (popResult.toPage == "/home") {
                  // TODO do stuff
                  _onRefresh();
                } else {
                  Navigator.of(context).pop(results);
                }
              }
            },
            padding: EdgeInsets.all(10.0),
            color: Colors.transparent,
            textColor: HermezColors.dark,
            child: Column(
              children: <Widget>[
                SvgPicture.asset("assets/bt_send.svg"),
                Text(
                  'Send',
                  style: TextStyle(
                    color: HermezColors.dark,
                    fontFamily: 'ModernEra',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )),
      ),
      Expanded(
        child: FlatButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            onPressed: () {
              widget.arguments.store.state.txLevel == TransactionLevel.LEVEL1
                  ? Navigator.of(widget.arguments.parentContext)
                      .pushNamed(
                        "/qrcode",
                        arguments: QRCodeArguments(
                            qrCodeType: QRCodeType.ETHEREUM,
                            code: widget.arguments.store.state.ethereumAddress,
                            store: widget.arguments.store,
                            isReceive: true),
                      )
                      .then((value) => _onRefresh())
                  : Navigator.of(widget.arguments.parentContext)
                      .pushNamed(
                        "/qrcode",
                        arguments: QRCodeArguments(
                            qrCodeType: QRCodeType.HERMEZ,
                            code: getHermezAddress(
                                widget.arguments.store.state.ethereumAddress),
                            store: widget.arguments.store,
                            isReceive: true),
                      )
                      .then((value) => _onRefresh());
            },
            padding: EdgeInsets.all(10.0),
            color: Colors.transparent,
            textColor: HermezColors.dark,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 5,
                ),
                SvgPicture.asset("assets/bt_receive.svg"),
                Text(
                  'Receive',
                  style: TextStyle(
                    color: HermezColors.dark,
                    fontFamily: 'ModernEra',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )),
      ),
      Expanded(
        child:
            // takes in an object and color and returns a circle avatar with first letter and required color
            FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onPressed: () async {
                  var results = await Navigator.pushNamed(
                    widget.arguments.parentContext,
                    "/transaction_amount",
                    arguments: TransactionAmountArguments(
                        widget.arguments.store,
                        widget.arguments.store.state.txLevel,
                        widget.arguments.store.state.txLevel ==
                                TransactionLevel.LEVEL1
                            ? TransactionType.DEPOSIT
                            : TransactionType.EXIT,
                        account: widget.arguments.account,
                        allowChangeLevel: false),
                  );
                  if (results is PopWithResults) {
                    PopWithResults popResult = results;
                    if (popResult.toPage == "/home") {
                      // TODO do stuff
                      _onRefresh();
                    } else {
                      Navigator.of(context).pop(results);
                    }
                  }
                },
                padding: EdgeInsets.all(10.0),
                color: Colors.transparent,
                textColor: HermezColors.dark,
                child: Column(
                  children: <Widget>[
                    SvgPicture.asset("assets/bt_move.svg"),
                    Text(
                      'Move',
                      style: TextStyle(
                        color: HermezColors.dark,
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )),
      ),
      SizedBox(width: 20.0),
    ]);
  }

  String calculateBalance(String symbol) {
    double resultAmount = BalanceUtils.calculatePendingBalance(
            widget.arguments.store.state.txLevel,
            widget.arguments.account,
            symbol,
            widget.arguments.store,
            historyTransactions: historyTransactions) /
        pow(10, widget.arguments.account.token.decimals);

    return EthAmountFormatter.formatAmount(resultAmount, symbol);
  }

  /*String accountBalance() {
    double resultValue = 0;
    String result = "";
    String locale = "";
    String symbol = "";
    final String currency =
        widget.arguments.store.state.defaultCurrency.toString().split('.').last;
    if (currency == "EUR") {
      locale = 'eu';
      symbol = '€';
    } else if (currency == "CNY") {
      locale = 'en';
      symbol = '\¥';
    } else if (currency == "JPY") {
      locale = 'en';
      symbol = "\¥";
    } else if (currency == "GBP") {
      locale = 'en';
      symbol = "\£";
    } else {
      locale = 'en';
      symbol = '\$';
    }
    if (widget.arguments.account.token.USD != null) {
      double value = widget.arguments.account.token.USD *
          double.parse(widget.arguments.account.balance);
      if (currency != "USD") {
        value *= widget.arguments.store.state.exchangeRatio;
      }
      resultValue = resultValue + value;
    }

    pendingTransfers.forEach((poolTransaction) {
      var amount = (getTokenAmountBigInt(
                  double.parse(poolTransaction.amount) /
                      pow(10, widget.arguments.account.token.decimals),
                  widget.arguments.account.token.decimals)
              .toDouble() /
          pow(10, widget.arguments.account.token.decimals));
      var fee = (getTokenAmountBigInt(
                  (poolTransaction.fee *
                          pow(10,
                              widget.arguments.account.token.decimals - 3)) /
                      pow(10, widget.arguments.account.token.decimals),
                  widget.arguments.account.token.decimals)
              .toDouble() /
          pow(10, widget.arguments.account.token.decimals));
      resultValue = resultValue - amount - fee;
    });

    //result += (resultValue / pow(10, 18)).toStringAsFixed(2);
    result = NumberFormat.currency(locale: locale, symbol: symbol)
        .format(resultValue / pow(10, widget.arguments.account.token.decimals));
    return result;
  }*/

  //widget that builds the list
  Widget _buildTransactionsList() {
    if (_isLoading && transactions.isEmpty) {
      return Container(
        color: HermezColors.light,
        child: Center(
          child: CircularProgressIndicator(color: HermezColors.primary),
        ),
      );
    } else if (!_isLoading &&
        transactions.isEmpty &&
        pendingExits.isEmpty &&
        filteredExits.isEmpty &&
        pendingWithdraws.isEmpty) {
      return Container(
          width: double.infinity,
          color: HermezColors.light,
          padding: const EdgeInsets.all(34.0),
          child: Text(
            'Account transactions will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: HermezColors.neutral,
              fontSize: 16,
              fontFamily: 'ModernEra',
              fontWeight: FontWeight.w500,
            ),
          ));
    } else {
      return Container(
        color: HermezColors.light,
        child: RefreshIndicator(
          color: HermezColors.primary,
          child: ListView.builder(
              controller: _controller,
              // ???
              shrinkWrap: true,
              // To make listView scrollable
              // even if there is only a single item.
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: transactions.length +
                  pendingExits.length +
                  pendingForceExits.length +
                  filteredExits.length +
                  pendingWithdraws.length +
                  (_isLoading ? 1 : 0),
              //set the item count so that index won't be out of range
              padding: const EdgeInsets.all(16.0),
              //add some padding to make it look good
              itemBuilder: (context, i) {
                if ((pendingExits.length > 0 || pendingForceExits.length > 0) &&
                    i < pendingExits.length + pendingForceExits.length) {
                  var index = i;
                  Exit exit;
                  if (i >= pendingExits.length) {
                    index = i - pendingExits.length;
                    var transaction = pendingForceExits[index];
                    exit = Exit.fromL1Transaction(transaction);
                  } else {
                    final PoolTransaction transaction = pendingExits[index];
                    exit = Exit.fromTransaction(transaction);
                  }

                  final String currency = widget
                      .arguments.store.state.defaultCurrency
                      .toString()
                      .split('.')
                      .last;

                  return WithdrawalRow(
                      exit,
                      1,
                      currency,
                      widget.arguments.store.state.exchangeRatio,
                      (bool completeDelayedWithdraw,
                          bool isInstantWithdraw) async {},
                      widget.arguments.store.state.txLevel,
                      _stateResponse);
                } // final index = i ~/ 2; //get the actual index excluding dividers.
                else if (filteredExits.length > 0 &&
                    i <
                        filteredExits.length +
                            pendingExits.length +
                            pendingForceExits.length) {
                  final index =
                      i - pendingExits.length - pendingForceExits.length;
                  final Exit exit = filteredExits[index];
                  final bool isAllowed = allowedInstantWithdraws[index];

                  final String currency = widget
                      .arguments.store.state.defaultCurrency
                      .toString()
                      .split('.')
                      .last;

                  return WithdrawalRow(exit, 2, currency,
                      widget.arguments.store.state.exchangeRatio,
                      (bool completeDelayedWithdraw,
                          bool isInstantWithdraw) async {
                    BigInt gasPrice = BigInt.one;
                    GasPriceResponse gasPriceResponse =
                        await widget.arguments.store.getGasPrice();
                    switch (widget.arguments.store.state.defaultFee) {
                      case WalletDefaultFee.SLOW:
                        int gasPriceFloor =
                            gasPriceResponse.safeLow * pow(10, 8);
                        gasPrice = BigInt.from(gasPriceFloor);
                        break;
                      case WalletDefaultFee.AVERAGE:
                        int gasPriceFloor =
                            gasPriceResponse.average * pow(10, 8);
                        gasPrice = BigInt.from(gasPriceFloor);
                        break;
                      case WalletDefaultFee.FAST:
                        int gasPriceFloor = gasPriceResponse.fast * pow(10, 8);
                        gasPrice = BigInt.from(gasPriceFloor);
                        break;
                    }
                    String addressFrom = exit.hezEthereumAddress;
                    String addressTo =
                        getCurrentEnvironment().contracts[ContractName.hermez];
                    BigInt gasLimit = BigInt.from(GAS_LIMIT_HIGH);
                    final amountWithdraw = double.parse(exit.balance);
                    gasLimit = await widget.arguments.store.withdrawGasLimit(
                        amountWithdraw,
                        null,
                        exit,
                        completeDelayedWithdraw,
                        isInstantWithdraw);

                    var results = await Navigator.of(
                            widget.arguments.parentContext)
                        .pushNamed("/transaction_details",
                            arguments: TransactionDetailsArguments(
                                store: widget.arguments.store,
                                transactionType: TransactionType.WITHDRAW,
                                transactionLevel: TransactionLevel.LEVEL1,
                                status: TransactionStatus.DRAFT,
                                token: exit.token,
                                exit: exit,
                                amount: amountWithdraw.toDouble() /
                                    pow(10, exit.token.decimals),
                                addressFrom: addressFrom,
                                addressTo: addressTo,
                                gasLimit: gasLimit.toInt(),
                                gasPrice: gasPrice.toInt(),
                                completeDelayedWithdrawal:
                                    completeDelayedWithdraw,
                                instantWithdrawal: isInstantWithdraw));
                    if (results is PopWithResults) {
                      PopWithResults popResult = results;
                      if (popResult.toPage == "/home") {
                        _onRefresh();
                      } else {
                        Navigator.of(context).pop(results);
                      }
                    }
                  }, widget.arguments.store.state.txLevel, _stateResponse,
                      instantWithdrawAllowed: isAllowed,
                      completeDelayedWithdraw: false);
                } else if (pendingWithdraws.length > 0 &&
                    i <
                        pendingWithdraws.length +
                            filteredExits.length +
                            pendingExits.length +
                            pendingForceExits.length) {
                  final index = i -
                      filteredExits.length -
                      pendingExits.length -
                      pendingForceExits.length;
                  final pendingWithdraw = pendingWithdraws[index];
                  final Token token = Token.fromJson(pendingWithdraw['token']);

                  final Exit exit = filteredExits.firstWhere(
                      (exit) => exit.itemId == pendingWithdraw['itemId'],
                      orElse: () => Exit(
                          hezEthereumAddress:
                              pendingWithdraw['hermezEthereumAddress'],
                          delayedWithdrawRequest:
                              pendingWithdraw['instant'] == false
                                  ? pendingWithdraw['blockNum']
                                  : null,
                          token: token,
                          balance: pendingWithdraw['amount']
                              .toString()
                              .replaceAll('.0', '')));

                  final bool isAllowed = pendingWithdraw['instant'];

                  if (isAllowed == false) {
                    if (exit.delayedWithdrawRequest == null) {
                      exit.delayedWithdrawRequest = pendingWithdraw['blockNum'];
                    }
                    exit.balance = pendingWithdraw['amount']
                        .toString()
                        .replaceAll('.0', '');
                  }

                  final String currency = widget
                      .arguments.store.state.defaultCurrency
                      .toString()
                      .split('.')
                      .last;

                  int step = 2;
                  if ((isAllowed == true &&
                          pendingWithdraw['status'] == 'pending') ||
                      (isAllowed == false &&
                          pendingWithdraw['status'] == 'completed')) {
                    step = 3;
                  } else if (pendingWithdraw['status'] == 'fail') {
                    step = 2;
                  }

                  return WithdrawalRow(
                    exit,
                    step,
                    currency,
                    widget.arguments.store.state.exchangeRatio,
                    step == 2
                        ? (bool completeDelayedWithdraw,
                            bool instantWithdrawAllowed) async {
                            BigInt gasPrice = BigInt.one;
                            GasPriceResponse gasPriceResponse =
                                await widget.arguments.store.getGasPrice();
                            switch (widget.arguments.store.state.defaultFee) {
                              case WalletDefaultFee.SLOW:
                                int gasPriceFloor =
                                    gasPriceResponse.safeLow * pow(10, 8);
                                gasPrice = BigInt.from(gasPriceFloor);
                                break;
                              case WalletDefaultFee.AVERAGE:
                                int gasPriceFloor =
                                    gasPriceResponse.average * pow(10, 8);
                                gasPrice = BigInt.from(gasPriceFloor);
                                break;
                              case WalletDefaultFee.FAST:
                                int gasPriceFloor =
                                    gasPriceResponse.fast * pow(10, 8);
                                gasPrice = BigInt.from(gasPriceFloor);
                                break;
                            }

                            String addressFrom = exit.hezEthereumAddress;
                            String addressTo = getCurrentEnvironment()
                                .contracts[ContractName.hermez];
                            final amountWithdraw = double.parse(exit.balance);
                            BigInt gasLimit = BigInt.from(GAS_LIMIT_HIGH);
                            try {
                              gasLimit = await widget.arguments.store
                                  .withdrawGasLimit(
                                      amountWithdraw,
                                      null,
                                      exit,
                                      completeDelayedWithdraw,
                                      instantWithdrawAllowed);
                            } catch (e) {
                              // default withdraw gas: 230K + STANDARD ERC20 TRANFER + (siblings.lenght * 31K)
                              gasLimit =
                                  BigInt.from(GAS_LIMIT_WITHDRAW_DEFAULT);
                              exit.merkleProof.siblings.forEach((element) {
                                gasLimit +=
                                    BigInt.from(GAS_LIMIT_WITHDRAW_SIBLING);
                              });
                              if (exit.token.id != 0) {
                                gasLimit +=
                                    BigInt.from(GAS_LIMIT_WITHDRAW_ERC20_TX);
                              }
                            }

                            var results = await Navigator.of(
                                    widget.arguments.parentContext)
                                .pushNamed("/transaction_details",
                                    arguments: TransactionDetailsArguments(
                                        store: widget.arguments.store,
                                        transactionType:
                                            TransactionType.WITHDRAW,
                                        transactionLevel:
                                            TransactionLevel.LEVEL1,
                                        status: TransactionStatus.DRAFT,
                                        token: exit.token,
                                        exit: exit,
                                        amount: amountWithdraw.toDouble() /
                                            pow(10, exit.token.decimals),
                                        addressFrom: addressFrom,
                                        addressTo: addressTo,
                                        gasLimit: gasLimit.toInt(),
                                        gasPrice: gasPrice.toInt(),
                                        instantWithdrawal:
                                            instantWithdrawAllowed,
                                        completeDelayedWithdrawal:
                                            completeDelayedWithdraw));
                            if (results is PopWithResults) {
                              PopWithResults popResult = results;
                              if (popResult.toPage == "/home") {
                                // TODO do stuff
                                _onRefresh();
                              } else {
                                Navigator.of(context).pop(results);
                              }
                            }
                          }
                        : (bool completeDelayedWithdraw,
                            bool instantWithdrawAllowed) {},
                    widget.arguments.store.state.txLevel,
                    _stateResponse,
                    retry: pendingWithdraw['status'] == 'fail',
                    instantWithdrawAllowed: isAllowed == true,
                    completeDelayedWithdraw: isAllowed == false,
                  );
                } else if (pendingExits.length +
                        pendingForceExits.length +
                        filteredExits.length +
                        pendingWithdraws.length +
                        transactions.length ==
                    i) {
                  return Center(
                    child:
                        CircularProgressIndicator(color: HermezColors.primary),
                  );
                } else {
                  Color statusColor = HermezColors.warning;
                  Color statusBackgroundColor = HermezColors.warningBackground;
                  var title = "";
                  var subtitle = "";
                  final index = i -
                      pendingExits.length -
                      pendingForceExits.length -
                      filteredExits.length -
                      pendingWithdraws.length;
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
                  var feeValue = '0';
                  var fee = 0.0;
                  var amount;
                  if (element.runtimeType == ForgedTransaction) {
                    ForgedTransaction transaction = element;
                    if (transaction.id != null) {
                      txId = transaction.id;
                    }
                    if (transaction.hash != null) {
                      txHash = transaction.hash;
                    }

                    if (transaction.type == "CreateAccountDeposit" ||
                        transaction.type == "Deposit" ||
                        transaction.type == "DEPOSIT") {
                      type = "DEPOSIT";
                      value = transaction.l1info.depositAmount.toString();
                      if (transaction.l1info.depositAmountSuccess == true) {
                        status = "CONFIRMED";
                        final formatter = DateFormat(
                            "yyyy-MM-ddThh:mm:ssZ"); // "2021-03-18T10:42:01Z"
                        final DateTime dateTimeFromStr =
                            formatter.parse(transaction.timestamp, true);
                        timestamp = dateTimeFromStr.millisecondsSinceEpoch;
                      } else if (transaction.timestamp.isNotEmpty) {
                        final formatter = DateFormat(
                            "yyyy-MM-ddThh:mm:ssZ"); // "2021-03-24T15:42:544802"
                        final DateTime dateTimeFromStr =
                            formatter.parse(transaction.timestamp, true);
                        timestamp = dateTimeFromStr.millisecondsSinceEpoch;
                      }
                      addressFrom = getEthereumAddress(
                          transaction.fromHezEthereumAddress);
                      addressTo = transaction.fromHezEthereumAddress;
                    } else if (transaction.type == "Exit" ||
                        transaction.type == "ForceExit") {
                      type = transaction.type.toUpperCase();
                      value = transaction.amount.toString();
                      if (transaction.timestamp.isNotEmpty) {
                        status = "CONFIRMED";
                        final formatter = DateFormat(
                            "yyyy-MM-ddThh:mm:ssZ"); // "2021-03-18T10:42:01Z"
                        final DateTime dateTimeFromStr =
                            formatter.parse(transaction.timestamp, true);
                        timestamp = dateTimeFromStr.millisecondsSinceEpoch;
                      }
                      addressFrom = transaction.fromHezEthereumAddress;
                      addressTo = getEthereumAddress(
                          transaction.fromHezEthereumAddress);
                    } else if (transaction.type == "Transfer" ||
                        transaction.type == "TransferToEthAddr") {
                      value = transaction.amount.toString();
                      /*if (transaction.L1orL2 == 'L1') {
                        if (transaction.fromHezEthereumAddress.toLowerCase() ==
                            widget.arguments.store.state.ethereumAddress
                                .toLowerCase()) {
                          type = "SEND";
                        } else if (transaction.toHezEthereumAddress
                                .toLowerCase() ==
                            widget.arguments.store.state.ethereumAddress
                                .toLowerCase()) {}
                      } else {*/
                      if ((transaction.fromAccountIndex != null &&
                              transaction.fromAccountIndex ==
                                  widget.arguments.account.accountIndex) ||
                          (transaction.fromHezEthereumAddress != null &&
                              transaction.fromHezEthereumAddress
                                      .toLowerCase() ==
                                  widget.arguments.store.state.ethereumAddress
                                      .toLowerCase())) {
                        type = "SEND";
                        if (transaction.batchNum != null) {
                          status = "CONFIRMED";
                          final formatter = DateFormat(
                              "yyyy-MM-ddThh:mm:ssZ"); // "2021-03-18T10:42:01Z"
                          final DateTime dateTimeFromStr =
                              formatter.parse(transaction.timestamp, true);
                          timestamp = dateTimeFromStr.millisecondsSinceEpoch;
                        } else if (transaction.timestamp.isNotEmpty) {
                          final formatter = DateFormat(
                              "yyyy-MM-ddThh:mm:ss"); // "2021-03-24T15:42:544802"
                          final DateTime dateTimeFromStr =
                              formatter.parse(transaction.timestamp, true);
                          timestamp = dateTimeFromStr.millisecondsSinceEpoch;
                        }
                        addressFrom = transaction.fromHezEthereumAddress;
                        addressTo = transaction.toHezEthereumAddress;
                      } else if ((transaction.toAccountIndex != null &&
                              transaction.toAccountIndex ==
                                  widget.arguments.account.accountIndex) ||
                          (transaction.toHezEthereumAddress != null &&
                              transaction.toHezEthereumAddress.toLowerCase() ==
                                  widget.arguments.store.state.ethereumAddress
                                      .toLowerCase())) {
                        type = "RECEIVE";
                        if (transaction.timestamp.isNotEmpty) {
                          status = "CONFIRMED";
                          final formatter = DateFormat(
                              "yyyy-MM-ddThh:mm:ssZ"); // "2021-03-18T10:42:01Z"
                          final DateTime dateTimeFromStr =
                              formatter.parse(transaction.timestamp, true);
                          timestamp = dateTimeFromStr.millisecondsSinceEpoch;
                        }
                        addressFrom = transaction.fromHezEthereumAddress;
                        addressTo = transaction.toHezEthereumAddress;
                      }
                    }
                    amount = double.parse(value) /
                        pow(10, widget.arguments.account.token.decimals);
                    if (transaction.L1orL2 == "L2") {
                      feeValue = getFeeValue(
                              transaction.l2info.fee, double.parse(value))
                          .toInt()
                          .toString();
                    }
                    fee = double.parse(feeValue);
                  } else {
                    LinkedHashMap event = element;
                    type = event['type'];
                    status = event['status'];
                    timestamp = event['timestamp'];
                    txHash = event['txHash'];
                    addressFrom = event['from'];
                    addressTo = event['to'];
                    value = event['value'];
                    feeValue = event['fee'];
                    if (feeValue == null) {
                      feeValue = '0';
                    }
                    amount = double.parse(value) /
                        pow(10, widget.arguments.account.token.decimals);
                    fee = double.parse(feeValue);
                  }

                  final String currency = widget
                      .arguments.store.state.defaultCurrency
                      .toString()
                      .split('.')
                      .last;

                  String symbol = "";
                  if (currency == "EUR") {
                    symbol = "€";
                  } else if (currency == "CNY") {
                    symbol = "\¥";
                  } else if (currency == "JPY") {
                    symbol = "\¥";
                  } else if (currency == "GBP") {
                    symbol = "\£";
                  } else {
                    symbol = "\$";
                  }

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
                    case 'EXIT':
                      txType = TransactionType.EXIT;
                      title = "Moved";
                      icon = "assets/tx_move.png";
                      isNegative = widget.arguments.store.state.txLevel ==
                          TransactionLevel.LEVEL2;
                      break;
                    case 'FORCEEXIT':
                      txType = TransactionType.FORCEEXIT;
                      title = "Moved";
                      icon = "assets/tx_move.png";
                      isNegative = widget.arguments.store.state.txLevel ==
                          TransactionLevel.LEVEL2;
                      break;
                    case "WITHDRAW":
                      txType = TransactionType.WITHDRAW;
                      title = "Moved";
                      icon = "assets/tx_move.png";
                      isNegative = widget.arguments.store.state.txLevel ==
                          TransactionLevel.LEVEL2;
                      break;
                    case "DEPOSIT":
                      txType = TransactionType.DEPOSIT;
                      title = "Moved";
                      icon = "assets/tx_move.png";
                      isNegative = widget.arguments.store.state.txLevel ==
                          TransactionLevel.LEVEL1;
                      break;
                  }

                  TransactionStatus txStatus = TransactionStatus.CONFIRMED;
                  if (status == "CONFIRMED") {
                    subtitle = format.format(date);
                    txStatus = TransactionStatus.CONFIRMED;
                  } else if (status == "INVALID") {
                    subtitle = "Invalid";
                    statusColor = HermezColors.error;
                    statusBackgroundColor = HermezColors.error;
                    txStatus = TransactionStatus.INVALID;
                  } else {
                    subtitle = "Pending";
                    txStatus = TransactionStatus.PENDING;
                  }

                  return Container(
                    child: ListTile(
                      leading: _getLeadingWidget(icon, null),
                      title: Container(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          title,
                          maxLines: 1,
                          style: TextStyle(
                            color: HermezColors.dark,
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
                                    child: Text(subtitle,
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
                                  color: HermezColors.neutral,
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
                                EthAmountFormatter.formatAmount(amount,
                                    widget.arguments.account.token.symbol),
                                style: TextStyle(
                                  color: HermezColors.dark,
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
                                (isNegative ? "- " : "") +
                                    EthAmountFormatter.formatAmount(
                                        (amount *
                                            widget.arguments.account.token.USD *
                                            (currency != 'USD'
                                                ? widget.arguments.store.state
                                                    .exchangeRatio
                                                : 1)),
                                        currency),
                                style: TextStyle(
                                  color: isNegative
                                      ? HermezColors.neutral
                                      : HermezColors.success,
                                  fontSize: 16,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ]),
                      onTap: () async {
                        var results = await Navigator.pushNamed(
                            context, "transaction_details",
                            arguments: TransactionDetailsArguments(
                                store: widget.arguments.store,
                                transactionType: txType,
                                transactionLevel:
                                    widget.arguments.store.state.txLevel,
                                status: txStatus,
                                account: widget.arguments.account,
                                token: widget.arguments.account.token,
                                amount: amount,
                                fee: fee,
                                transactionId: txId,
                                transactionHash: txHash,
                                addressFrom: addressFrom,
                                addressTo: addressTo,
                                transactionDate: date));
                        if (results is PopWithResults) {
                          PopWithResults popResult = results;
                          if (popResult.toPage == "/home") {
                            // TODO do stuff
                            _onRefresh();
                          } else {
                            Navigator.of(context).pop(results);
                          }
                        }
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
    _stateResponse = await getState();
    if (_needRefresh) {
      await widget.arguments.store.getAccounts();
    }
    if (widget.arguments.store.state.txLevel == TransactionLevel.LEVEL2) {
      pendingTransfers =
          await fetchL2PendingTransfers(widget.arguments.account.accountIndex);
      final List<ForgedTransaction> pendingTransfersTxs =
          pendingTransfers.map((poolTransaction) {
        final formatter = DateFormat("yyyy-MM-ddThh:mm:ssZ");
        DateTime date = formatter.parse(poolTransaction.timestamp, true);
        String timestamp = date.toString().replaceFirst(" ", "T") + "Z";
        return ForgedTransaction(
            id: poolTransaction.id,
            amount: poolTransaction.amount,
            type: poolTransaction.type,
            L1orL2: "L2",
            l2info: L2Info(fee: poolTransaction.fee),
            fromHezEthereumAddress: poolTransaction.fromHezEthereumAddress,
            fromAccountIndex: poolTransaction.fromAccountIndex,
            toAccountIndex: poolTransaction.toAccountIndex,
            toHezEthereumAddress: poolTransaction.toHezEthereumAddress,
            timestamp: timestamp);
      }).toList();
      pendingExits =
          await fetchL2PendingExits(widget.arguments.account.accountIndex);
      exits = fetchExits(widget.arguments.account.token.id);
      pendingForceExits = await fetchPendingForceExits(
          widget.arguments.account.token.id, exits, pendingExits);
      pendingWithdraws =
          await fetchPendingWithdraws(widget.arguments.account.token.id);
      filteredExits = List.from(exits);
      filteredExits.removeWhere((Exit exit) {
        for (dynamic pendingWithdraw in pendingWithdraws) {
          if (pendingWithdraw["id"] ==
                  (exit.accountIndex + exit.batchNum.toString()) ||
              (pendingWithdraw['instant'] == false &&
                  exit.delayedWithdrawRequest != null &&
                  Token.fromJson(pendingWithdraw['token']).id ==
                      exit.token.id)) {
            return true;
          }
        }
        return false;
      });
      allowedInstantWithdraws = [];
      for (int i = 0; i < filteredExits.length; i++) {
        Exit exit = filteredExits[i];
        bool isAllowed = await widget.arguments.store
            .isInstantWithdrawalAllowed(double.parse(exit.balance), exit.token);
        allowedInstantWithdraws.add(isAllowed);
      }
      pendingDeposits =
          await fetchPendingDeposits(widget.arguments.account.token.id);
      final List<ForgedTransaction> pendingDepositsTxs =
          pendingDeposits.map((pendingDeposit) {
        DateTime date = DateTime.fromMillisecondsSinceEpoch(
            pendingDeposit['timestamp'],
            isUtc: true);
        String timestamp = date.toString().replaceFirst(" ", "T") + "Z";
        return ForgedTransaction(
            id: pendingDeposit['id'],
            hash: pendingDeposit['txHash'],
            l1info: L1Info(depositAmount: pendingDeposit['value']),
            type: pendingDeposit['type'],
            fromHezEthereumAddress: pendingDeposit['from'],
            timestamp: timestamp);
      }).toList();
      if (transactions.isEmpty) {
        transactions.addAll(pendingTransfersTxs);
        transactions.addAll(pendingDepositsTxs);
      }
      historyTransactions = await fetchHistoryTransactions();
      final filteredTransactions = filterExitsFromHistoryTransactions(
        historyTransactions,
        exits,
      );
      widget.arguments.account = await fetchAccount();
      setState(() {
        pendingItems = pendingItems;
        fromItem = filteredTransactions.last.itemId;
        transactions.addAll(filteredTransactions);
        transactions.sort((a, b) {
          final formatter =
              DateFormat("yyyy-MM-ddThh:mm:ssZ"); // "2021-03-18T10:42:01Z"
          final DateTime dateTime1FromStr = formatter.parse(a.timestamp);
          final DateTime dateTime2FromStr = formatter.parse(b.timestamp);

          return dateTime2FromStr.compareTo(dateTime1FromStr);
        });
        _isLoading = false;
      });
    } else {
      pendingTransfers =
          await fetchPendingTransfers(widget.arguments.account.token.id);
      pendingExits =
          fetchL2PendingExitsByTokenId(widget.arguments.account.token.id);
      exits = fetchExits(widget.arguments.account.token.id);
      pendingForceExits = await fetchPendingForceExits(
          widget.arguments.account.token.id, exits, pendingExits);
      filteredExits = exits.toList();
      pendingWithdraws =
          await fetchPendingWithdraws(widget.arguments.account.token.id);
      filteredExits.removeWhere((Exit exit) {
        for (dynamic pendingWithdraw in pendingWithdraws) {
          if (pendingWithdraw["id"] ==
                  (exit.accountIndex + exit.batchNum.toString()) ||
              (pendingWithdraw['instant'] == false &&
                  exit.delayedWithdrawRequest != null &&
                  Token.fromJson(pendingWithdraw['token']).id ==
                      exit.token.id)) {
            return true;
          }
        }
        return false;
      });
      allowedInstantWithdraws = [];
      for (int i = 0; i < filteredExits.length; i++) {
        Exit exit = filteredExits[i];
        bool isAllowed = await widget.arguments.store
            .isInstantWithdrawalAllowed(double.parse(exit.balance), exit.token);
        allowedInstantWithdraws.add(isAllowed);
      }
      pendingDeposits =
          await fetchPendingDeposits(widget.arguments.account.token.id);
      historyTransactions = await fetchHistoryTransactions();
      List<dynamic> fullTxs = List.from(historyTransactions);
      if (transactions.isEmpty) {
        for (dynamic pendingDeposit in pendingDeposits) {
          fullTxs.removeWhere(
              (element) => element['txHash'] == pendingDeposit['txHash']);
          transactions.add(pendingDeposit);
        }
        for (dynamic pendingTransfer in pendingTransfers) {
          fullTxs.firstWhere(
              (element) => element['txHash'] == pendingTransfer['txHash'],
              orElse: () => transactions.add(pendingTransfer));
        }
      }
      widget.arguments.account = await fetchAccount();
      setState(() {
        pendingItems = 0;
        transactions.addAll(fullTxs);
        transactions.sort((a, b) {
          DateTime dateTime1FromStr;
          DateTime dateTime2FromStr;
          final formatter =
              DateFormat("yyyy-MM-ddThh:mm:ssZ"); // "2021-03-18T10:42:01Z"
          dateTime1FromStr =
              DateTime.fromMillisecondsSinceEpoch(a['timestamp']);
          dateTime2FromStr =
              DateTime.fromMillisecondsSinceEpoch(b['timestamp']);
          return dateTime2FromStr.compareTo(dateTime1FromStr);
        });
        _isLoading = false;
      });
    }
  }

  void fetchState() {
    widget.arguments.store.getState();
  }

  Future<Account> fetchAccount() {
    if (widget.arguments.store.state.txLevel == TransactionLevel.LEVEL2) {
      return widget.arguments.store
          .getAccount(widget.arguments.account.accountIndex);
    } else {
      return widget.arguments.store
          .getL1Account(widget.arguments.account.token.id);
    }
  }

  Future<List<PoolTransaction>> fetchL2PendingTransfers(
      String accountIndex) async {
    List<PoolTransaction> poolTxs =
        List.from(widget.arguments.store.state.pendingL2Txs);
    poolTxs.removeWhere((transaction) =>
        transaction.type == 'Exit' ||
        transaction.fromAccountIndex != accountIndex);
    return poolTxs;
  }

  Future<List<PoolTransaction>> fetchL2PendingExits(String accountIndex) async {
    List<PoolTransaction> poolTxs =
        List.from(widget.arguments.store.state.pendingL2Txs);
    poolTxs.removeWhere((transaction) =>
        transaction.type != 'Exit' ||
        transaction.fromAccountIndex != accountIndex);
    return poolTxs;
  }

  List<PoolTransaction> fetchL2PendingExitsByTokenId(int tokenId) {
    List<PoolTransaction> poolTxs =
        List.from(widget.arguments.store.state.pendingL2Txs);
    poolTxs.removeWhere((transaction) =>
        transaction.type != 'Exit' || transaction.token.id != tokenId);
    return poolTxs;
  }

  Future<List<dynamic>> fetchPendingForceExits(
      int tokenId, List<Exit> exits, List<PoolTransaction> pendingExits) async {
    final accountPendingForceExits = List.from(widget
        .arguments.store.state.pendingForceExits); //getPendingForceExits();
    accountPendingForceExits.removeWhere((pendingForceExit) =>
        Token.fromJson(pendingForceExit['token']).id != tokenId);

    /*exits.forEach((exit) {
      var pendingExit = pendingExits.firstWhere(
          (pendingExit) => pendingExit.fromAccountIndex == exit.accountIndex,
          orElse: () => null);
      if (pendingExit == null) {
        var pendingForceExit = accountPendingForceExits.firstWhere(
            (pendingForceExit) =>
                pendingForceExit['amount'].toString() == exit.balance,
            orElse: null);
        if (pendingForceExit != null) {
          accountPendingForceExits.remove(pendingForceExit);
        }
      }
    });*/

    return accountPendingForceExits;
  }

  Future<List<dynamic>> fetchPendingDeposits(int tokenId) async {
    final accountPendingDeposits =
        List.from(widget.arguments.store.state.pendingDeposits);
    accountPendingDeposits.removeWhere((pendingDeposit) =>
        Token.fromJson(pendingDeposit['token']).id != tokenId);
    return accountPendingDeposits;
  }

  Future<List<dynamic>> fetchPendingTransfers(int tokenId) async {
    final accountPendingTransfers =
        List.from(widget.arguments.store.state.pendingL1Transfers);
    accountPendingTransfers.removeWhere((pendingTransfer) =>
        Token.fromJson(pendingTransfer['token']).id != tokenId);
    return accountPendingTransfers;
  }

  List<Exit> fetchExits(int tokenId) {
    List<Exit> exits = List.from(widget.arguments.store.state.exits);
    exits.removeWhere((exit) => exit.token.id != tokenId);
    return exits;
  }

  Future<List<dynamic>> fetchPendingWithdraws(int tokenId) async {
    final accountPendingWithdraws =
        List.from(widget.arguments.store.state.pendingWithdraws);
    accountPendingWithdraws.removeWhere((pendingWithdraw) =>
        Token.fromJson(pendingWithdraw['token']).id != tokenId);
    return accountPendingWithdraws;
  }

  Future<List<dynamic>> fetchHistoryTransactions() async {
    if (widget.arguments.store.state.txLevel == TransactionLevel.LEVEL1) {
      return await widget.arguments.store.getEthereumTransactionsByAddress(
          widget.arguments.store.state.ethereumAddress,
          widget.arguments.account.token,
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

  Future<StateResponse> getState() async {
    return await widget.arguments.store.getState();
  }

  /*Future<Account> getEthereumAccount() async {
    Account ethereumAccount = await widget.arguments.store.getL1Account(0);
    return ethereumAccount;
  }*/

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // takes in an object and color and returns a circle avatar with first letter and required color
  CircleAvatar _getLeadingWidget(String icon, Color color) {
    return new CircleAvatar(
        radius: 23, backgroundColor: color, child: Image.asset(icon));
  }
}
