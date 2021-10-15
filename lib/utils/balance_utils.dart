import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hermez/src/domain/accounts/account.dart';
import 'package:hermez/src/domain/prices/price_token.dart';
import 'package:hermez/src/domain/tokens/token.dart';
import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez_sdk/tx_utils.dart';
import 'package:hermez_sdk/utils.dart';
import 'package:intl/intl.dart';

class BalanceUtils {
  static String amountInCurrency(
      double amount, String currency, double exchangeRatio) {
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

    if (currency != "USD") {
      amount *= exchangeRatio;
    }

    result = NumberFormat.currency(locale: locale, symbol: symbol)
        .format(getDoubleWithPrecision(amount));
    return result;
  }

  static String formatBalance(double amount, Token token,
      {bool toFiat = false,
      String currency = "USD",
      double exchangeRatio = 1}) {
    double value = (amount / pow(10, token.token.decimals));
    String result = "";
    if (toFiat) {
      value *= token.price.USD;
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

      if (currency != "USD") {
        value *= exchangeRatio;
      }

      result = NumberFormat.currency(locale: locale, symbol: symbol)
          .format(getDoubleWithPrecision(value));
    } else {}
    return result;
  }

  static String balanceOfAccounts(
      TransactionLevel txLevel,
      List<Account> _accounts,
      //WalletHandler store,
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
        Token token = account.token;
        PriceToken priceToken = token.price;
        if (priceToken.USD != null) {
          tokens.add(token);
          double value = priceToken.USD *
              account.totalBalance /
              pow(10, token.token.decimals);
          if (currency != "USD") {
            value *= exchangeRatio;
          }
          balanceAmount += value;
        }
      }
    }

    // calculate withdraws amount
    tokens.forEach((token) {
      PriceToken priceToken = token.price;
      if (txLevel == TransactionLevel.LEVEL2) {
        // Pending transfers and Pending Exits L2
        pendingWithdraws
            .takeWhile(
                (poolTransaction) => token.token.id == poolTransaction.token.id)
            .forEach((poolTransaction) {
          var amount = (getTokenAmountBigInt(
                  double.parse(poolTransaction.amount),
                  poolTransaction.token.decimals)
              .toDouble());
          var fee = getFeeValue(
                  poolTransaction.fee, double.parse(poolTransaction.amount))
              .toDouble();
          double value =
              priceToken.USD * ((amount + fee) / pow(10, token.token.decimals));
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
                (poolTransaction) => token.token.id == poolTransaction.token.id)
            .forEach((pendingTransfer) {
          //if (token.id == 0) {
          //rest fees
          //var fee = pendingTransfer['fee'] / pow(10, 3);
          //}
          var amount = double.parse(pendingTransfer['value']);
          var fee = 0;
          double value =
              priceToken.USD * ((amount + fee) / pow(10, token.token.decimals));
          if (currency != "USD") {
            value *= exchangeRatio;
          }
          withdrawsAmount += value;
        });
        pendingDeposits
            .takeWhile((pendingDeposit) =>
                token.token.id ==
                Token.fromJson(pendingDeposit['token']).token.id)
            .forEach((pendingDeposit) {
          /*historyTransactions.firstWhere(
            (forgedTransaction) =>
                forgedTransaction['txHash'] == pendingDeposit['hash'],
            orElse: () {*/
          if (pendingDeposit['id'] == null) {
            var amount = double.parse(pendingDeposit['value']);
            double value =
                priceToken.USD * (amount / pow(10, token.token.decimals));
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

  static double calculatePendingBalance(TransactionLevel txLevel,
      Account account, String symbol, //WalletHandler store,
      {List<dynamic> historyTransactions}) {
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
    double balanceAmount =
        account.totalBalance != null ? account.totalBalance : 0.0;
    double withdrawsAmount = 0;
    double depositsAmount = 0;
    Token token = account.token;
    PriceToken priceToken = token.price;
    if (txLevel == TransactionLevel.LEVEL2) {
      // Pending transfers and Pending Exits L2
      /*store.state.pendingL2Txs
          .takeWhile(
              (poolTransaction) => account.token.token.id == poolTransaction.token.id)
          .forEach((poolTransaction) {
        var amount = double.parse(poolTransaction.amount);
        var fee = getFeeValue(
                poolTransaction.fee, double.parse(poolTransaction.amount))
            .toDouble();
        withdrawsAmount += amount + fee;
      });
      store.state.pendingForceExits
          .takeWhile((pendingForceExit) =>
      account.accountIndex == pendingForceExit['accountIndex'])
          .forEach((pendingForceExit) {
        var amount = pendingForceExit['amount'];
        withdrawsAmount += amount;
      });*/

      // NOT INCLUDED
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

    } else {
      /*store.state.pendingL1Transfers
          .takeWhile((pendingDeposit) =>
              Token.fromJson(pendingDeposit['token']).symbol == token.symbol)
          .forEach((pendingTransfer) {
        if (historyTransactions != null) {
          historyTransactions.firstWhere(
              (forgedTransaction) =>
                  forgedTransaction['txHash'] == pendingTransfer['txHash'],
              orElse: () {
            var amount = double.parse(pendingTransfer['value']);
            if (account.tokenId == 0) {
              //rest fees
              //var fee = pendingTransfer['fee'] / pow(10, 3);
            }
            var fee = 0;
            withdrawsAmount += amount + fee;
          });
        } else {
          var amount = double.parse(pendingTransfer['value']);
          if (account.tokenId == 0) {
            //rest fees
            //var fee = pendingTransfer['fee'] / pow(10, 3);
          }
          var fee = 0;
          withdrawsAmount += amount + fee;
        }
      });
      store.state.pendingDeposits
          .takeWhile((pendingDeposit) =>
              Token.fromJson(pendingDeposit['token']).symbol == token.symbol)
          .forEach((pendingDeposit) {
        if (historyTransactions != null) {
          historyTransactions.firstWhere(
              (forgedTransaction) =>
                  forgedTransaction['txHash'] == pendingDeposit['txHash'],
              orElse: () {
            if (pendingDeposit['id'] == null) {
              var amount = double.parse(pendingDeposit['value']);
              withdrawsAmount += amount;
            }
          });
        } else {
          if (pendingDeposit['id'] == null) {
            var amount = double.parse(pendingDeposit['value']);
            withdrawsAmount += amount;
          }
        }
      });*/
    }

    debugPrint("balance amount:" + balanceAmount.toString());
    debugPrint("withdraws amount:" + withdrawsAmount.toString());
    debugPrint("deposits amount:" + depositsAmount.toString());
    resultAmount = balanceAmount - withdrawsAmount; //+ depositsAmount;

    if (resultAmount.isNegative) {
      resultAmount = 0.0;
    }

    if (isCurrency && priceToken.USD != null) {
      resultAmount = priceToken.USD * resultAmount;
      if (symbol != "USD") {
        //resultAmount *= store.state.exchangeRatio;
      }
    }

    return resultAmount;
  }
}
