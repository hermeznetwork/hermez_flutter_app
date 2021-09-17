import 'package:hermez/src/domain/accounts/account.dart';

class Wallet {
  final String l1Address;
  final String l2Address;
  final List<Account> l1Accounts;
  final List<Account> l2Accounts;
  final List<dynamic> pendingTransactions;
  final num totalL1Balance;
  final num totalL2Balance;

  Wallet(
      {this.l1Address,
      this.l2Address,
      this.l1Accounts,
      this.l2Accounts,
      this.pendingTransactions})
      : totalL1Balance =
            _calculateTotalBalance(false, l1Accounts, pendingTransactions),
        totalL2Balance =
            _calculateTotalBalance(true, l2Accounts, pendingTransactions);

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      l1Address: json['l1Address'],
      l2Address: json['l2Address'],
      l1Accounts: json['l1Accounts'],
      l2Accounts: json['l2Accounts'],
      pendingTransactions: json['pendingTransactions'],
    );
  }

  Map<String, dynamic> toJson() => {
        'l1Address': l1Address,
        'l2Address': l2Address,
        'l1Accounts': l1Accounts,
        'l2Accounts': l2Accounts,
        'pendingTransactions': pendingTransactions,
      };

  static double _calculateTotalBalance(
      bool layer2, List<Account> accounts, List<dynamic> pendingTransactions) {
    // TODO:
    return 0;
    /*final double price = items.fold(
        0, (accumulator, item) => accumulator + (item.quantity * item.price));

    return double.parse(price.toStringAsFixed(2));*/
  }

  /*String totalBalance(TransactionLevel txLevel, List<Account> _accounts) {
    double resultValue = 0;
    String result = "";
    String locale = "";
    String symbol = "";
    final String currency =
        widget.arguments.store.state.defaultCurrency.toString().split('.').last;
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

    result = BalanceUtils.balanceOfAccounts(
        txLevel,
        _accounts,
        widget.arguments.store,
        currency,
        widget.arguments.store.state.exchangeRatio,
        pendingWithdraws,
        pendingDeposits);
    /*if (_accounts != null && _accounts.length > 0) {
      for (Account account in _accounts) {
        if (account.token.USD != null) {
          double value = account.token.USD * double.parse(account.balance);
          if (currency != "USD") {
            value *= widget.arguments.store.state.exchangeRatio;
          }
          resultValue += value;
        }
      }
    }
    //result += (resultValue / pow(10, 18)).toStringAsFixed(2);
    result = NumberFormat.currency(locale: locale, symbol: symbol)
        .format(resultValue / pow(10, 18));*/
    return result;
  }*/
}
