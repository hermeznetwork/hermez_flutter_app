import 'package:hermez/src/common/bloc/bloc.dart';
import 'package:hermez/src/domain/transactions/usecases/get_transactions_use_case.dart';
import 'package:hermez/src/presentation/transactions/transactions_state.dart';
import 'package:hermez/src/presentation/transfer/transfer_state.dart';
import 'package:hermez_sdk/model/transaction.dart';
import 'package:intl/intl.dart';

class TransferBloc extends Bloc<TransferState> {
  final TransferUseCase _transferUseCase;

  TransferBloc(this._transferUseCase) {
    changeState(TransferState.loading(searchTerm: ''));
  }

  void search(String searchTerm) {
    _transferUseCase.execute().then((products) {
      changeState(TransferState.loaded(
          state.searchTerm, _mapTransactionsToState(products)));
    }).catchError((error) {
      changeState(TransferState.error(
          state.searchTerm, 'A network error has occurred'));
    });
  }

  List<TransferState> _mapTransactionsToState(List<Transaction> transactions) {
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'es-ES');

    /*return transactions
        .map((transaction) => TransactionItemState(
            transaction.id,
            transaction.image,
            transaction.title,
            formatCurrency.format(transaction.price)))
        .toList();*/
    return null;
  }
}
