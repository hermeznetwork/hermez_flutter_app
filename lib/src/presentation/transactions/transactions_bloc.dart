import 'package:hermez/src/common/bloc/bloc.dart';
import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez/src/domain/transactions/usecases/get_transactions_use_case.dart';
import 'package:hermez/src/presentation/transactions/transactions_state.dart';
import 'package:intl/intl.dart';

class TransactionsBloc extends Bloc<TransactionsState> {
  final GetAllTransactionsUseCase _getAllTransactionsUseCase;

  TransactionsBloc(this._getAllTransactionsUseCase) {
    changeState(TransactionsState.loading());
  }

  void getAllTransactions() {
    _getAllTransactionsUseCase.execute().then((transactions) {
      changeState(
          TransactionsState.loaded(_mapTransactionsToState(transactions)));
    }).catchError((error) {
      changeState(TransactionsState.error('A network error has occurred'));
    });
  }

  List<TransactionItemState> _mapTransactionsToState(
      List<Transaction> transactions) {
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
