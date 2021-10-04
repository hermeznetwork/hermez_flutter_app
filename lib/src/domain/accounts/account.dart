import 'package:hermez/src/domain/tokens/token.dart';
import 'package:hermez/src/domain/transactions/transaction.dart';

class Account {
  final bool l2Account;
  final String address;
  final String bjj;
  final String accountIndex;
  final String balance;
  final List<Transaction> transactions;
  final Token token;
  final num totalBalance;
  final num totalPrice;

  Account(
      {this.l2Account,
      this.address,
      this.bjj,
      this.accountIndex,
      this.balance,
      this.transactions,
      this.token})
      : totalBalance = _calculateTotalBalance(transactions),
        totalPrice = _calculateTotalPrice(transactions);

  factory Account.createEmpty() {
    return Account();
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      l2Account: json['l2Account'],
      address: json['address'],
      bjj: json['bjj'],
      accountIndex: json['accountIndex'],
      balance: json['balance'],
      transactions: json['transactions'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
        'l2Account': l2Account,
        'address': address,
        'bjj': bjj,
        'accountIndex': accountIndex,
        'balance': balance,
        'transactions': transactions,
        'token': token,
      };

  static double _calculateTotalPrice(List<Transaction> transactions) {
    // TODO:
    return 0;
    /*final double price = items.fold(
        0, (accumulator, item) => accumulator + (item.quantity * item.price));

    return double.parse(price.toStringAsFixed(2));*/
  }

  static int _calculateTotalBalance(List<Transaction> transactions) {
    // TODO:
    return 0;
    //items.fold(0, (accumulator, item) => accumulator + item.quantity);
  }

  /*static double calculatePendingBalance(TransactionLevel txLevel,
      Account account, String symbol, WalletHandler store,
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
    double balanceAmount = double.parse(account.balance);
    double withdrawsAmount = 0;
    double depositsAmount = 0;
    Token token =
    store.state.tokens.firstWhere((token) => token.id == account.tokenId);
    PriceToken priceToken = store.state.priceTokens
        .firstWhere((priceToken) => priceToken.id == token.id);
    if (txLevel == TransactionLevel.LEVEL2) {
      // Pending transfers and Pending Exits L2
      store.state.pendingL2Txs
          .takeWhile(
              (poolTransaction) => account.tokenId == poolTransaction.token.id)
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
      store.state.pendingForceExits
          .takeWhile((pendingForceExit) =>
      account.accountIndex == pendingForceExit['accountIndex'])
          .forEach((pendingForceExit) {
        var amount = pendingForceExit['amount'];
        withdrawsAmount += amount;
      });
    } else {
      store.state.pendingL1Transfers
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
      });
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
        resultAmount *= store.state.exchangeRatio;
      }
    }

    return resultAmount;
  }*/
}