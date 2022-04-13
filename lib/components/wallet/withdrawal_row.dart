import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez/utils/eth_amount_formatter.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez_sdk/model/bucket.dart';
import 'package:hermez_sdk/model/exit.dart';
import 'package:hermez_sdk/model/state_response.dart';

class WithdrawalRow extends StatelessWidget {
  WithdrawalRow(
    this.exit,
    this.step,
    this.currency,
    this.exchangeRatio,
    this.onPressed,
    this.transactionLevel,
    this.state, {
    this.retry = false,
    this.completeDelayedWithdraw = false,
    this.instantWithdrawAllowed = true,
  });

  final Exit exit;
  final int step;
  final String currency;
  final double exchangeRatio;
  final bool retry;
  final bool completeDelayedWithdraw;
  final bool instantWithdrawAllowed;
  final StateResponse state;
  final TransactionLevel transactionLevel;
  final void Function(bool completeDelayedWithdraw, bool isInstantWithdraw)
      onPressed;

  Widget build(BuildContext context) {
    String status = "";
    Color statusColor = HermezColors.warning;
    Color statusBackgroundColor = HermezColors.warningBackground;
    calculateRemainingTime();
    String stepTitle = "1";
    switch (step) {
      case 1:
        stepTitle = "1";
        status = "Initiated";
        statusColor = HermezColors.warning;
        statusBackgroundColor = HermezColors.warningBackground;
        break;
      case 2:
        stepTitle = "2";
        status = "On hold";
        statusColor = HermezColors.error;
        statusBackgroundColor = HermezColors.error;
        break;
      case 3:
        stepTitle = "2";
        status = "Pending";
        statusColor = HermezColors.warning;
        statusBackgroundColor = HermezColors.warningBackground;
        break;
    }

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

    return Container(
      padding: EdgeInsets.only(bottom: 15.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: HermezColors.darkTwo),
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Text("STEP $stepTitle/2",
                          style: TextStyle(
                            color: HermezColors.quaternary,
                            fontSize: 13,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      child: Text(
                          transactionLevel == TransactionLevel.LEVEL2
                              ? "Move to\nEthereum Wallet"
                              : "Move from\nHermez Wallet",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.3,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                    SizedBox(height: 8.0),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: statusBackgroundColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(status,
                          // On Hold, Pending
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 16,
                            fontFamily: 'ModernEra',
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    child: Text("",
                        style: TextStyle(
                          color: HermezColors.quaternary,
                          fontSize: 13,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    child: Text(
                        EthAmountFormatter.formatAmount(
                            double.parse(exit.balance) /
                                pow(10, exit.token.decimals),
                            exit.token.symbol),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text(
                        symbol +
                            (double.parse(exit.balance) /
                                    pow(10, exit.token.decimals) *
                                    exit.token.USD *
                                    (currency != "USD" ? exchangeRatio : 1))
                                .toStringAsFixed(2),
                        // On Hold, Pending
                        style: TextStyle(
                          color: HermezColors.quaternary,
                          fontSize: 16,
                          fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ],
              ),
            ]),
            Row(children: [
              step == 2
                  ? Expanded(
                      child: Container(
                      margin: EdgeInsets.only(top: 15, bottom: 15),
                      //width: double.infinity,
                      child: Divider(
                          color: Color(0x757a7c89), height: 0.5, thickness: 2),
                    ))
                  : Container(),
            ]),
            instantWithdrawAllowed && !state.withdrawalDelayer.emergencyMode ||
                    (!instantWithdrawAllowed &&
                        exit.delayedWithdrawRequest != null &&
                        calculateDelayedWithdrawRequestRemainingTime() == 0)
                ? Row(children: [
                    step == 2
                        ? Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                    child: RichText(
                                  text: TextSpan(
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                    children: [
                                      WidgetSpan(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 5.0),
                                          child: SvgPicture.asset(
                                              "assets/info.svg",
                                              width: 15,
                                              height: 15,
                                              color: HermezColors.quaternary),
                                        ),
                                      ),
                                      TextSpan(
                                          text: retry
                                              ? "There was an error\nprocessing the withdraw"
                                              : "Sign required to\nfinalize withdraw",
                                          style: TextStyle(
                                            color: HermezColors.quaternary,
                                            fontSize: 14,
                                            height: 1.43,
                                            fontFamily: 'ModernEra',
                                            fontWeight: FontWeight.w500,
                                          )),
                                    ],
                                  ),
                                )),
                              ],
                            ),
                          )
                        : Container(),
                    step == 2
                        ? Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                SizedBox(
                                  height: 42,
                                  child: FlatButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      side: BorderSide(
                                          color: instantWithdrawAllowed ||
                                                  (!instantWithdrawAllowed &&
                                                      exit.delayedWithdrawRequest !=
                                                          null &&
                                                      calculateDelayedWithdrawRequestRemainingTime() ==
                                                          0)
                                              ? HermezColors.secondary
                                              : HermezColors.quaternary
                                                  .withOpacity(0.5)),
                                    ),
                                    onPressed: () {
                                      this.onPressed(
                                          !instantWithdrawAllowed &&
                                              exit.delayedWithdrawRequest !=
                                                  null &&
                                              calculateDelayedWithdrawRequestRemainingTime() ==
                                                  0,
                                          instantWithdrawAllowed);
                                    },
                                    padding: EdgeInsets.only(
                                        top: 13.0,
                                        bottom: 13.0,
                                        right: 24.0,
                                        left: 24.0),
                                    color: instantWithdrawAllowed ||
                                            (!instantWithdrawAllowed &&
                                                exit.delayedWithdrawRequest !=
                                                    null &&
                                                calculateDelayedWithdrawRequestRemainingTime() ==
                                                    0)
                                        ? HermezColors.secondary
                                        : HermezColors.quaternary.withOpacity(0.5),
                                    textColor: Colors.white,
                                    child: Text(
                                        instantWithdrawAllowed ||
                                                (!instantWithdrawAllowed &&
                                                    exit.delayedWithdrawRequest !=
                                                        null &&
                                                    calculateDelayedWithdrawRequestRemainingTime() ==
                                                        0)
                                            ? (retry ? "Try again" : "Finalize")
                                            : "Withdraw in 1 hour",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'ModernEra',
                                          fontWeight: FontWeight.w700,
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                  ])
                : Column(
                    children: [
                      Row(children: [
                        Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
                                    color: HermezColors.quaternary.withOpacity(0.5)),
                                padding: EdgeInsets.only(
                                    left: 24.0,
                                    top: 20.0,
                                    right: 24.0,
                                    bottom: 24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.withdrawalDelayer.emergencyMode
                                          ? "Move will require a manual inspection.\n\n"
                                              "Your funds can stay on hold for a maximum period of 1 year."
                                          : exit.delayedWithdrawRequest != null
                                              ? "Your request to withdraw is validating with the network."
                                              : "Move is on hold because of the current network capacity.\n\n"
                                                  "You can try to move your funds later or you can schedule this transaction.",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        height: 1.5,
                                        fontFamily: 'ModernEra',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    !state.withdrawalDelayer.emergencyMode
                                        ? Container(
                                            margin: EdgeInsets.only(top: 20),
                                            child: RichText(
                                              text: TextSpan(
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2,
                                                children: [
                                                  WidgetSpan(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 5.0),
                                                      child: SvgPicture.asset(
                                                          "assets/info.svg",
                                                          width: 16,
                                                          height: 16,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                  TextSpan(
                                                      text: exit.delayedWithdrawRequest !=
                                                              null
                                                          ? "Remaining time : " +
                                                              calculateDelayedWithdrawRequestTime()
                                                                  .toString() +
                                                              " " +
                                                              withdrawDelayRequestPeriodTimeString()
                                                          : "Network update in " +
                                                              calculateRemainingTimeInPeriod()
                                                                  .toString() +
                                                              " " +
                                                              calculateRemainingTimePeriodString(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        height: 1.5,
                                                        fontFamily: 'ModernEra',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      )),
                                                ],
                                              ),
                                            ))
                                        : Container(),
                                  ],
                                )))
                      ]),
                      !state.withdrawalDelayer.emergencyMode &&
                              exit.delayedWithdrawRequest == null
                          ? Row(children: [
                              Expanded(
                                  child: Container(
                                margin: EdgeInsets.only(top: 15, bottom: 15),
                                //width: double.infinity,
                                child: Divider(
                                    color: Color(0x757a7c89),
                                    height: 0.5,
                                    thickness: 2),
                              ))
                            ])
                          : Container(),
                      /*!state.withdrawalDelayer.emergencyMode
                          ? Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 42,
                                    child: FlatButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        side: BorderSide(
                                            color: HermezColors.secondary),
                                      ),
                                      onPressed: () {
                                        //this.onPressed();
                                      },
                                      padding: EdgeInsets.only(
                                          top: 13.0,
                                          bottom: 13.0,
                                          right: 24.0,
                                          left: 24.0),
                                      color: HermezColors.secondary,
                                      textColor: Colors.white,
                                      child: Text("Check availability in 10m",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontFamily: 'ModernEra',
                                            fontWeight: FontWeight.w700,
                                          )),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      !state.withdrawalDelayer.emergencyMode
                          ? SizedBox(height: 15.0)
                          : Container(),*/
                      !state.withdrawalDelayer.emergencyMode &&
                              exit.delayedWithdrawRequest == null
                          ? Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 42,
                                    child: FlatButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        side: BorderSide(
                                            color: HermezColors.quaternary
                                                .withOpacity(0.5)),
                                      ),
                                      onPressed: () {
                                        this.onPressed(
                                            false, instantWithdrawAllowed);
                                      },
                                      padding: EdgeInsets.only(
                                          top: 13.0,
                                          bottom: 13.0,
                                          right: 24.0,
                                          left: 24.0),
                                      color:
                                          HermezColors.quaternary.withOpacity(0.5),
                                      textColor: Colors.white,
                                      child: Text(
                                          "Schedule Move (approx " +
                                              calculateWithdrawDelayTime()
                                                  .toString() +
                                              " " +
                                              withdrawDelayPeriodTimeString() +
                                              ")",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontFamily: 'ModernEra',
                                            fontWeight: FontWeight.w700,
                                          )),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  ),
            //title to be name of the crypto
          ],
        ),
      ),
    );
  }

  int calculateRemainingTime() {
    double exitAmount = double.parse(exit.balance) /
        pow(10, exit.token.decimals) *
        exit.token.USD;
    int bucketBlockLastUpdate;
    int bucketBlocksEachCheck;
    //this.state.network.lastBatch.timestamp
    double batchFrequencyTime = this.state.metrics.batchFrequency;

    int lastBatchNum = this.state.network.lastBatch.batchNum ?? 0;
    String lastBatchDate = this.state.network.lastBatch.timestamp ?? 0;

    int maxWaitingTime;
    int passedTime;
    Bucket bucket = this.state.rollup.buckets.firstWhere(
        (bucket) => double.parse(bucket.ceilUSD) > exitAmount,
        orElse: () => null);
    maxWaitingTime = 0;
    if (bucket != null) {
      bucketBlockLastUpdate = int.parse(bucket.blockStamp);
      bucketBlocksEachCheck = int.parse(bucket.rateBlocks);
      maxWaitingTime = (bucketBlocksEachCheck * batchFrequencyTime).toInt();
      print('LAST BATCH NUM: ' + lastBatchNum.toString());
      print('BLOCK LAST UPDATE NUM: ' + bucketBlockLastUpdate.toString());
      if (lastBatchNum >= bucketBlockLastUpdate) {
        int passedBlocks = lastBatchNum - bucketBlockLastUpdate;
        passedTime = (passedBlocks * batchFrequencyTime) ~/ 60;
        print('PASSED TIME: ' + (passedTime).toString());
      }
      print('REMAINING TIME: ' + (maxWaitingTime).toString());
    }
    return maxWaitingTime;
  }

  String calculateRemainingTimePeriodString() {
    int withdrawDelayTime = calculateRemainingTime();
    int correctTime =
        calculateDurationInCorrectTime(Duration(seconds: withdrawDelayTime));
    if (withdrawDelayTime < 60) {
      if (correctTime == 1) {
        return "second";
      } else {
        return "seconds";
      }
    } else if (withdrawDelayTime >= 60 && withdrawDelayTime < 3600) {
      // minutes
      if (correctTime == 1) {
        return "minute";
      } else {
        return "minutes";
      }
    } else if (withdrawDelayTime >= 3600 && withdrawDelayTime < 86400) {
      if (correctTime == 1) {
        return "hour";
      } else {
        return "hours";
      }
    } // hours
    else if (withdrawDelayTime >= 86400) {
      if (correctTime == 1) {
        return "day";
      } else {
        return "days";
      }
    }
  }

  int calculateDurationInCorrectTime(Duration duration) {
    if (duration.inSeconds < 60) {
      return duration.inSeconds;
    } else if (duration.inSeconds >= 60 && duration.inSeconds < 3600) {
      // minutes
      return duration.inMinutes;
    } else if (duration.inSeconds >= 3600 && duration.inSeconds < 86400) {
      return duration.inHours;
    } // hours
    else if (duration.inSeconds >= 86400) {
      return duration.inDays;
    } // days
  }

  int calculateRemainingTimeInPeriod() {
    Duration duration = Duration(seconds: calculateRemainingTime());
    return calculateDurationInCorrectTime(duration);
  }

  int calculateWithdrawDelayTime() {
    Duration duration =
        Duration(seconds: this.state.withdrawalDelayer.withdrawalDelay);
    return calculateDurationInCorrectTime(duration);
  }

  String withdrawDelayPeriodTimeString() {
    int withdrawDelayTime = calculateWithdrawDelayTime();
    if (this.state.withdrawalDelayer.withdrawalDelay < 60) {
      if (withdrawDelayTime == 1) {
        return "second";
      } else {
        return "seconds";
      }
    } else if (this.state.withdrawalDelayer.withdrawalDelay >= 60 &&
        this.state.withdrawalDelayer.withdrawalDelay < 3600) {
      // minutes
      if (withdrawDelayTime == 1) {
        return "minute";
      } else {
        return "minutes";
      }
    } else if (this.state.withdrawalDelayer.withdrawalDelay >= 3600 &&
        this.state.withdrawalDelayer.withdrawalDelay < 86400) {
      if (withdrawDelayTime == 1) {
        return "hour";
      } else {
        return "hours";
      }
    } // hours
    else if (this.state.withdrawalDelayer.withdrawalDelay >= 86400) {
      if (withdrawDelayTime == 1) {
        return "day";
      } else {
        return "days";
      }
    }
  }

  int calculateDelayedWithdrawRequestRemainingTime() {
    int requestBlockNum = 0;
    if (this.exit.delayedWithdrawRequest == null) {
      return 0;
    }
    int lastBlockNum = this.state.network.lastEthereumBlock;
    requestBlockNum = this.exit.delayedWithdrawRequest;
    double blockFrequencyTime = 13.0;
    // average block time ethereum
    int passedTime = 0;
    if (lastBlockNum >= requestBlockNum) {
      int passedBlocks = lastBlockNum - requestBlockNum;
      passedTime = (passedBlocks * blockFrequencyTime).toInt();
      print('PASSED TIME: ' + (passedTime).toString());
    }
    int maxTime = this.state.withdrawalDelayer.withdrawalDelay;
    print('MAX TIME: ' + (maxTime).toString());
    if (maxTime >= passedTime) {
      int remainingTime = maxTime - passedTime;
      return remainingTime;
    } else {
      return 0;
    }
  }

  int calculateDelayedWithdrawRequestTime() {
    Duration duration =
        Duration(seconds: calculateDelayedWithdrawRequestRemainingTime());
    return calculateDurationInCorrectTime(duration);
  }

  String withdrawDelayRequestPeriodTimeString() {
    int withdrawDelayTime = calculateDelayedWithdrawRequestRemainingTime();
    int correctTime = calculateDelayedWithdrawRequestTime();
    if (withdrawDelayTime < 60) {
      if (correctTime == 1) {
        return "second";
      } else {
        return "seconds";
      }
    } else if (withdrawDelayTime >= 60 && withdrawDelayTime < 3600) {
      // minutes
      if (correctTime == 1) {
        return "minute";
      } else {
        return "minutes";
      }
    } else if (withdrawDelayTime >= 3600 && withdrawDelayTime < 86400) {
      if (correctTime == 1) {
        return "hour";
      } else {
        return "hours";
      }
    } // hours
    else if (withdrawDelayTime >= 86400) {
      if (correctTime == 1) {
        return "day";
      } else {
        return "days";
      }
    }
  }
}
