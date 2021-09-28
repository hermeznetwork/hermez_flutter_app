import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hermez/dependencies_provider.dart';
import 'package:hermez/src/domain/prices/price_token.dart';
import 'package:hermez/src/domain/tokens/token.dart';
import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez/src/presentation/accounts/accounts_state.dart';
import 'package:hermez/src/presentation/qrcode/widgets/qrcode.dart';
import 'package:hermez/src/presentation/tokens/tokens_bloc.dart';
import 'package:hermez/src/presentation/tokens/tokens_state.dart';
import 'package:hermez/src/presentation/tokens/widgets/token_row.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_sdk/model/token.dart' as hezToken;

class TokenSelectorArguments {
  final TransactionLevel txLevel;
  final TransactionType transactionType;
  final String address;
  //final WalletHandler store;

  TokenSelectorArguments(this.txLevel, this.transactionType, this.address
      /*this.store*/
      );
}

class TokenSelectorPage extends StatefulWidget {
  TokenSelectorPage({Key key, this.arguments}) : super(key: key);

  final TokenSelectorArguments arguments;

  @override
  _TokenSelectorPageState createState() => _TokenSelectorPageState();
}

class _TokenSelectorPageState extends State<TokenSelectorPage> {
  List<Token> _tokens;

  final TokensBloc _bloc;
  _TokenSelectorPageState() : _bloc = getIt<TokensBloc>() {
    fetchData();
  }

  void fetchData() {
    _bloc.getTokens();
  }

  @override
  Widget build(BuildContext context) {
    //final bloc = BlocProvider.of<CartBloc>(context);

    return StreamBuilder<TokensState>(
        initialData: _bloc.state,
        stream: _bloc.observableState,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is LoadingAccountsState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ErrorAccountsState) {
            return _renderErrorContent();
          } else {
            return _renderAccountsContent(context, state);
          }
        });
  }

  Widget _renderAccountsContent(BuildContext context, LoadedTokensState state) {
    if (state.tokensItem.tokens != null && state.tokensItem.tokens.length > 0) {
      _tokens = state.tokensItem.tokens;
      buildTokensList(context);
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

  Future<void> _onRefresh() async {
    fetchData();
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
  Widget buildTokensList(BuildContext parentContext) {
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
                        itemCount: _tokens.length,
                        //set the item count so that index won't be out of range
                        padding: const EdgeInsets.all(16.0),
                        //add some padding to make it look good
                        itemBuilder: (context, i) {
                          final index = i;
                          /*final String currency = widget
                              .arguments.store.state.defaultCurrency
                              .toString()
                              .split('.')
                              .last;*/

                          final Token token = _tokens[index];
                          final hezToken.Token hermezToken = token.token;
                          PriceToken priceToken = token.price;
                          return TokenRow(
                              token,
                              hermezToken.name,
                              hermezToken.symbol,
                              /*currency != "USD"
                                  ? priceToken.USD *
                                      widget.arguments.store.state.exchangeRatio
                                  :*/
                              priceToken.USD,
                              "USD", //currency,
                              0,
                              false,
                              true,
                              false, (Token token, String tokenId,
                                  String amount) async {
                            Navigator.maybePop(parentContext, token);
                          });
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
