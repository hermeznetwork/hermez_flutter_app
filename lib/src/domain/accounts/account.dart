import 'package:hermez/src/domain/prices/price_token.dart';
import 'package:hermez_sdk/model/token.dart';
import 'package:hermez_sdk/model/transaction.dart';

class Account {
  final bool l2Account;
  final String address;
  final String bjj;
  final String accountIndex;
  final String balance;
  final List<dynamic> transactions;
  final Token token;
  final PriceToken price;
  final num totalBalance;
  final num totalPrice;

  Account(
      {this.l2Account,
      this.address,
      this.bjj,
      this.accountIndex,
      this.balance,
      this.transactions,
      this.token,
      this.price})
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
      price: json['price'],
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
        'price': price,
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
    return 0; // items.fold(0, (accumulator, item) => accumulator + item.quantity);
  }
}
