import 'package:hermez/src/domain/accounts/account.dart';

class Wallet {
  final String l1Address;
  final String l2Address;
  final List<Account> accounts;
  final List<dynamic> pendingTransactions;
  final num totalL1Balance;
  final num totalL1Price;
  final num totalL2Balance;
  final num totalL2Price;

  Wallet(
      {this.l1Address, this.l2Address, this.accounts, this.pendingTransactions})
      : totalL1Balance =
            _calculateTotalBalance(false, accounts, pendingTransactions),
        totalL1Price =
            _calculateTotalPrice(false, accounts, pendingTransactions),
        totalL2Balance =
            _calculateTotalBalance(true, accounts, pendingTransactions),
        totalL2Price =
            _calculateTotalPrice(true, accounts, pendingTransactions);

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      accounts: json['accounts'],
      pendingTransactions: json['pendingTransactions'],
    );
  }

  Map<String, dynamic> toJson() => {
        'accounts': accounts,
        'pendingTransactions': pendingTransactions,
      };

  static double _calculateTotalPrice(
      bool layer2, List<Account> accounts, List<dynamic> pendingTransactions) {
    // TODO:
    return 0;
    /*final double price = items.fold(
        0, (accumulator, item) => accumulator + (item.quantity * item.price));

    return double.parse(price.toStringAsFixed(2));*/
  }

  static int _calculateTotalBalance(
      bool layer2, List<Account> accounts, List<dynamic> pendingTransactions) {
    // TODO:
    return 0; // items.fold(0, (accumulator, item) => accumulator + item.quantity);
  }
}
