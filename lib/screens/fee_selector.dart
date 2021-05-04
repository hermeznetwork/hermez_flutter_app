import 'package:flutter/material.dart';
import 'package:hermez/model/wallet.dart';
import 'package:hermez/service/network/model/gas_price_response.dart';
import 'package:hermez/utils/hermez_colors.dart';

import '../context/wallet/wallet_handler.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class FeeSelectorArguments {
  final WalletHandler store;
  WalletDefaultFee selectedFee;
  GasPriceResponse gasPriceResponse;
  final void Function(WalletDefaultFee selectedFee) onFeeSelected;

  FeeSelectorArguments(this.store,
      {this.selectedFee, this.gasPriceResponse, this.onFeeSelected});
}

class FeeSelectorPage extends StatefulWidget {
  FeeSelectorPage({Key key, this.arguments}) : super(key: key);

  final FeeSelectorArguments arguments;

  @override
  _FeeSelectorPageState createState() => _FeeSelectorPageState();
}

class _FeeSelectorPageState extends State<FeeSelectorPage> {
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
      body: Column(
        children: <Widget>[
          buildDefaultFeeList(),
        ],
      ),
    );
  }

  //widget that builds the list
  Widget buildDefaultFeeList() {
    return Expanded(
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
                    margin: EdgeInsets.only(left: 10, bottom: 15, right: 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          widget.arguments.selectedFee != null
                              ? 'Select the fee you want to'
                                  ' spend to cover the cost of processing'
                                  ' your transaction. Higher fees are '
                                  'more likely to be processed.'
                              : 'Select the default fee you want to'
                                  ' spend to cover the cost of processing'
                                  ' your transactions. Higher fees are '
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

                  dynamic element = WalletDefaultFee.values.elementAt(index);

                  return ListTile(
                      title: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 5.0, top: 30.0, bottom: 30.0),
                          child: Column(
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
                              Container(
                                padding:
                                    EdgeInsets.only(top: 12.0, bottom: 12.0),
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
                            ],
                          ),
                        ),
                      ),
                      trailing: (widget.arguments.selectedFee != null
                              ? widget.arguments.selectedFee == element
                              : widget.arguments.store.state.defaultFee ==
                                  element)
                          ? Radio(
                              groupValue: null,
                              activeColor: HermezColors.blackTwo,
                              value: null,
                              onChanged: (value) {
                                setState(() {
                                  if (widget.arguments.selectedFee != null) {
                                    widget.arguments.selectedFee = element;
                                  } else {
                                    widget.arguments.store
                                        .updateDefaultFee(element);
                                  }
                                  if (widget.arguments.onFeeSelected != null) {
                                    widget.arguments.onFeeSelected(element);
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
                                  if (widget.arguments.selectedFee != null) {
                                    widget.arguments.selectedFee = element;
                                  } else {
                                    widget.arguments.store
                                        .updateDefaultFee(element);
                                  }
                                  if (widget.arguments.onFeeSelected != null) {
                                    widget.arguments.onFeeSelected(element);
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  }
                                });
                              },
                            ),
                      onTap: () {
                        setState(() {
                          if (widget.arguments.selectedFee != null) {
                            widget.arguments.selectedFee = element;
                          } else {
                            widget.arguments.store.updateDefaultFee(element);
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
    );
  }
}
