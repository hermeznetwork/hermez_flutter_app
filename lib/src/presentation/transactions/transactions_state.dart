import 'package:flutter/widgets.dart';

abstract class TransactionsState {
  TransactionsState();

  factory TransactionsState.loading() => LoadingTransactionsState();

  factory TransactionsState.loaded(List<TransactionItemState> transactions) =>
      LoadedTransactionsState(transactions: transactions);

  factory TransactionsState.error(String message) =>
      ErrorTransactionsState(message: message);
}

class LoadingTransactionsState extends TransactionsState {
  LoadingTransactionsState();
}

class LoadedTransactionsState extends TransactionsState {
  final List<TransactionItemState> transactions;

  LoadedTransactionsState({@required this.transactions});
}

class ErrorTransactionsState<T> extends TransactionsState {
  final String message;

  ErrorTransactionsState({@required this.message});
}

class TransactionItemState {
  final String id;
  final String image;
  final String title;
  final String price;

  TransactionItemState(this.id, this.image, this.title, this.price);
}
