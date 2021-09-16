import 'package:hermez/src/common/bloc/bloc.dart';
import 'package:hermez/src/domain/transactions/get_transactions_use_case.dart';
import 'package:hermez/src/domain/wallets/get_wallets_use_case.dart';
import 'package:hermez/src/presentation/transactions/transactions_state.dart';
import 'package:hermez_sdk/model/transaction.dart';
import 'package:intl/intl.dart';

class WalletsBloc extends Bloc<WalletsState> {
  final GetWalletsUseCase _getWalletsUseCase;

  TransactionsBloc(this._getWalletsUseCase) {
    changeState(TransactionsState.loading(searchTerm: ''));
  }

  void search(String searchTerm) {
    _getTransactionsUseCase.execute().then((products) {
      changeState(TransactionsState.loaded(
          state.searchTerm, _mapTransactionsToState(products)));
    }).catchError((error) {
      changeState(TransactionsState.error(
          state.searchTerm, 'A network error has occurred'));
    });
  }

  List<TransactionItemState> _mapTransactionsToState(
      List<Transaction> transactions) {
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'es-ES');

    return transactions
        .map((transaction) => TransactionItemState(
            transaction.id,
            transaction.image,
            transaction.title,
            formatCurrency.format(transaction.price)))
        .toList();
  }
}
