import 'package:hermez/src/common/bloc/bloc.dart';
import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez/src/domain/transfer/usecases/deposit_use_case.dart';
import 'package:hermez/src/domain/transfer/usecases/exit_use_case.dart';
import 'package:hermez/src/domain/transfer/usecases/force_exit_use_case.dart';
import 'package:hermez/src/domain/transfer/usecases/transfer_use_case.dart';
import 'package:hermez/src/domain/transfer/usecases/withdraw_use_case.dart';
import 'package:hermez/src/presentation/transfer/transfer_state.dart';
import 'package:hermez_sdk/model/account.dart';
import 'package:hermez_sdk/model/exit.dart';
import 'package:hermez_sdk/model/token.dart';

class TransferBloc extends Bloc<TransferState> {
  final TransferUseCase _transferUseCase;
  final DepositUseCase _depositUseCase;
  final ExitUseCase _exitUseCase;
  final ForceExitUseCase _forceExitUseCase;
  final WithdrawUseCase _withdrawUseCase;

  TransferBloc(this._transferUseCase, this._depositUseCase, this._exitUseCase,
      this._forceExitUseCase, this._withdrawUseCase) {
    changeState(TransferState.loading(searchTerm: ''));
  }

  Future<bool> transfer(TransactionLevel level, String from, String to,
      double amount, Token token) async {
    return _transferUseCase.execute(level, from, to, amount, token);
    /*_transferUseCase.execute().then((products) {
      //changeState(TransferState.loaded(
      //    state.searchTerm, _mapTransactionsToState(products)));
    }).catchError((error) {
      changeState(TransferState.error(
          state.searchTerm, 'A network error has occurred'));
    });*/
  }

  Future<bool> deposit(double amount, Token token) async {
    return _depositUseCase.execute(amount, token);
    /*_transferUseCase.execute().then((products) {
      //changeState(TransferState.loaded(
      //    state.searchTerm, _mapTransactionsToState(products)));
    }).catchError((error) {
      changeState(TransferState.error(
          state.searchTerm, 'A network error has occurred'));
    });*/
  }

  Future<bool> exit(double amount, Account account, double fee) async {
    return _exitUseCase.execute(amount, account, fee);
    /*_transferUseCase.execute().then((products) {
      //changeState(TransferState.loaded(
      //    state.searchTerm, _mapTransactionsToState(products)));
    }).catchError((error) {
      changeState(TransferState.error(
          state.searchTerm, 'A network error has occurred'));
    });*/
  }

  Future<bool> forceExit(double amount, Account account) async {
    return _forceExitUseCase.execute(amount, account);
    /*_transferUseCase.execute().then((products) {
      //changeState(TransferState.loaded(
      //    state.searchTerm, _mapTransactionsToState(products)));
    }).catchError((error) {
      changeState(TransferState.error(
          state.searchTerm, 'A network error has occurred'));
    });*/
  }

  Future<bool> withdraw(double amount, Account account, Exit exit,
      {bool completeDelayedWithdrawal = false,
      bool instantWithdrawal = true}) async {
    return _withdrawUseCase.execute(amount, account, exit,
        completeDelayedWithdrawal: completeDelayedWithdrawal,
        instantWithdrawal: instantWithdrawal);
    /*_transferUseCase.execute().then((products) {
      //changeState(TransferState.loaded(
      //    state.searchTerm, _mapTransactionsToState(products)));
    }).catchError((error) {
      changeState(TransferState.error(
          state.searchTerm, 'A network error has occurred'));
    });*/
  }

  /*List<TransferState> _mapTransactionsToState(List<Transaction> transactions) {
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'es-ES');

    /*return transactions
        .map((transaction) => TransactionItemState(
            transaction.id,
            transaction.image,
            transaction.title,
            formatCurrency.format(transaction.price)))
        .toList();*/
    return null;
  }*/
}
