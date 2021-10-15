import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hermez/dependencies_provider.dart';
import 'package:hermez/src/domain/accounts/account.dart';
import 'package:hermez/src/domain/prices/price_token.dart';
import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez/src/domain/transactions/transaction_repository.dart';
import 'package:hermez/src/presentation/accounts/accounts_bloc.dart';
import 'package:hermez/src/presentation/accounts/accounts_state.dart';
import 'package:hermez/src/presentation/accounts/widgets/account_row.dart';
import 'package:hermez/src/presentation/qrcode/widgets/qrcode.dart';
import 'package:hermez/src/presentation/settings/settings_bloc.dart';
import 'package:hermez/src/presentation/settings/settings_state.dart';
import 'package:hermez/utils/balance_utils.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_sdk/model/token.dart';

class AccountSelectorArguments {
  List<Account> accounts;
  SettingsBloc settingsBloc;
  final TransactionLevel txLevel;
  final TransactionType transactionType;
  final String address;

  AccountSelectorArguments(this.accounts, this.settingsBloc, this.txLevel,
      this.transactionType, this.address);
}

class AccountSelectorPage extends StatefulWidget {
  AccountSelectorPage({Key key, this.arguments}) : super(key: key);

  final AccountSelectorArguments arguments;

  @override
  _AccountSelectorPageState createState() => _AccountSelectorPageState(
      arguments.accounts,
      arguments.txLevel,
      arguments.transactionType,
      arguments.address);
}

class _AccountSelectorPageState extends State<AccountSelectorPage> {
  //List<Account> _accounts;
  //List<Token> _tokens;

  final AccountsBloc _bloc;
  _AccountSelectorPageState(List<Account> accounts, TransactionLevel level,
      TransactionType type, String address)
      : _bloc = getIt<AccountsBloc>() {
    if (!(_bloc.state is LoadedAccountsState)) {
      if ((level == TransactionLevel.LEVEL1 &&
              type != TransactionType.FORCEEXIT) ||
          type == TransactionType.DEPOSIT) {
        _bloc.getAccounts(LayerFilter.L1, address);
      } else {
        _bloc.getAccounts(LayerFilter.L2, address);
      }
    }
  }

  /*void fetchData() {
    if ((widget.arguments.txLevel == TransactionLevel.LEVEL1 &&
            widget.arguments.transactionType != TransactionType.FORCEEXIT) ||
        widget.arguments.transactionType == TransactionType.DEPOSIT) {
      _bloc.getAccounts(LayerFilter.L1, widget.arguments.address);
    } else {
      _bloc.getAccounts(LayerFilter.L2, widget.arguments.address);
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _renderAppBar(), body: _renderAccountSelector());
  }

  Widget _renderAccountSelector() {
    if (widget.arguments.accounts != null) {
      return _renderAccountsContent(context, widget.arguments.accounts);
    } else {
      return StreamBuilder<AccountsState>(
        initialData: _bloc.state,
        stream: _bloc.observableState,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is LoadingAccountsState) {
            return Container(
                color: Colors.white,
                child: Center(
                  child: CircularProgressIndicator(color: HermezColors.orange),
                ));
          } else if (state is ErrorAccountsState) {
            return _renderErrorContent();
          } else {
            return _renderAccountsContent(context, state.accountsItem.accounts);
          }
        },
      );
    }
  }

  Widget _renderAccountsContent(BuildContext context, List<Account> accounts) {
    if (accounts != null && accounts.length > 0) {
      widget.arguments.accounts = accounts;
      return buildAccountsList(context);
    } else {
      return _renderEmptyViewContent();
    }
  }

  Widget _renderEmptyViewContent() {
    return Container(
      margin: EdgeInsets.all(20.0),
      child: Column(children: [
        Text(
          'Make a deposit first in your ' +
              (widget.arguments.txLevel == TransactionLevel.LEVEL1
                  ? 'Ethereum wallet'
                  : 'Hermez wallet') +
              ' to ' +
              (widget.arguments.transactionType == TransactionType.SEND
                  ? 'send tokens.'
                  : 'move your funds.'),
          textAlign: TextAlign.left,
          style: TextStyle(
            color: HermezColors.blackTwo,
            fontSize: 18,
            height: 1.5,
            fontFamily: 'ModernEra',
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        new GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              "/qrcode",
              arguments: QRCodeArguments(
                qrCodeType: widget.arguments.txLevel == TransactionLevel.LEVEL1
                    ? QRCodeType.ETHEREUM
                    : QRCodeType.HERMEZ,
                code: widget.arguments.address,
                //store: widget.arguments.store,
              ),
            );
          },
          child: Container(
            height: 200,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: widget.arguments.txLevel == TransactionLevel.LEVEL1
                    ? HermezColors.blueyGreyTwo
                    : HermezColors.darkOrange),
            padding: EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.arguments.txLevel == TransactionLevel.LEVEL1
                            ? 'Ethereum wallet'
                            : 'Hermez wallet',
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
                          color: widget.arguments.txLevel ==
                                  TransactionLevel.LEVEL1
                              ? Colors.white
                              : HermezColors.orange),
                      padding: EdgeInsets.only(
                          left: 12.0, right: 12.0, top: 6, bottom: 6),
                      child: Text(
                        widget.arguments.txLevel == TransactionLevel.LEVEL1
                            ? 'L1'
                            : 'L2',
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
                      Image.asset(
                        'assets/deposit3.png',
                        width: 75,
                        height: 75,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset(
                      widget.arguments.txLevel == TransactionLevel.LEVEL1
                          ? 'assets/ethereum_logo.png'
                          : 'assets/hermez_logo_white.png',
                      width: 30,
                      height: 30,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _renderErrorContent() {
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
                padding:
                    EdgeInsets.only(left: 23, right: 23, bottom: 16, top: 16),
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
  }

  /*List<Account> getAccounts() {
    if ((widget.arguments.txLevel == TransactionLevel.LEVEL1 &&
            widget.arguments.transactionType != TransactionType.FORCEEXIT) ||
        widget.arguments.transactionType == TransactionType.DEPOSIT) {
      return _bloc.state.accountItem.accounts;
      //return widget.arguments.store.state.l1Accounts; //getL1Accounts(false);
    } else {
      return _bloc.state.accountItem.accounts;
      //return widget.arguments.store.state.l2Accounts; //getL2Accounts();
    }
  }*/

  /*Future<List<Token>> getTokens() {
    return widget.arguments.store.getTokens();
  }*/

  Future<void> _onRefresh() async {
    //fetchData();
    //setState(() {});
  }

  Widget _renderAppBar() {
    String operation;
    if (widget.arguments.transactionType == TransactionType.SEND) {
      operation = "send";
    } else if (widget.arguments.transactionType == TransactionType.EXIT ||
        widget.arguments.transactionType == TransactionType.FORCEEXIT ||
        widget.arguments.transactionType == TransactionType.DEPOSIT ||
        widget.arguments.transactionType == TransactionType.WITHDRAW) {
      operation = "move";
    } else if (widget.arguments.transactionType == TransactionType.RECEIVE) {
      operation = "receive";
    }

    return AppBar(
      title: new Text(operation[0].toUpperCase() + operation.substring(1),
          style: TextStyle(
              fontFamily: 'ModernEra',
              color: HermezColors.blackTwo,
              fontWeight: FontWeight.w800,
              fontSize: 20)),
      centerTitle: true,
      elevation: 0.0,
      actions: <Widget>[
        new IconButton(
          icon: new Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
      ],
      leading: new Container(),
    );
  }

  /*@override
  Widget build(BuildContext context) {
    //_accounts = getAccounts();

    return Scaffold(
      appBar: _renderAppBar(),
      body:
          /*widget.arguments.transactionType == TransactionType.RECEIVE
          ? FutureBuilder<List<dynamic>>(
              future: getTokens(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>> snapshot) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                          color: Colors.white,
                          child: handleAccountsList(snapshot, context)),
                    ),
                  ],
                );
              },
            )
          :*/
          _accounts != null && _accounts.length > 0
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                          color: Colors.white,
                          child: buildAccountsList(context)),
                    ),
                  ],
                )
              : _renderEmptyViewContent(),
    );
  }*/

  /*Widget handleAccountsList(AsyncSnapshot snapshot, BuildContext context) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
        child: CircularProgressIndicator(color: HermezColors.orange),
      );
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
          if (widget.arguments.transactionType == TransactionType.RECEIVE) {
            _tokens = snapshot.data;
          } else {
            _accounts = snapshot.data;
            buildAccountsList(context);
          }
        } else {
          return Container(
            margin: EdgeInsets.all(20.0),
            child: Column(children: [
              Text(
                'Make a deposit first in your ' +
                    (widget.arguments.txLevel == TransactionLevel.LEVEL1
                        ? 'Ethereum wallet'
                        : 'Hermez wallet') +
                    ' to ' +
                    (widget.arguments.transactionType == TransactionType.SEND
                        ? 'send tokens.'
                        : 'move your funds.'),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: HermezColors.blackTwo,
                  fontSize: 18,
                  height: 1.5,
                  fontFamily: 'ModernEra',
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              new GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    "/qrcode",
                    arguments: QRCodeArguments(
                      qrCodeType:
                          widget.arguments.txLevel == TransactionLevel.LEVEL1
                              ? QRCodeType.ETHEREUM
                              : QRCodeType.HERMEZ,
                      code: widget.arguments.txLevel == TransactionLevel.LEVEL1
                          ? widget.arguments.store.state.ethereumAddress
                          : getHermezAddress(
                              widget.arguments.store.state.ethereumAddress),
                      store: widget.arguments.store,
                    ),
                  );
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: widget.arguments.txLevel == TransactionLevel.LEVEL1
                          ? HermezColors.blueyGreyTwo
                          : HermezColors.darkOrange),
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.arguments.txLevel ==
                                      TransactionLevel.LEVEL1
                                  ? 'Ethereum wallet'
                                  : 'Hermez wallet',
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
                                color: widget.arguments.txLevel ==
                                        TransactionLevel.LEVEL1
                                    ? Colors.white
                                    : HermezColors.orange),
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 6, bottom: 6),
                            child: Text(
                              widget.arguments.txLevel ==
                                      TransactionLevel.LEVEL1
                                  ? 'L1'
                                  : 'L2',
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
                            Image.asset(
                              'assets/deposit3.png',
                              width: 75,
                              height: 75,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Image.asset(
                            widget.arguments.txLevel == TransactionLevel.LEVEL1
                                ? 'assets/ethereum_logo.png'
                                : 'assets/hermez_logo_white.png',
                            width: 30,
                            height: 30,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          );
        }
      }
    }

    return buildAccountsList(context);
  }*/

  //widget that builds the list
  Widget buildAccountsList(BuildContext parentContext) {
    String operation;
    if (widget.arguments.transactionType == TransactionType.SEND) {
      operation = "send";
    } else if (widget.arguments.transactionType == TransactionType.EXIT ||
        widget.arguments.transactionType == TransactionType.FORCEEXIT ||
        widget.arguments.transactionType == TransactionType.DEPOSIT ||
        widget.arguments.transactionType == TransactionType.WITHDRAW) {
      operation = "move";
    } else if (widget.arguments.transactionType == TransactionType.RECEIVE) {
      operation = "receive";
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Available tokens to ' + operation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: HermezColors.blackTwo,
                        fontSize: 16,
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          color: HermezColors.blueyGreyTwo),
                      padding: EdgeInsets.only(
                          left: 12.0, right: 12.0, top: 4, bottom: 4),
                      child: Text(
                        widget.arguments.txLevel == TransactionLevel.LEVEL1
                            ? "L1"
                            : "L2",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: RefreshIndicator(
                      color: HermezColors.orange,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.arguments.accounts.length,
                        //set the item count so that index won't be out of range
                        padding: const EdgeInsets.all(16.0),
                        //add some padding to make it look good
                        itemBuilder: (context, i) {
                          final index = i;
                          final String currency = (widget.arguments.settingsBloc
                                  .state as LoadedSettingsState)
                              .settings
                              .defaultCurrency
                              .toString()
                              .split('.')
                              .last;
                          final Account account =
                              widget.arguments.accounts[index];
                          Token token = account.token.token;
                          PriceToken priceToken = account.token.price;
                          return AccountRow(
                            account,
                            token.name,
                            token.symbol,
                            priceToken.USD *
                                (currency != "USD"
                                    ? (widget.arguments.settingsBloc.state
                                            as LoadedSettingsState)
                                        .settings
                                        .exchangeRatio
                                    : 1),
                            currency,
                            BalanceUtils.calculatePendingBalance(
                                    widget.arguments.txLevel,
                                    account,
                                    token.symbol) /
                                pow(10, token.decimals),
                            false,
                            true,
                            false,
                            (Account account, String tokenId, String amount) {
                              Navigator.maybePop(parentContext, account);
                            },
                          );
                        },
                      ),
                      onRefresh: _onRefresh,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
