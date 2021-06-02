import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez_plugin/model/account.dart';
import 'package:hermez_plugin/model/exit.dart';
import 'package:hermez_plugin/model/pool_transaction.dart';
import 'package:hermez_plugin/model/token.dart';
import 'package:hermez_plugin/tx_utils.dart';
import 'package:hermez_plugin/utils.dart';
import 'package:intl/intl.dart';

class BalanceUtils {
  static String balanceOfAccounts(
      TransactionLevel txLevel,
      List<Account> _accounts,
      String currency,
      double exchangeRatio,
      List<dynamic> pendingWithdraws,
      List<dynamic> pendingDeposits) {
    Set<Token> tokens = Set();
    double resultAmount = 0.0;
    double balanceAmount = 0.0;
    double withdrawsAmount = 0.0;
    //double depositsAmount = 0.0;
    String result = "";
    String locale = "";
    String symbol = "";
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

    // calculate accounts amount
    if (_accounts != null && _accounts.length > 0) {
      for (Account account in _accounts) {
        if (account.token.USD != null) {
          tokens.add(account.token);
          double value = account.token.USD *
              double.parse(account.balance) /
              pow(10, account.token.decimals);
          if (currency != "USD") {
            value *= exchangeRatio;
          }
          balanceAmount += value;
        }
      }
    }

    // calculate withdraws amount
    tokens.forEach((token) {
      if (txLevel == TransactionLevel.LEVEL2) {
        // Pending transfers and Pending Exits L2
        pendingWithdraws
            .takeWhile(
                (poolTransaction) => token.id == poolTransaction.token.id)
            .forEach((poolTransaction) {
          var amount = (getTokenAmountBigInt(
                  double.parse(poolTransaction.amount),
                  poolTransaction.token.decimals)
              .toDouble());
          var fee = getFeeValue(
                  poolTransaction.fee, double.parse(poolTransaction.amount))
              .toDouble();
          double value = token.USD * ((amount + fee) / pow(10, token.decimals));
          if (currency != "USD") {
            value *= exchangeRatio;
          }
          withdrawsAmount += value;
        });
        /*pendingDeposits
            .takeWhile((pendingDeposit) =>
                token.id == Token.fromJson(pendingDeposit['token']).id)
            .forEach((pendingDeposit) {
          var amount = pendingDeposit['amount'];
          double value = token.USD * amount / pow(10, token.decimals);
          if (currency != "USD") {
            value *= exchangeRatio;
          }
          depositsAmount += value;
        });*/
      } else {
        pendingWithdraws
            .takeWhile(
                (poolTransaction) => token.id == poolTransaction.token.id)
            .forEach((pendingTransfer) {
          //if (token.id == 0) {
          //rest fees
          //var fee = pendingTransfer['fee'] / pow(10, 3);
          //}
          var amount = pendingTransfer['amount'];
          var fee = 0;
          double value = token.USD * ((amount + fee) / pow(10, token.decimals));
          if (currency != "USD") {
            value *= exchangeRatio;
          }
          withdrawsAmount += value;
        });
        pendingDeposits
            .takeWhile((pendingDeposit) =>
                token.id == Token.fromJson(pendingDeposit['token']).id)
            .forEach((pendingDeposit) {
          /*historyTransactions.firstWhere(
            (forgedTransaction) =>
                forgedTransaction['txHash'] == pendingDeposit['hash'],
            orElse: () {*/
          if (pendingDeposit['id'] == null) {
            var amount = pendingDeposit['amount'];
            double value = token.USD * (amount / pow(10, token.decimals));
            if (currency != "USD") {
              value *= exchangeRatio;
            }
            withdrawsAmount += value;
          }
          //});
        });
      }
    });

    /*if (txLevel == TransactionLevel.LEVEL2) {
      // missing pending deposits without an account yet
      pendingDeposits
          .where((pendingDeposit) =>
              tokens.firstWhere(
                  (token) =>
                      token.id == Token.fromJson(pendingDeposit['token']).id,
                  orElse: () => null) ==
              null)
          .forEach((pendingDeposit) {
        Token token = Token.fromJson(pendingDeposit['token']);
        var amount = pendingDeposit['amount'];
        double value = token.USD * (amount / pow(10, token.decimals));
        if (currency != "USD") {
          value *= exchangeRatio;
        }
        depositsAmount += value;
      });
    }*/

    resultAmount = balanceAmount - withdrawsAmount;
    debugPrint("balance amount:" + balanceAmount.toString());
    debugPrint("withdraws amount:" + withdrawsAmount.toString());
    //debugPrint("deposits amount:" + depositsAmount.toString());
    debugPrint(
        "result amount:" + getDoubleWithPrecision(resultAmount).toString());
    result = NumberFormat.currency(locale: locale, symbol: symbol)
        .format(getDoubleWithPrecision(resultAmount));
    return result;
  }

  static double getDoubleWithPrecision(double input, {int precision = 2}) =>
      (input * pow(10, precision)).truncateToDouble() / pow(10, precision);

  static double calculatePendingBalance(
      TransactionLevel txLevel,
      double balance,
      Token token,
      String symbol,
      String accountIndex,
      double exchangeRatio,
      List<PoolTransaction> pendingL2Txs,
      List<dynamic> pendingL1Transfers,
      List<Exit> exits,
      List<dynamic> pendingWithdraws,
      List<dynamic> pendingDeposits,
      List<dynamic> pendingForceExits) {
    bool isCurrency = false;
    if (symbol == "EUR") {
      isCurrency = true;
    } else if (symbol == "CNY") {
      isCurrency = true;
    } else if (symbol == "JPY") {
      isCurrency = true;
    } else if (symbol == "GBP") {
      isCurrency = true;
    } else if (symbol == "USD") {
      isCurrency = true;
    }
    double resultAmount = 0;
    double balanceAmount = balance;
    double withdrawsAmount = 0;
    double depositsAmount = 0;
    if (txLevel == TransactionLevel.LEVEL2) {
      // Pending transfers and Pending Exits L2
      pendingL2Txs
          .takeWhile((poolTransaction) => token.id == poolTransaction.token.id)
          .forEach((poolTransaction) {
        var amount = double.parse(poolTransaction.amount);
        var fee = getFeeValue(
                poolTransaction.fee, double.parse(poolTransaction.amount))
            .toDouble();
        withdrawsAmount += amount + fee;
      });
      /*exits
          .takeWhile((exit) => accountIndex == exit.accountIndex)
          .forEach((exit) {
        var amount = double.parse(exit.balance);
        withdrawsAmount += amount;
      });*/
      /*pendingWithdraws
          .takeWhile((pendingWithdraw) =>
              accountIndex == pendingWithdraw['accountIndex'])
          .forEach((pendingWithdraw) {
        var amount = pendingWithdraw['amount'];
        withdrawsAmount += amount;
      });*/
      pendingForceExits
          .takeWhile((pendingForceExit) =>
              accountIndex == pendingForceExit.accountIndex)
          .forEach((pendingForceExit) {
        var amount = pendingForceExit['amount'];
        withdrawsAmount += amount;
      });
    } else {
      pendingL1Transfers.forEach((pendingTransfer) {
        var amount = pendingTransfer['amount'];

        if (token.id == 0) {
          //rest fees
          //var fee = pendingTransfer['fee'] / pow(10, 3);
        }
        var fee = 0;
        withdrawsAmount += amount + fee;
      });
      pendingDeposits
          .takeWhile((pendingDeposit) =>
              Token.fromJson(pendingDeposit['token']).symbol == token.symbol)
          .forEach((pendingDeposit) {
        /*historyTransactions.firstWhere(
            (forgedTransaction) =>
                forgedTransaction['txHash'] == pendingDeposit['hash'],
            orElse: () {*/
        if (pendingDeposit['id'] == null) {
          var amount = pendingDeposit['amount'];
          withdrawsAmount += amount;
        }
        //});
      });
    }

    debugPrint("balance amount:" + balanceAmount.toString());
    debugPrint("withdraws amount:" + withdrawsAmount.toString());
    debugPrint("deposits amount:" + depositsAmount.toString());
    resultAmount = balanceAmount - withdrawsAmount; //+ depositsAmount;

    if (resultAmount.isNegative) {
      resultAmount = 0.0;
    }

    if (isCurrency && token.USD != null) {
      resultAmount = token.USD * resultAmount;
      if (symbol != "USD") {
        resultAmount *= exchangeRatio;
      }
    }

    return resultAmount;
  }

  /*static String calculatePendingBalance(
      TransactionLevel txLevel, double balance, Token token, String symbol) {
    bool isCurrency = false;
    if (symbol == "EUR") {
      isCurrency = true;
    } else if (symbol == "CNY") {
      isCurrency = true;
    } else if (symbol == "JPY") {
      isCurrency = true;
    } else if (symbol == "GBP") {
      isCurrency = true;
    } else if (symbol == "USD") {
      isCurrency = true;
    }
    double resultAmount = 0;
    double balanceAmount = balance / pow(10, token.decimals);
    double withdrawsAmount = 0;
    double depositsAmount = 0;
    if (txLevel == TransactionLevel.LEVEL2) {
      pendingTransfers.forEach((poolTransaction) {
        var amount = (getTokenAmountBigInt(
                    double.parse(poolTransaction.amount) /
                        pow(10, token.decimals),
                    token.decimals)
                .toDouble() /
            pow(10, token.decimals));
        var fee = getFeeValue(
                    poolTransaction.fee, double.parse(poolTransaction.amount))
                .toDouble() /
            pow(10, token.decimals);
        withdrawsAmount = withdrawsAmount + amount + fee;
      });
      pendingExits.forEach((poolTransaction) {
        var amount = (getTokenAmountBigInt(
                    double.parse(poolTransaction.amount) /
                        pow(10, token.decimals),
                    token.decimals)
                .toDouble() /
            pow(10, token.decimals));
        var fee = getFeeValue(
                    poolTransaction.fee, double.parse(poolTransaction.amount))
                .toDouble() /
            pow(10, token.decimals);
        withdrawsAmount = withdrawsAmount + amount + fee;
      });
      pendingDeposits.forEach((pendingDeposit) {
        var amount = pendingDeposit['amount'] / pow(10, token.decimals);
        depositsAmount = depositsAmount + amount;
      });
    } else {
      pendingTransfers.forEach((pendingTransfer) {
        var amount = pendingTransfer['amount'] / pow(10, token.decimals);

        if (token.id == 0) {
          //rest fees
          //var fee = pendingTransfer['fee'] / pow(10, 3);
        }
        var fee = 0;
        withdrawsAmount = withdrawsAmount + amount + fee;
      });
      pendingDeposits.forEach((pendingDeposit) {
        historyTransactions.firstWhere(
            (forgedTransaction) =>
                forgedTransaction['txHash'] == pendingDeposit['hash'],
            orElse: () {
          var amount = pendingDeposit['amount'] / pow(10, token.decimals);
          withdrawsAmount = withdrawsAmount + amount;
        });
      });
    }

    debugPrint("balance amount:" + balanceAmount.toString());
    debugPrint("withdraws amount:" + withdrawsAmount.toString());
    debugPrint("deposits amount:" + depositsAmount.toString());
    resultAmount = balanceAmount - withdrawsAmount + depositsAmount;

    if (resultAmount.isNegative) {
      resultAmount = 0.0;
    }

    if (isCurrency && token.USD != null) {
      resultAmount = token.USD * resultAmount;
      if (symbol != "USD") {
        resultAmount *= widget.arguments.store.state.exchangeRatio;
      }
    }

    return EthAmountFormatter.formatAmount(resultAmount, symbol);
  }*/
}
