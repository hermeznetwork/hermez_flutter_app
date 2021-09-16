import 'package:flutter/widgets.dart';

abstract class TransactionsState {
  final String searchTerm;

  TransactionsState(this.searchTerm);

  factory TransactionsState.loading({String searchTerm}) =>
      LoadingTransactionsState(searchTerm: searchTerm);

  factory TransactionsState.loaded(
          String searchTerm, List<TransactionItemState> transactions) =>
      LoadedTransactionsState(
          searchTerm: searchTerm, transactions: transactions);

  factory TransactionsState.error(String searchTerm, String message) =>
      ErrorTransactionsState(searchTerm: searchTerm, message: message);
}

class LoadingTransactionsState extends TransactionsState {
  LoadingTransactionsState({String searchTerm}) : super(searchTerm);
}

class LoadedTransactionsState extends TransactionsState {
  final List<TransactionItemState> transactions;

  LoadedTransactionsState({String searchTerm, @required this.transactions})
      : super(searchTerm);
}

class ErrorTransactionsState<T> extends TransactionsState {
  final String message;

  ErrorTransactionsState({@required String searchTerm, @required this.message})
      : super(searchTerm);
}

class TransactionItemState {
  final String id;
  final String image;
  final String title;
  final String price;

  TransactionItemState(this.id, this.image, this.title, this.price);
}
