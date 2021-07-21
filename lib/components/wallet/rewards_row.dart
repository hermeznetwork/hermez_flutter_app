import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/service/network/model/airdrop_info.dart';
import 'package:hermez/utils/eth_amount_formatter.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_sdk/model/token.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class RewardsRow extends StatelessWidget {
  RewardsRow(
      this.parentContext, this.airdropInfo, this.store /*this.onPressed*/);

  final BuildContext parentContext;
  final AirdropInfo airdropInfo;
  final WalletHandler store;
  //final void Function() onPressed;

  Widget build(BuildContext context) {
    Token token = store.state.tokens.firstWhere((token) => token.id == 1);
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
                /*this.rewardsType == RewardsType.ERROR
                    ? "There was a problem "
                        "loading the information on this page. "
                        "Please, try to access it again later."
                    :*/
                this.airdropInfo.airdrop.status != "IN_PROGRESS"
                    ? "Thank you for participating in the Hermez reward program."
                            " Your total reward is " +
                        EthAmountFormatter.formatAmount(
                            this.airdropInfo.earnedReward, "HEZ") +
                        ' (' +
                        EthAmountFormatter.formatAmount(
                            (this.airdropInfo.earnedReward *
                                token.USD *
                                (this
                                            .store
                                            .state
                                            .defaultCurrency
                                            .toString()
                                            .split(".")
                                            .last !=
                                        'USD'
                                    ? this.store.state.exchangeRatio
                                    : 1)),
                            this
                                .store
                                .state
                                .defaultCurrency
                                .toString()
                                .split(".")
                                .last) +
                        ')'
                    : "Reward over your funds is 0.65%. You earned so far " +
                        EthAmountFormatter.formatAmount(
                            this.airdropInfo.earnedReward, "HEZ") +
                        " (\$107.33)",
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
    Token token = store.state.tokens.firstWhere((token) => token.id == 1);
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(30.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                child: Text(
                  this.airdropInfo.airdrop.status != "IN_PROGRESS"
                      ? "Community Rewards Round is over"
                      : "Deposit funds to Hermez to earn rewards.",
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
            this.airdropInfo.airdrop.status == "IN_PROGRESS"
                ? Container(
                    margin: EdgeInsets.only(top: 20),
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  calculateTimeLeft(),
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
                    ),
                  )
                : Container(),
            this.airdropInfo.airdrop.status == "IN_PROGRESS" &&
                    this.airdropInfo.eligible == false
                ? Align(
                    alignment: Alignment.centerLeft,
                    //alignment: Alignment(-1.6, 0),
                    child: Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Text(
                        "Action required for eligibility",
                        style: TextStyle(
                            color: HermezColors.blueyGreyTwo,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  )
                : Container(),
            this.airdropInfo.airdrop.status != "IN_PROGRESS"
                ? Align(
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
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      this.airdropInfo.airdrop.status == "IN_PROGRESS"
                          ? Container(
                              margin: EdgeInsets.only(
                                  top: /*this.rewardsType != RewardsType.ERROR &&*/
                                      this.airdropInfo.eligible == false
                                          ? 17
                                          : 27,
                                  right: 10),
                              alignment: Alignment.topLeft,
                              child: SvgPicture.asset(
                                this.airdropInfo.eligible == true
                                    ? "assets/green_tick.svg"
                                    : "assets/red_alert.svg",
                                width: 16,
                                height: 16,
                              ),
                            )
                          : Container(),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          //alignment: Alignment(-1.6, 0),
                          child: Container(
                            margin: EdgeInsets.only(
                                top: /*this.rewardsType != RewardsType.ERROR &&*/
                                    this.airdropInfo.eligible == false
                                        ? 10
                                        : 20,
                                bottom: 20),
                            child: Text(
                              /*this.rewardsType == RewardsType.ERROR
                                  ? "There was a problem "
                                      "loading the information on this page. "
                                      "Please, try to access it again later."
                                  :*/
                              this.airdropInfo.eligible == true
                                  ? "You are eligible to earn rewards"
                                  : "Make at least 2" +
                                      //this.airdrop.minTx.toString() +
                                      " transactions to other Hermez accounts.",
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
                      )
                    ],
                  ),
            /*this.rewardsType != RewardsType.ERROR
                ?*/
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
                              this.airdropInfo.airdrop.status != "IN_PROGRESS"
                                  ? 'Your total reward'
                                  : 'Reward over your funds',
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
                          this.airdropInfo.airdrop.status != "IN_PROGRESS"
                              ? EthAmountFormatter.formatAmount(
                                      this.airdropInfo.earnedReward, "HEZ") +
                                  ' (' +
                                  EthAmountFormatter.formatAmount(
                                      (this.airdropInfo.earnedReward *
                                          token.USD *
                                          (this
                                                      .store
                                                      .state
                                                      .defaultCurrency
                                                      .toString()
                                                      .split(".")
                                                      .last !=
                                                  'USD'
                                              ? this.store.state.exchangeRatio
                                              : 1)),
                                      this
                                          .store
                                          .state
                                          .defaultCurrency
                                          .toString()
                                          .split(".")
                                          .last) +
                                  ')'
                              : this.airdropInfo.rewardPercentage.toString() +
                                  "%",
                          style: TextStyle(
                            color: HermezColors.blackTwo,
                            fontSize: 18,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        this.airdropInfo.airdrop.status == "IN_PROGRESS"
                            ? Align(
                                alignment: Alignment.centerLeft,
                                //alignment: Alignment(-1.6, 0),
                                child: Container(
                                  padding:
                                      EdgeInsets.only(top: 20, bottom: 10.0),
                                  child: Text(
                                    'You earned so far',
                                    style: TextStyle(
                                      color: HermezColors.blueyGreyTwo,
                                      fontFamily: 'ModernEra',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        this.airdropInfo.airdrop.status == "IN_PROGRESS"
                            ? Text(
                                EthAmountFormatter.formatAmount(
                                        this.airdropInfo.earnedReward, "HEZ") +
                                    ' (' +
                                    EthAmountFormatter.formatAmount(
                                        (this.airdropInfo.earnedReward *
                                            token.USD *
                                            (this
                                                        .store
                                                        .state
                                                        .defaultCurrency
                                                        .toString()
                                                        .split(".")
                                                        .last !=
                                                    'USD'
                                                ? this.store.state.exchangeRatio
                                                : 1)),
                                        this
                                            .store
                                            .state
                                            .defaultCurrency
                                            .toString()
                                            .split(".")
                                            .last) +
                                    ')',
                                style: TextStyle(
                                  color: HermezColors.blackTwo,
                                  fontSize: 18,
                                  fontFamily: 'ModernEra',
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ],
              ),
            ))
            /*: Container()*/,
            /*this.rewardsType != RewardsType.ERROR
                ?*/
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 25),
                  alignment: Alignment.topLeft,
                  child: SvgPicture.asset(
                    "assets/info.svg",
                    width: 16,
                    height: 16,
                    color: HermezColors.steel,
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 20, left: 15, bottom: 20),
                    child: Text(
                      this.airdropInfo.airdrop.status == "IN_PROGRESS"
                          ? "Values are estimated and updated once per day."
                              " You will receive your reward at the"
                              " end of the program."
                          : "The value of the reward is estimated, "
                              "it may vary slightly from the reward finally "
                              "received.",
                      style: TextStyle(
                          color: HermezColors.blueyGreyTwo,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ],
            ),
            //: Container(),
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding:
                      EdgeInsets.only(left: 23, right: 23, bottom: 16, top: 16),
                  backgroundColor: HermezColors.lightGrey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'More info',
                      style: TextStyle(
                        color: HermezColors.blueyGreyTwo,
                        fontSize: 16,
                        fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Image.asset(
                      'assets/show_explorer.png',
                      height: 16,
                      width: 16,
                      color: HermezColors.blueyGreyTwo,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String calculateTimeLeft() {
    int lastBlockNum = 30000000; //this.state.network.lastEthereumBlock;
    double blockFrequencyTime = 13.0;
    // average block time ethereum
    int passedTime = 0;
    if (lastBlockNum >= this.airdropInfo.airdrop.initialEthereumBlock) {
      int passedBlocks =
          lastBlockNum - this.airdropInfo.airdrop.initialEthereumBlock;
      passedTime = (passedBlocks * blockFrequencyTime).toInt();
      print('PASSED TIME: ' + (passedTime).toString());
    }
    final airdropDuration = ((this.airdropInfo.airdrop.finalEthereumBlock -
                this.airdropInfo.airdrop.initialEthereumBlock) *
            blockFrequencyTime)
        .toInt();

    final timeLeft = airdropDuration - passedTime;
    final duration = Duration(milliseconds: timeLeft);
    final days = duration.inDays;
    final hours = duration.inHours - (days * 24);
    final minutes = duration.inMinutes - (hours * 60) - (days * 24 * 60);
    return days.toString() +
        "d " +
        hours.toString() +
        "h " +
        minutes.toString() +
        "m left";
  }
}
