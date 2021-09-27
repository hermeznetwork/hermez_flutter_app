import 'package:flutter/widgets.dart';

abstract class TransferState {
  final String searchTerm;

  TransferState(this.searchTerm);

  factory TransferState.loading({String searchTerm}) =>
      LoadingTransactionsState(searchTerm: searchTerm);

  factory TransferState.loaded(
          String searchTerm, List<TransactionItemState> transactions) =>
      LoadedTransferState(searchTerm: searchTerm, transactions: transactions);

  factory TransferState.error(String searchTerm, String message) =>
      ErrorTransferState(searchTerm: searchTerm, message: message);
}

class LoadingTransactionsState extends TransferState {
  LoadingTransactionsState({String searchTerm}) : super(searchTerm);
}

class LoadedTransferState extends TransferState {
  final List<TransactionItemState> transactions;

  LoadedTransferState({String searchTerm, @required this.transactions})
      : super(searchTerm);
}

class ErrorTransferState<T> extends TransferState {
  final String message;

  ErrorTransferState({@required String searchTerm, @required this.message})
      : super(searchTerm);
}

class TransactionItemState {
  final String id;
  final String image;
  final String title;
  final String price;

  TransactionItemState(this.id, this.image, this.title, this.price);
}
