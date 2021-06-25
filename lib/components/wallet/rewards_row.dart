import 'package:flutter/material.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class RewardsRow extends StatelessWidget {
  RewardsRow(this.parentContext /*this.onPressed*/);

  final BuildContext parentContext;
  //final void Function() onPressed;

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: HermezColors.blackTwo),
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      //alignment: Alignment(-1.6, 0),
                      child: Container(
                        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Text(
                          "Your earnings",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w700,
                              fontSize: 18),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: HermezColors.steel.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  showBarModalBottomSheet(
                    context: parentContext,
                    builder: (context) => _buildRewardsPage(),
                  );
                },
                child: Container(
                  padding: EdgeInsets.only(right: 6, left: 6),
                  child: Text(
                    'More info',
                    style: TextStyle(
                      color: HermezColors.lightGrey,
                      fontSize: 15,
                      fontFamily: 'ModernEra',
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          Divider(color: HermezColors.steel),
          Align(
            alignment: Alignment.centerLeft,
            //alignment: Alignment(-1.6, 0),
            child: Container(
              padding: EdgeInsets.only(top: 5.0, bottom: 10.0),
              child: Text(
                "Thank you for participating in the Hermez reward program."
                " Your total reward is 12.3 HEZ (\$43.12)",
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'ModernEra',
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    fontSize: 16),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsPage() {
    return Container(
      padding: EdgeInsets.all(30.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            //alignment: Alignment(-1.6, 0),
            child: Container(
              child: Text(
                "Deposit funds to Hermez to earn rewards.",
                style: TextStyle(
                    color: HermezColors.blackTwo,
                    fontFamily: 'ModernEra',
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    fontSize: 18),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20.0),
            child: Image.asset("assets/rewards.png"),
          ),
          Align(
            alignment: Alignment.centerLeft,
            //alignment: Alignment(-1.6, 0),
            child: Container(
              padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: Text(
                "Thank you for participating in the Hermez reward program."
                " You will receive your HEZ in next few days.",
                style: TextStyle(
                    color: HermezColors.blackTwo,
                    fontFamily: 'ModernEra',
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                    fontSize: 16),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
          Container(
              child: FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(color: HermezColors.lightGrey)),
            onPressed: null,
            padding: EdgeInsets.all(24.0),
            color: HermezColors.lightGrey,
            textColor: Colors.black,
            disabledColor: HermezColors.lightGrey,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        //alignment: Alignment(-1.6, 0),
                        child: Container(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            'Your total reward',
                            style: TextStyle(
                              color: HermezColors.blueyGreyTwo,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '12.3 HEZ (\$43.12)',
                        style: TextStyle(
                          color: HermezColors.blackTwo,
                          fontSize: 18,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }
}
