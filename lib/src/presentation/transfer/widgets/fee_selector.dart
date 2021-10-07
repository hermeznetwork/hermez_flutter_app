import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hermez/dependencies_provider.dart';
import 'package:hermez/service/network/model/gas_price_response.dart';
import 'package:hermez/src/domain/tokens/token.dart';
import 'package:hermez/src/domain/wallets/wallet.dart';
import 'package:hermez/src/presentation/settings/settings_bloc.dart';
import 'package:hermez/src/presentation/settings/settings_state.dart';
import 'package:hermez/utils/eth_amount_formatter.dart';
import 'package:hermez/utils/hermez_colors.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class FeeSelectorArguments {
  SettingsBloc settingsBloc;
  WalletDefaultFee selectedFee;
  Token ethereumToken;
  BigInt estimatedGas;
  GasPriceResponse gasPriceResponse;
  final void Function(WalletDefaultFee selectedFee) onFeeSelected;

  FeeSelectorArguments(
      {this.settingsBloc,
      this.selectedFee,
      this.ethereumToken,
      this.estimatedGas,
      this.gasPriceResponse,
      this.onFeeSelected});
}

class FeeSelectorPage extends StatefulWidget {
  FeeSelectorPage({Key key, this.arguments}) : super(key: key);

  final FeeSelectorArguments arguments;

  @override
  _FeeSelectorPageState createState() =>
      _FeeSelectorPageState(arguments.settingsBloc);
}

class _FeeSelectorPageState extends State<FeeSelectorPage> {
  final SettingsBloc _settingsBloc;

  _FeeSelectorPageState(SettingsBloc settingsBloc)
      : _settingsBloc =
            settingsBloc != null ? settingsBloc : getIt<SettingsBloc>() {
    if (_settingsBloc.state is InitSettingsState) {
      _settingsBloc.init();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Select fee",
            style: TextStyle(
                fontFamily: 'ModernEra',
                color: HermezColors.blackTwo,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<SettingsState>(
        initialData: _settingsBloc.state,
        stream: _settingsBloc.observableState,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is LoadingSettingsState) {
            return Container(
                color: Colors.white,
                child: Center(
                  child: CircularProgressIndicator(color: HermezColors.orange),
                ));
          } else if (state is ErrorSettingsState) {
            return Center(child: Text(state.message));
          } else {
            return _renderFeeSelector(context, state);
          }
        },
      ),
    );
  }

  Widget _renderFeeSelector(BuildContext context, LoadedSettingsState state) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
              color: Colors.white,
              child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: WalletDefaultFee.values.length + 1,
                  padding: const EdgeInsets.all(16.0),
                  separatorBuilder: (BuildContext context, int index) {
                    return Container(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: Divider(color: HermezColors.steel));
                  },
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return Container(
                        margin:
                            EdgeInsets.only(left: 10, bottom: 15, right: 24),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              'Select the ' +
                                  (widget.arguments.selectedFee == null
                                      ? 'default'
                                      : '') +
                                  ' fee you want to'
                                      ' spend to cover the cost of processing'
                                      ' your transaction. Higher fees are '
                                      'more likely to be processed.',
                              style: TextStyle(
                                color: HermezColors.blueyGreyTwo,
                                fontSize: 16,
                                height: 1.5,
                                fontFamily: 'ModernEra',
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                      );
                    } else {
                      final index = i - 1;

                      dynamic element =
                          WalletDefaultFee.values.elementAt(index);
                      int gasPrice = 0;
                      if (widget.arguments.selectedFee != null) {
                        switch (index) {
                          case 0:
                            gasPrice =
                                widget.arguments.gasPriceResponse.safeLow *
                                    pow(10, 8);
                            break;
                          case 1:
                            gasPrice =
                                widget.arguments.gasPriceResponse.average *
                                    pow(10, 8);
                            break;
                          case 2:
                            gasPrice = widget.arguments.gasPriceResponse.fast *
                                pow(10, 8);
                            break;
                        }
                      }

                      return ListTile(
                          title: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(
                                      left: 5.0, top: 24.0, bottom: 24.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Text(
                                          element
                                                  .toString()
                                                  .split(".")
                                                  .last
                                                  .substring(0, 1) +
                                              element
                                                  .toString()
                                                  .split(".")
                                                  .last
                                                  .substring(1)
                                                  .toLowerCase(),
                                          style: TextStyle(
                                              fontFamily: 'ModernEra',
                                              color: HermezColors.blackTwo,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      widget.arguments.selectedFee != null
                                          ? Container(
                                              padding: EdgeInsets.only(
                                                  top: 12.0, bottom: 12.0),
                                              child: Text(
                                                EthAmountFormatter.formatAmount(
                                                    (widget.arguments
                                                            .estimatedGas
                                                            .toInt() *
                                                        gasPrice /
                                                        pow(
                                                            10,
                                                            widget
                                                                .arguments
                                                                .ethereumToken
                                                                .token
                                                                .decimals)),
                                                    widget
                                                        .arguments
                                                        .ethereumToken
                                                        .token
                                                        .symbol),
                                                style: TextStyle(
                                                    fontFamily: 'ModernEra',
                                                    color:
                                                        HermezColors.blackTwo,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16),
                                                textAlign: TextAlign.left,
                                              ),
                                            )
                                          : Container(),
                                      widget.arguments.selectedFee != null
                                          ? Container(
                                              child: Text(
                                                (widget.arguments.ethereumToken
                                                                .price.USD *
                                                            /*(state.settings.defaultCurrency
                                                                    .toString()
                                                                    .split(".")
                                                                    .last !=
                                                                "USD"
                                                            ?  state.settings
                                                                .exchangeRatio
                                                            : 1)
                                                            * */
                                                            (widget.arguments
                                                                    .estimatedGas
                                                                    .toInt() *
                                                                gasPrice /
                                                                pow(
                                                                    10,
                                                                    widget
                                                                        .arguments
                                                                        .ethereumToken
                                                                        .token
                                                                        .decimals)))
                                                        .toStringAsFixed(2) +
                                                    " " +
                                                    state.settings
                                                        .defaultCurrency
                                                        .toString()
                                                        .split(".")
                                                        .last,
                                                style: TextStyle(
                                                    fontFamily: 'ModernEra',
                                                    color: HermezColors
                                                        .blueyGreyTwo,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16),
                                                textAlign: TextAlign.left,
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                              ),
                              (widget.arguments.selectedFee != null
                                      ? widget.arguments.selectedFee == element
                                      : state.settings.defaultFee == element)
                                  ? Radio(
                                      groupValue: null,
                                      activeColor: HermezColors.blackTwo,
                                      value: null,
                                      onChanged: (value) {
                                        setState(() {
                                          if (widget.arguments.selectedFee !=
                                              null) {
                                            widget.arguments.selectedFee =
                                                element;
                                          } else {
                                            _settingsBloc
                                                .setDefaultFee(element);
                                            /*widget.arguments.store
                                            .updateDefaultFee(element);*/
                                          }
                                          if (widget.arguments.onFeeSelected !=
                                              null) {
                                            widget.arguments
                                                .onFeeSelected(element);
                                            if (Navigator.canPop(context)) {
                                              Navigator.pop(context);
                                            }
                                          }
                                        });
                                      },
                                    )
                                  : Radio(
                                      groupValue: null,
                                      value: element.toString().split(".").last,
                                      activeColor: HermezColors.blackTwo,
                                      onChanged: (value) {
                                        setState(() {
                                          if (widget.arguments.selectedFee !=
                                              null) {
                                            widget.arguments.selectedFee =
                                                element;
                                          } else {
                                            _settingsBloc
                                                .setDefaultFee(element);
                                            /*widget.arguments.store
                                            .updateDefaultFee(element);*/
                                          }
                                          if (widget.arguments.onFeeSelected !=
                                              null) {
                                            widget.arguments
                                                .onFeeSelected(element);
                                            if (Navigator.canPop(context)) {
                                              Navigator.pop(context);
                                            }
                                          }
                                        });
                                      },
                                    ),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              if (widget.arguments.selectedFee != null) {
                                widget.arguments.selectedFee = element;
                              } else {
                                _settingsBloc.setDefaultFee(element);
                                //widget.arguments.store.updateDefaultFee(element);
                              }
                              if (widget.arguments.onFeeSelected != null) {
                                widget.arguments.onFeeSelected(element);
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              }
                            });
                          });
                    }
                  })),
        ),
      ],
    );
  }
}
