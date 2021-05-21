import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hermez/components/wallet/account_row.dart';
import 'package:hermez/components/wallet/withdrawal_row.dart';
import 'package:hermez/constants.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/model/wallet.dart';
import 'package:hermez/screens/qrcode.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez/service/network/model/gas_price_response.dart';
import 'package:hermez/utils/address_utils.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_plugin/addresses.dart';
import 'package:hermez_plugin/constants.dart';
import 'package:hermez_plugin/environment.dart';
import 'package:hermez_plugin/model/account.dart';
import 'package:hermez_plugin/model/exit.dart';
import 'package:hermez_plugin/model/pool_transaction.dart';
import 'package:hermez_plugin/model/token.dart';
import 'package:hermez_plugin/utils.dart';
import 'package:intl/intl.dart';

import 'account_details.dart';
import 'transaction_details.dart';

class WalletDetailsArguments {
  final WalletHandler store;
  final TransactionLevel transactionLevel;
  final BuildContext parentContext;

  WalletDetailsArguments(this.store, this.transactionLevel, this.parentContext);
}

class WalletDetailsPage extends StatefulWidget {
  WalletDetailsPage({Key key, this.arguments}) : super(key: key);

  final WalletDetailsArguments arguments;

  @override
  _WalletDetailsPageState createState() => _WalletDetailsPageState();
}

class _WalletDetailsPageState extends State<WalletDetailsPage> {
  List<Account> _accounts;
  List<Exit> _exits = [];
  List<Exit> _filteredExits = [];
  List<dynamic> _poolTxs = [];
  List<dynamic> _pendingWithdraws = [];
  List<dynamic> _pendingDeposits = [];

  @override
  void initState() {
    //fetchAccounts();
    super.initState();
  }

  Future<void> _onRefresh() async {
    setState(() {});
  }

  Future<List<Account>> fetchAccounts() async {
    fetchPendingTransactions();
    if (widget.arguments.store.state.txLevel == TransactionLevel.LEVEL2) {
      /*const accountPendingDeposits = storage.getItemsByHermezAddress(
          pendingDeposits,
          ethereumNetworkTask.data.chainId,
          wallet.hermezEthereumAddress
      )*/

      /*
      const pendingOnTopDeposits = accountPendingDeposits
          .filter(deposit => deposit.type === TxType.Deposit)
      const pendingCreateAccountDeposits = accountPendingDeposits
          .filter(deposit => deposit.type === TxType.CreateAccountDeposit)*/
      _pendingDeposits = await fetchPendingDeposits();
      return widget.arguments.store.getAccounts();
    } else {
      return widget.arguments.store.getL1Accounts(true);
    }
  }

  void fetchPendingTransactions() async {
    try {
      _poolTxs = await fetchPendingExits();
    } catch (e) {}
    _exits = await fetchExits();
    _filteredExits = _exits.toList();
    _pendingWithdraws = await fetchPendingWithdraws();
    _filteredExits.removeWhere((Exit exit) {
      for (dynamic pendingWithdraw in _pendingWithdraws) {
        if (pendingWithdraw["id"] ==
            (exit.accountIndex + exit.batchNum.toString())) {
          return true;
        }
      }
      return false;
    });
    /*const accountPendingDelayedWithdraws = storage.getItemsByHermezAddress(
          pendingDelayedWithdraws,
          ethereumNetworkTask.data.chainId,
          wallet.hermezEthereumAddress
      )*/
  }

  Future<List<dynamic>> fetchPendingExits() async {
    List<PoolTransaction> poolTxs =
        await widget.arguments.store.getPoolTransactions();
    poolTxs.removeWhere((transaction) => transaction.type != 'Exit');
    return poolTxs;
  }

  Future<List<Exit>> fetchExits() {
    return widget.arguments.store.getExits(); // TODO : only pending withdraws?
  }

  Future<List<dynamic>> fetchPendingWithdraws() {
    return widget.arguments.store.getPendingWithdraws();
  }

  Future<List<dynamic>> fetchPendingDeposits() {
    return widget.arguments.store.getPendingDeposits();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HermezColors.lightOrange,
      child: FutureBuilder(
        future: fetchAccounts(),
        builder: (buildContext, snapshot) {
          return Scaffold(
            body: NestedScrollView(
              body: handleAccountsList(snapshot),
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    snap: false,
                    collapsedHeight: kToolbarHeight,
                    expandedHeight: 340.0,
                    title: Container(
                      padding: EdgeInsets.all(20),
                      color: HermezColors.lightOrange,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'assets/' +
                                (widget.arguments.store.state.txLevel ==
                                        TransactionLevel.LEVEL1
                                    ? "ethereum_logo"
                                    : "hermez_logo") +
                                '.png',
                            width: 30,
                            height: 30,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          new Text(
                              widget.arguments.store.state.txLevel ==
                                      TransactionLevel.LEVEL1
                                  ? "Ethereum Wallet"
                                  : "Hermez Wallet",
                              style: TextStyle(
                                  fontFamily: 'ModernEra',
                                  color: HermezColors.blackTwo,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20)),
                          SizedBox(
                            width: 60,
                          ),
                        ],
                      ),
                    ),
                    centerTitle: true,
                    elevation: 0.0,
                    flexibleSpace: FlexibleSpaceBar(
                      // here the desired height*/
                      background: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).padding.top +
                                  kToolbarHeight +
                                  20),
                          Container(
                            margin: EdgeInsets.only(left: 40, right: 40),
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(56.0),
                                  side: BorderSide(
                                      color: HermezColors.mediumOrange)),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                    text:
                                        widget.arguments.store.state.txLevel ==
                                                TransactionLevel.LEVEL1
                                            ? widget.arguments.store.state
                                                .ethereumAddress
                                            : "hez:" +
                                                widget.arguments.store.state
                                                    .ethereumAddress));
                                Flushbar(
                                  messageText: Text(
                                    'Copied',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: HermezColors.blackTwo,
                                      fontSize: 16,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  boxShadows: [
                                    BoxShadow(
                                      color: HermezColors.blueyGreyTwo
                                          .withAlpha(64),
                                      offset: Offset(0, 4),
                                      blurRadius: 16,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                  borderColor:
                                      HermezColors.blueyGreyTwo.withAlpha(64),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                  backgroundColor: Colors.white,
                                  margin: EdgeInsets.all(16.0),
                                  duration: Duration(
                                      seconds: FLUSHBAR_AUTO_HIDE_DURATION),
                                ).show(context);
                              },
                              padding: EdgeInsets.only(
                                  left: 20.0,
                                  right: 10.0,
                                  top: 10.0,
                                  bottom: 10.0),
                              color: HermezColors.mediumOrange,
                              textColor: HermezColors.steel,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget != null && widget.arguments != null && widget.arguments.store.state.ethereumAddress != null
                                        ? (widget.arguments.store.state.txLevel == TransactionLevel.LEVEL1
                                            ? "0x" +
                                                    AddressUtils.strip0x(widget.arguments.store.state.ethereumAddress.substring(0, 6))
                                                        .toUpperCase() +
                                                    " ･･･ " +
                                                    widget.arguments.store.state
                                                        .ethereumAddress
                                                        .substring(
                                                            widget.arguments.store.state.ethereumAddress.length -
                                                                5,
                                                            widget
                                                                .arguments
                                                                .store
                                                                .state
                                                                .ethereumAddress
                                                                .length)
                                                        .toUpperCase() ??
                                                ""
                                            : "hez:" +
                                                    "0x" +
                                                    AddressUtils.strip0x(widget.arguments.store.state.ethereumAddress.substring(0, 6))
                                                        .toUpperCase() +
                                                    " ･･･ " +
                                                    widget.arguments.store.state
                                                        .ethereumAddress
                                                        .substring(widget.arguments.store.state.ethereumAddress.length - 5, widget.arguments.store.state.ethereumAddress.length)
                                                        .toUpperCase() ??
                                                "")
                                        : "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: HermezColors.steel,
                                      fontSize: 16,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        color: HermezColors.steel),
                                    padding: EdgeInsets.only(
                                        left: 12.0,
                                        right: 12.0,
                                        top: 4,
                                        bottom: 4),
                                    child: Text(
                                      widget.arguments.store.state.txLevel ==
                                              TransactionLevel.LEVEL1
                                          ? "L1"
                                          : "L2",
                                      style: TextStyle(
                                        color: HermezColors.mediumOrange,
                                        fontSize: 15,
                                        fontFamily: 'ModernEra',
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          SizedBox(
                              width: double.infinity,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(totalBalance(snapshot),
                                        style: TextStyle(
                                          color: HermezColors.black,
                                          fontSize: 32,
                                          fontFamily: 'ModernEra',
                                          fontWeight: FontWeight.w800,
                                        )),
                                  ])),
                          SizedBox(height: 16),
                          buildButtonsRow(context, snapshot),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                    backgroundColor: HermezColors.lightOrange,
                  ),
                ];
              },
            ),
          );
        },
      ),
    );
  }

  buildButtonsRow(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      // data loaded:
      _accounts = snapshot.data;
    }
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _accounts != null && _accounts.length > 0
              ? SizedBox(width: 20.0)
              : Container(),
          _accounts != null && _accounts.length > 0
              ? Expanded(
                  child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      onPressed: () async {
                        List<Account> accounts = _accounts
                            .takeWhile(
                                (account) => double.parse(account.balance) > 0)
                            .toList();
                        Account account;
                        if (accounts.length == 1) {
                          account = accounts[0];
                        }
                        Navigator.pushNamed(widget.arguments.parentContext,
                            "/transaction_amount",
                            arguments: TransactionAmountArguments(
                              widget.arguments.store,
                              widget.arguments.store.state.txLevel,
                              TransactionType.SEND,
                              account: account,
                            ));
                      },
                      padding: EdgeInsets.all(10.0),
                      color: Colors.transparent,
                      textColor: HermezColors.blackTwo,
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: 80,
                            height: 80,
                            child: SvgPicture.asset(
                              "assets/bt_send.svg",
                              fit: BoxFit.cover,
                            ),
                          ),
                          Text(
                            'Send',
                            style: TextStyle(
                              color: HermezColors.blackTwo,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      )),
                )
              : Container(),
          SizedBox(width: 20.0),
          Expanded(
            child:
                // takes in an object and color and returns a circle avatar with first letter and required color
                FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    onPressed: () {
                      if (widget.arguments.store.state.txLevel ==
                          TransactionLevel.LEVEL1) {
                        Navigator.of(widget.arguments.parentContext).pushNamed(
                          "/qrcode",
                          arguments: QRCodeArguments(
                              qrCodeType: QRCodeType.ETHEREUM,
                              code:
                                  widget.arguments.store.state.ethereumAddress,
                              store: widget.arguments.store,
                              isReceive: true),
                        );
                      } else {
                        Navigator.of(widget.arguments.parentContext).pushNamed(
                          "/qrcode",
                          arguments: QRCodeArguments(
                              qrCodeType: QRCodeType.HERMEZ,
                              code: getHermezAddress(
                                  widget.arguments.store.state.ethereumAddress),
                              store: widget.arguments.store,
                              isReceive: true),
                        );
                      }
                    },
                    padding: EdgeInsets.all(10.0),
                    color: Colors.transparent,
                    textColor: HermezColors.blackTwo,
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 80,
                          height: 80,
                          child: SvgPicture.asset(
                            "assets/bt_receive.svg",
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          'Receive',
                          style: TextStyle(
                            color: HermezColors.blackTwo,
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

  Widget handleAccountsList(AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    } else {
      if (snapshot.hasError) {
        // while data is loading:
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(34.0),
            child: Column(children: [
              Text(
                'There was an error loading \n\n this page.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: HermezColors.blueyGrey,
                  fontSize: 16,
                  fontFamily: 'ModernEra',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    padding: EdgeInsets.only(
                        left: 23, right: 23, bottom: 16, top: 16),
                    backgroundColor: Color(0xfff3f3f8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    _onRefresh();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset('assets/reload.svg',
                          color: HermezColors.blueyGreyTwo,
                          semanticsLabel: 'reload'),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Reload',
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
            ]));
      } else {
        if (snapshot.hasData && (snapshot.data as List).length > 0) {
          // data loaded:
          _accounts = snapshot.data;
          return Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: buildAccountsList(),
                ),
                SafeArea(
                  top: false,
                  bottom: true,
                  child: Container(
                    //height: kBottomNavigationBarHeight,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(34.0),
              child: Text(
                widget.arguments.store.state.txLevel == TransactionLevel.LEVEL1
                    ? 'Transfer tokens to your \n\n Ethereum wallet.'
                    : 'Transfer tokens to your \n\n Hermez wallet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: HermezColors.blueyGrey,
                  fontSize: 16,
                  fontFamily: 'ModernEra',
                  fontWeight: FontWeight.w500,
                ),
              ));
        }
      }
    }

    return buildAccountsList();
  }

  //widget that builds the list
  Widget buildAccountsList() {
    return Container(
      color: Colors.white,
      child: RefreshIndicator(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: (_poolTxs.isNotEmpty ||
                      _exits.isNotEmpty ||
                      _pendingWithdraws.isNotEmpty
                  ? 1
                  : 0) +
              _accounts.length,
          //set the item count so that index won't be out of range
          padding: const EdgeInsets.all(16.0),
          //add some padding to make it look good
          itemBuilder: (context, i) {
            //item builder returns a row for each index i=0,1,2,3,4
            // if (i.isOdd) return Divider(); //if index = 1,3,5 ... return a divider to make it visually appealing
            if (i == 0 && _poolTxs.length > 0 && i < _poolTxs.length) {
              final index = i;
              final PoolTransaction transaction = _poolTxs[index];

              final Exit exit = Exit.fromTransaction(transaction);

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
                  () async {},
                  widget.arguments.store.state.txLevel);
            } else if (i == 0 && _filteredExits.length > 0) {
              final index = i;
              final Exit exit = _filteredExits[index];

              final String currency = widget
                  .arguments.store.state.defaultCurrency
                  .toString()
                  .split('.')
                  .last;

              return WithdrawalRow(
                  exit, 2, currency, widget.arguments.store.state.exchangeRatio,
                  () async {
                BigInt gasPrice = BigInt.one;
                GasPriceResponse gasPriceResponse =
                    await widget.arguments.store.getGasPrice();
                switch (widget.arguments.store.state.defaultFee) {
                  case WalletDefaultFee.SLOW:
                    int gasPriceFloor = gasPriceResponse.safeLow * pow(10, 8);
                    gasPrice = BigInt.from(gasPriceFloor);
                    break;
                  case WalletDefaultFee.AVERAGE:
                    int gasPriceFloor = gasPriceResponse.average * pow(10, 8);
                    gasPrice = BigInt.from(gasPriceFloor);
                    break;
                  case WalletDefaultFee.FAST:
                    int gasPriceFloor = gasPriceResponse.fast * pow(10, 8);
                    gasPrice = BigInt.from(gasPriceFloor);
                    break;
                }
                String addressFrom = exit.hezEthereumAddress;
                String addressTo = getCurrentEnvironment().contracts['Hermez'];
                final amountWithdraw = getTokenAmountBigInt(
                    double.parse(exit.balance) / pow(10, exit.token.decimals),
                    exit.token.decimals);
                BigInt gasLimit = await widget.arguments.store
                    .withdrawGasLimit(amountWithdraw, null, exit, false, true);

                Navigator.of(widget.arguments.parentContext)
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
                          selectedFeeSpeed:
                              widget.arguments.store.state.defaultFee,
                          gasLimit: gasLimit.toInt(),
                          gasPrice: gasPrice.toInt(),
                        ))
                    .then((value) => _onRefresh());
              }, widget.arguments.store.state.txLevel);
            } else if (i == 0 && _pendingWithdraws.length > 0) {
              final index = i;
              final pendingWithdraw = _pendingWithdraws[index];
              final Token token =
                  Token.fromJson(_pendingWithdraws[index]['token']);

              final Exit exit = _exits.firstWhere(
                  (exit) => exit.itemId == pendingWithdraw['itemId'],
                  orElse: () => Exit(
                      hezEthereumAddress:
                          pendingWithdraw['hermezEthereumAddress'],
                      token: token,
                      balance: pendingWithdraw['amount']
                          .toString()
                          .replaceAll('.0', '')));

              final String currency = widget
                  .arguments.store.state.defaultCurrency
                  .toString()
                  .split('.')
                  .last;

              int step = 2;
              if (pendingWithdraw['status'] == 'pending') {
                step = 3;
              } else if (pendingWithdraw['status'] == 'fail') {
                step = 2;
              } else if (pendingWithdraw['status'] == 'initiated') {
                step = 1;
              }

              return WithdrawalRow(
                exit,
                step,
                currency,
                widget.arguments.store.state.exchangeRatio,
                step == 2
                    ? () async {
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
                        String addressTo =
                            getCurrentEnvironment().contracts['Hermez'];

                        BigInt gasLimit = BigInt.from(GAS_LIMIT_HIGH);
                        try {
                          final amountWithdraw = getTokenAmountBigInt(
                              double.parse(exit.balance) /
                                  pow(10, exit.token.decimals),
                              exit.token.decimals);
                          gasLimit = await widget.arguments.store
                              .withdrawGasLimit(
                                  amountWithdraw, null, exit, false, true);
                        } catch (e) {
                          // default withdraw gas: 230K + STANDARD ERC20 TRANFER + (siblings.lenght * 31K)
                          gasLimit = BigInt.from(GAS_LIMIT_WITHDRAW_DEFAULT);
                          exit.merkleProof.siblings.forEach((element) {
                            gasLimit += BigInt.from(GAS_LIMIT_WITHDRAW_SIBLING);
                          });
                          if (exit.token.id != 0) {
                            gasLimit +=
                                BigInt.from(GAS_LIMIT_WITHDRAW_ERC20_TX);
                          }
                        }

                        Navigator.of(widget.arguments.parentContext)
                            .pushNamed("/transaction_details",
                                arguments: TransactionDetailsArguments(
                                  store: widget.arguments.store,
                                  transactionType: TransactionType.WITHDRAW,
                                  transactionLevel: TransactionLevel.LEVEL1,
                                  status: TransactionStatus.DRAFT,
                                  token: exit.token,
                                  exit: exit,
                                  amount: double.parse(exit.balance) /
                                      pow(10, exit.token.decimals),
                                  addressFrom: addressFrom,
                                  addressTo: addressTo,
                                  gasLimit: gasLimit.toInt(),
                                  gasPrice: gasPrice.toInt(),
                                ))
                            .then((value) => _onRefresh());
                      }
                    : () {},
                widget.arguments.store.state.txLevel,
                retry: pendingWithdraw['status'] == 'fail',
              );
            } // final index = i ~/ 2; //get the actual index excluding dividers.
            else {
              final index = i -
                  (_poolTxs.isNotEmpty ||
                          _exits.isNotEmpty ||
                          _pendingWithdraws.isNotEmpty
                      ? 1
                      : 0);
              final Account account = _accounts[index];

              final String currency = widget
                  .arguments.store.state.defaultCurrency
                  .toString()
                  .split('.')
                  .last;

              var isPendingDeposit = false;
              _pendingDeposits.forEach((pendingDeposit) {
                if (account.token.id == (pendingDeposit['token'])['id']) {
                  isPendingDeposit = true;
                }
              });

              return AccountRow(
                  account.token.name,
                  account.token.symbol,
                  currency != "USD"
                      ? account.token.USD *
                          widget.arguments.store.state.exchangeRatio
                      : account.token.USD,
                  currency,
                  double.parse(account.balance) /
                      pow(10, account.token.decimals),
                  false,
                  true,
                  isPendingDeposit,
                  false, (token, amount) async {
                Navigator.of(context)
                    .pushNamed("account_details",
                        arguments: AccountDetailsArguments(
                            widget.arguments.store,
                            account,
                            widget.arguments.parentContext))
                    .then((value) => _onRefresh());
              }); //iterate through indexes and get the next colour
            }
          },
        ),
        onRefresh: _onRefresh,
      ),
      /*),*/
    );
  }

  String totalBalance(AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      // data loaded:
      _accounts = snapshot.data;
    }
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
    if (_accounts != null && _accounts.length > 0) {
      for (Account account in _accounts) {
        if (account.token.USD != null) {
          double value = account.token.USD * double.parse(account.balance);
          if (currency != "USD") {
            value *= widget.arguments.store.state.exchangeRatio;
          }
          resultValue = resultValue + value;
        }
      }
    }

    result = NumberFormat.currency(locale: locale, symbol: symbol)
        .format(resultValue / pow(10, 18));
    return result;
  }
}
