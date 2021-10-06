import 'package:after_layout/after_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hermez/dependencies_provider.dart';
import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez/src/presentation/accounts/widgets/account_selector.dart';
import 'package:hermez/src/presentation/qrcode/widgets/qrcode.dart';
import 'package:hermez/src/presentation/settings/settings_bloc.dart';
import 'package:hermez/src/presentation/transfer/widgets/transaction_amount.dart';
import 'package:hermez/src/presentation/wallets/widgets/wallet_details.dart';
import 'package:hermez/utils/address_utils.dart';
import 'package:hermez/utils/balance_utils.dart';
import 'package:hermez/utils/blinking_text_animation.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_sdk/model/pool_transaction.dart';

import '../wallets_bloc.dart';
import '../wallets_state.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class WalletSelectorArguments {
  bool showHermezWallet;
  Function hermezWalletShown;
  BuildContext parentContext;

  WalletSelectorArguments(this.parentContext,
      {this.showHermezWallet = false, this.hermezWalletShown});
}

class WalletSelectorPage extends StatefulWidget {
  WalletSelectorPage({Key key, this.arguments}) : super(key: key);

  WalletSelectorArguments arguments;

  @override
  _WalletSelectorPageState createState() => _WalletSelectorPageState();
}

class _WalletSelectorPageState extends State<WalletSelectorPage>
    with AfterLayoutMixin<WalletSelectorPage> {
  final WalletsBloc _bloc;
  _WalletSelectorPageState() : _bloc = getIt<WalletsBloc>() {
    _bloc.fetchData();
  }
  SettingsBloc _settingsBloc = getIt<SettingsBloc>();

  //List<Account> l1Accounts;
  //List<Account> l2Accounts;

  List<dynamic> pendingExits = [];
  List<dynamic> pendingForceExits = [];
  List<dynamic> pendingWithdraws = [];
  List<dynamic> pendingDeposits = [];
  //List<dynamic> pendingTransfers = [];

  bool isLoading = false;
  bool needRefresh = true;

  @override
  Future<void> afterFirstLayout(BuildContext context) {
    if (widget.arguments.showHermezWallet == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _settingsBloc.setLevel(TransactionLevel.LEVEL2);
        // Add Your Code here.
        //widget.arguments.store.updateLevel(TransactionLevel.LEVEL2);
      });
      Navigator.pushNamed(context, 'wallet_details',
          arguments: WalletDetailsArguments(TransactionLevel.LEVEL2, "",
              widget.arguments.parentContext, true, _bloc, _settingsBloc));
      widget.arguments.showHermezWallet = false;
      if (widget.arguments.hermezWalletShown != null) {
        widget.arguments.hermezWalletShown();
      }
    }
  }

  Future<void> fetchData() async {
    /*if (widget.arguments.store.state.walletInitialized == true &&
        (isLoading == false && needRefresh == true)) {
      isLoading = true;
      needRefresh = false;
      await widget.arguments.store.getAccounts();
      pendingDeposits = fetchPendingDeposits();
      isLoading = false;
    }*/
  }

  Future<List<PoolTransaction>> fetchL2PendingTransfersAndExits() async {
    //List<PoolTransaction> poolTxs = widget.arguments.store.state.pendingL2Txs;
    //return poolTxs;
  }

  List<dynamic> fetchPendingDeposits() {
    //final accountPendingDeposits = widget.arguments.store.state.pendingDeposits;
    //return accountPendingDeposits;
  }

  /*void fetchPendingTransactions() async {
    _pendingExits = await fetchPendingExits();
    List<Exit> _exits = await fetchExits();
    _filteredExits = _exits.toList();
    _pendingForceExits = await fetchPendingForceExits(_exits, _pendingExits);
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

  /*Future<List<dynamic>> fetchPendingForceExits(
      List<Exit> exits, List<PoolTransaction> pendingExits) async {
    final accountPendingForceExits =
    await widget.arguments.store.getPendingForceExits();

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

  Future<List<Exit>> fetchExits() {
    return widget.arguments.store.getExits();
  }

  Future<List<dynamic>> fetchPendingWithdraws() {
    return widget.arguments.store.getPendingWithdraws();
  }

  Future<List<dynamic>> fetchPendingDeposits() {
    return widget.arguments.store.getPendingDeposits();
  }*/*/

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WalletsState>(
        initialData: _bloc.state,
        stream: _bloc.observableState,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is LoadingWalletsState) {
            return Container(
                color: HermezColors.lightOrange,
                child: Center(
                  child: CircularProgressIndicator(color: HermezColors.orange),
                ));
          } else if (state is ErrorWalletsState) {
            return Center(child: Text(state.message));
          } else {
            return _renderWalletSelector(context, state);
          }
        });
  }

  Widget _renderWalletSelector(BuildContext context, LoadedWalletsState state) {
    WalletItemState l1Wallet;
    WalletItemState l2Wallet;
    if (state.wallets != null) {
      state.wallets.forEach((wallet) {
        if (wallet.l2Wallet == true) {
          l2Wallet = wallet;
        } else {
          l1Wallet = wallet;
        }
      });
    }

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: HermezColors.lightOrange,
        body: SafeArea(
          child: Container(
            margin: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Center(
                    child: new GestureDetector(
                      onTap: () {
                        if (!isLoading) {
                          _settingsBloc.setLevel(TransactionLevel.LEVEL2);
                          /*widget.arguments.store
                              .updateLevel(TransactionLevel.LEVEL2);*/
                          Future.delayed(const Duration(milliseconds: 100), () {
                            Navigator.pushNamed(context, 'wallet_details',
                                arguments: WalletDetailsArguments(
                                  TransactionLevel.LEVEL2,
                                  l2Wallet.address,
                                  widget.arguments.parentContext,
                                  false,
                                  _bloc,
                                  _settingsBloc,
                                )).then((refresh) {
                              if (refresh != null && refresh == true) {
                                needRefresh = refresh;
                              } else {
                                needRefresh = false;
                              }
                              setState(() {});
                            });
                          });
                        }
                      },
                      onDoubleTap: null,
                      child: Container(
                        height: width * 0.58,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            color: HermezColors.darkOrange),
                        padding: EdgeInsets.only(
                            left: 24.0, top: 16.0, right: 16.0, bottom: 16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Hermez wallet',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16.0),
                                      color: HermezColors.orange),
                                  padding: EdgeInsets.only(
                                      left: 12.0,
                                      right: 12.0,
                                      top: 6,
                                      bottom: 6),
                                  child: Text(
                                    'L2',
                                    style: TextStyle(
                                      color: HermezColors.blackTwo,
                                      fontSize: 15,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  isLoading == false
                                      ? Flexible(
                                          child: Text(
                                            BalanceUtils.amountInCurrency(
                                                double.parse(
                                                    l2Wallet.totalBalance),
                                                _settingsBloc
                                                    .getDefaultCurrency()
                                                    .toString()
                                                    .split(".")
                                                    .last,
                                                0.8)
                                            /*totalBalance(
                                                TransactionLevel.LEVEL2,
                                                )*/
                                            ,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 32,
                                              fontFamily: 'ModernEra',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        )
                                      : Flexible(
                                          child: BlinkingTextAnimation(
                                              arguments:
                                                  BlinkingTextAnimationArguments(
                                                      Colors.white,
                                                      BalanceUtils.amountInCurrency(
                                                          double.parse(l2Wallet
                                                              .totalBalance),
                                                          _settingsBloc
                                                              .getDefaultCurrency()
                                                              .toString()
                                                              .split(".")
                                                              .last,
                                                          0.8)

                                                      /*totalBalance(
                                                          TransactionLevel
                                                              .LEVEL2,
                                                          widget
                                                              .arguments
                                                              .store
                                                              .state
                                                              .l2Accounts)*/
                                                      ,
                                                      32,
                                                      FontWeight.w700)))
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "hez:" +
                                        "0x" +
                                        (l1Wallet.address != null
                                            ? AddressUtils.strip0x(l1Wallet
                                                    .address
                                                    .substring(0, 6))
                                                .toUpperCase()
                                            : "") +
                                        " ･･･ " +
                                        (l1Wallet.address != null
                                            ? l1Wallet.address
                                                .substring(
                                                    l1Wallet.address.length - 4,
                                                    l1Wallet.address.length)
                                                .toUpperCase()
                                            : ""),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                IconButton(
                                    icon: ImageIcon(
                                      AssetImage('assets/qr_code.png'),
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.of(
                                              widget.arguments.parentContext)
                                          .pushNamed(
                                        "/qrcode",
                                        arguments: QRCodeArguments(
                                            qrCodeType: QRCodeType.HERMEZ,
                                            code: l2Wallet.address,
                                            //store: widget.arguments.store,
                                            isReceive: true),
                                      );
                                    })
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        padding: EdgeInsets.only(
                            left: 23, right: 23, bottom: 16, top: 16),
                        backgroundColor: HermezColors.blackTwo,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () async {
                        if (!isLoading) {
                          if ((l1Wallet == null ||
                                  double.parse(l1Wallet.totalBalance) == 0) &&
                              (l2Wallet == null ||
                                  double.parse(l2Wallet.totalBalance) == 0)) {
                            Navigator.pushNamed(widget.arguments.parentContext,
                                "/first_deposit",
                                arguments: false);
                          } else if (l1Wallet != null &&
                              l1Wallet.accounts != null &&
                              l1Wallet.accounts.length > 0) {
                            _settingsBloc.setLevel(TransactionLevel.LEVEL1);
                            //widget.arguments.store
                            //    .updateLevel(TransactionLevel.LEVEL1);
                            var selectedAccount;
                            if (l1Wallet.accounts.length == 1) {
                              selectedAccount = l1Wallet.accounts[0];
                            } else {
                              selectedAccount = await Navigator.pushNamed(
                                  widget.arguments.parentContext,
                                  "/account_selector",
                                  arguments: AccountSelectorArguments(
                                      TransactionLevel.LEVEL1,
                                      TransactionType.DEPOSIT,
                                      ""
                                      /*widget.arguments.store*/
                                      ));
                            }
                            if (selectedAccount != null) {
                              /*Token token = _settingsBloc.state.settings.tokens
                                  .firstWhere((token) =>
                                      token.token.id == selectedAccount.tokenId);
                              PriceToken priceToken = widget
                                  .arguments.store.state.priceTokens
                                  .firstWhere((priceToken) =>
                                      priceToken.id == selectedAccount.tokenId);*/
                              Navigator.pushNamed(
                                  widget.arguments.parentContext,
                                  "/transaction_amount",
                                  arguments: TransactionAmountArguments(
                                    //widget.arguments.store,
                                    TransactionLevel.LEVEL1,
                                    TransactionType.DEPOSIT,
                                    account: selectedAccount,
                                    //token: token,
                                    //priceToken: priceToken,
                                    allowChangeLevel: true,
                                  )).then((value) {
                                setState(() {});
                              });
                            }
                          } else if (l2Wallet.accounts != null &&
                              l2Wallet.accounts.length > 0) {
                            _settingsBloc.setLevel(TransactionLevel.LEVEL2);
                            /*widget.arguments.store
                                .updateLevel(TransactionLevel.LEVEL2);*/
                            var selectedAccount;
                            if (l2Wallet.accounts.length == 1) {
                              selectedAccount = l2Wallet.accounts[0];
                            } else {
                              selectedAccount = await Navigator.of(
                                      widget.arguments.parentContext)
                                  .pushNamed("/account_selector",
                                      arguments: AccountSelectorArguments(
                                          TransactionLevel.LEVEL2,
                                          TransactionType.EXIT,
                                          ""
                                          /*widget.arguments.store*/));
                            }
                            if (selectedAccount != null) {
                              /*Token token = widget.arguments.store.state.tokens
                                  .firstWhere((token) =>
                                      token.id == selectedAccount.tokenId);
                              PriceToken priceToken = widget
                                  .arguments.store.state.priceTokens
                                  .firstWhere((priceToken) =>
                                      priceToken.id == selectedAccount.tokenId);*/
                              Navigator.pushNamed(
                                  widget.arguments.parentContext,
                                  "/transaction_amount",
                                  arguments: TransactionAmountArguments(
                                    //widget.arguments.store,
                                    TransactionLevel.LEVEL2,
                                    TransactionType.EXIT,
                                    account: selectedAccount,
                                    //token: token,
                                    //priceToken: priceToken,
                                    allowChangeLevel: true,
                                  )).then((value) {
                                setState(() {});
                              });
                            }
                          } else {
                            _settingsBloc.setLevel(TransactionLevel.LEVEL1);
                            /*widget.arguments.store
                                .updateLevel(TransactionLevel.LEVEL1);*/
                            final selectedAccount = await Navigator.of(context)
                                .pushNamed("/account_selector",
                                    arguments: AccountSelectorArguments(
                                        TransactionLevel.LEVEL1,
                                        TransactionType.DEPOSIT,
                                        ""
                                        /*widget.arguments.store*/));
                            if (selectedAccount != null) {
                              /*Token token = widget.arguments.store.state.tokens
                                  .firstWhere((token) =>
                                      token.id ==
                                      (selectedAccount as Account).tokenId);
                              PriceToken priceToken = widget
                                  .arguments.store.state.priceTokens
                                  .firstWhere((priceToken) =>
                                      priceToken.id ==
                                      (selectedAccount as Account).tokenId);*/
                              Navigator.pushNamed(
                                  widget.arguments.parentContext,
                                  "/transaction_amount",
                                  arguments: TransactionAmountArguments(
                                    //widget.arguments.store,
                                    TransactionLevel.LEVEL1,
                                    TransactionType.DEPOSIT,
                                    account: selectedAccount,
                                    //token: token,
                                    //priceToken: priceToken,
                                    allowChangeLevel: true,
                                  )).then((value) {
                                setState(() {});
                              });
                            }
                          }
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Move',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          SvgPicture.asset(
                            'assets/move.svg',
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: new GestureDetector(
                      onTap: () {
                        if (!isLoading) {
                          _settingsBloc.setLevel(TransactionLevel.LEVEL1);
                          /*widget.arguments.store
                              .updateLevel(TransactionLevel.LEVEL1);*/
                          Future.delayed(const Duration(milliseconds: 100), () {
                            Navigator.pushNamed(context, 'wallet_details',
                                arguments: WalletDetailsArguments(
                                  //widget.arguments.store,
                                  TransactionLevel.LEVEL1,
                                  l1Wallet.address,
                                  widget.arguments.parentContext,
                                  false,
                                  _bloc,
                                  _settingsBloc,
                                )).then((value) {
                              setState(() {});
                            });
                          });
                        }
                      },
                      onDoubleTap: null,
                      child: Container(
                        height: width * 0.58,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            color: HermezColors.blueyGreyTwo),
                        padding: EdgeInsets.only(
                            left: 24.0, top: 16.0, right: 16.0, bottom: 16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Ethereum wallet',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16.0),
                                      color: Colors.white),
                                  padding: EdgeInsets.only(
                                      left: 12.0,
                                      right: 12.0,
                                      top: 6,
                                      bottom: 6),
                                  child: Text(
                                    'L1',
                                    style: TextStyle(
                                      color: HermezColors.blackTwo,
                                      fontSize: 15,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  isLoading == false
                                      ? Flexible(
                                          child: Text(
                                              BalanceUtils.amountInCurrency(
                                                  double.parse(
                                                      l1Wallet.totalBalance),
                                                  _settingsBloc
                                                      .getDefaultCurrency()
                                                      .toString()
                                                      .split(".")
                                                      .last,
                                                  0.8)
                                              //l1Wallet.totalBalance
                                              /*totalBalance(
                                                  TransactionLevel.LEVEL1,
                                                  widget.arguments.store.state
                                                      .l1Accounts)*/
                                              ,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 32,
                                                fontFamily: 'ModernEra',
                                                fontWeight: FontWeight.w700,
                                              )))
                                      : Flexible(
                                          child: BlinkingTextAnimation(
                                              arguments:
                                                  BlinkingTextAnimationArguments(
                                                      Colors.white,
                                                      BalanceUtils.amountInCurrency(
                                                          double.parse(l1Wallet
                                                              .totalBalance),
                                                          _settingsBloc
                                                              .getDefaultCurrency()
                                                              .toString()
                                                              .split(".")
                                                              .last,
                                                          0.8)

                                                      /*totalBalance(
                                                          TransactionLevel
                                                              .LEVEL1,
                                                          l1Wallet.accounts
                                                          /*widget
                                                              .arguments
                                                              .store
                                                              .state
                                                              .l1Accounts*/)*/
                                                      ,
                                                      32,
                                                      FontWeight.w700)))
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "0x" +
                                        (l1Wallet.address != null
                                            ? AddressUtils.strip0x(l1Wallet
                                                    .address
                                                    .substring(0, 6))
                                                .toUpperCase()
                                            : "") +
                                        " ･･･ " +
                                        (l1Wallet.address != null
                                            ? l1Wallet.address
                                                .substring(
                                                    l1Wallet.address.length - 4,
                                                    l1Wallet.address.length)
                                                .toUpperCase()
                                            : ""),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: ImageIcon(
                                    AssetImage('assets/qr_code.png'),
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.of(widget.arguments.parentContext)
                                        .pushNamed(
                                      "/qrcode",
                                      arguments: QRCodeArguments(
                                          qrCodeType: QRCodeType.ETHEREUM,
                                          code: l1Wallet.address,
                                          //store: widget.arguments.store,
                                          isReceive: true),
                                    );
                                    //Navigator.pushNamed(context, 'home');
                                  },
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ), //buildCurrencyList(),
              ],
            ),
          ),
        ));
  }

  /*String totalBalance(TransactionLevel txLevel, List<Account> _accounts) {
    double resultValue = 0;
    String result = "";
    String locale = "";
    String symbol = "";
    final String currency =
        _settingsBloc.state.settings.defaultCurrency.toString().split('.').last;
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

    result = BalanceUtils.balanceOfAccounts(
        txLevel,
        _accounts,
        //widget.arguments.store,
        currency,
        1,
        //widget.arguments.store.state.exchangeRatio,
        pendingWithdraws,
        pendingDeposits);
    /*if (_accounts != null && _accounts.length > 0) {
      for (Account account in _accounts) {
        if (account.token.USD != null) {
          double value = account.token.USD * double.parse(account.balance);
          if (currency != "USD") {
            value *= widget.arguments.store.state.exchangeRatio;
          }
          resultValue += value;
        }
      }
    }
    //result += (resultValue / pow(10, 18)).toStringAsFixed(2);
    result = NumberFormat.currency(locale: locale, symbol: symbol)
        .format(resultValue / pow(10, 18));*/
    return result;
  }*/
}
