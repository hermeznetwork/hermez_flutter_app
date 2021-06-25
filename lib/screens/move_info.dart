import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez/utils/hermez_colors.dart';

class MoveInfoArguments {
  final TransactionType transactionType;

  MoveInfoArguments({this.transactionType = TransactionType.EXIT});
}

class MoveInfoPage extends StatefulWidget {
  MoveInfoPage({this.arguments, Key key}) : super(key: key);

  final MoveInfoArguments arguments;

  @override
  _MoveInfoPageState createState() => _MoveInfoPageState();
}

class _MoveInfoPageState extends State<MoveInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(24.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Moving funds requires completing 2 steps. '
                  'Once you have initiated moving funds '
                  'it can’t be canceled.',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: HermezColors.blueyGreyTwo,
                    fontSize: 16,
                    height: 1.57,
                    fontFamily: 'ModernEra',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: HermezColors.lightGrey),
                padding: EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          color: Colors.white),
                      padding: EdgeInsets.only(
                          left: 14.0, right: 14.0, top: 9, bottom: 9),
                      child: Text(
                        'Step 1',
                        style: TextStyle(
                          color: HermezColors.blueyGreyTwo,
                          fontSize: 15,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'You will pay for a fixed amount of ' +
                            (widget.arguments.transactionType ==
                                    TransactionType.EXIT
                                ? 'Hermez fees.'
                                : 'Ethereum gas fees'),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: HermezColors.blackTwo,
                          fontSize: 16,
                          height: 1.57,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: HermezColors.lightGrey),
                padding: EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          color: Colors.white),
                      padding: EdgeInsets.only(
                          left: 14.0, right: 14.0, top: 9, bottom: 9),
                      child: Text(
                        'Step 2',
                        style: TextStyle(
                          color: HermezColors.blueyGreyTwo,
                          fontSize: 15,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'You will pay for Ethereum gas fees and it may vary from the estimation in step 1.',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: HermezColors.blackTwo,
                          fontSize: 16,
                          height: 1.57,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
