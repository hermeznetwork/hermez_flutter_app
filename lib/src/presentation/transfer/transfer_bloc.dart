import 'dart:collection';
import 'dart:typed_data';

import 'package:hermez/service/network/model/gas_price_response.dart';
import 'package:hermez/src/common/bloc/bloc.dart';
import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez/src/domain/transfer/usecases/deposit_use_case.dart';
import 'package:hermez/src/domain/transfer/usecases/exit_use_case.dart';
import 'package:hermez/src/domain/transfer/usecases/fee_use_case.dart';
import 'package:hermez/src/domain/transfer/usecases/force_exit_use_case.dart';
import 'package:hermez/src/domain/transfer/usecases/transfer_use_case.dart';
import 'package:hermez/src/domain/transfer/usecases/withdraw_use_case.dart';
import 'package:hermez/src/presentation/transfer/transfer_state.dart';
import 'package:hermez_sdk/model/exit.dart';
import 'package:hermez_sdk/model/recommended_fee.dart';
import 'package:hermez_sdk/model/token.dart';

class TransferBloc extends Bloc<TransferState> {
  final TransferUseCase _transferUseCase;
  final DepositUseCase _depositUseCase;
  final ExitUseCase _exitUseCase;
  final ForceExitUseCase _forceExitUseCase;
  final WithdrawUseCase _withdrawUseCase;
  final FeeUseCase _feeUseCase;

  TransferBloc(this._transferUseCase, this._depositUseCase, this._exitUseCase,
      this._forceExitUseCase, this._withdrawUseCase, this._feeUseCase) {
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

  Future<bool> deposit(double amount, Token token,
      {BigInt approveGasLimit, BigInt depositGasLimit, int gasPrice}) async {
    return _depositUseCase.deposit(amount, token,
        approveGasLimit: approveGasLimit,
        depositGasLimit: depositGasLimit,
        gasPrice: gasPrice);
    /*_transferUseCase.execute().then((products) {
      //changeState(TransferState.loaded(
      //    state.searchTerm, _mapTransactionsToState(products)));
    }).catchError((error) {
      changeState(TransferState.error(
          state.searchTerm, 'A network error has occurred'));
    });*/
  }

  Future<LinkedHashMap<String, BigInt>> depositGasLimit(
      double amount, Token token) async {
    return _depositUseCase.depositGasLimit(amount, token);
    /*_transferUseCase.execute().then((products) {
      //changeState(TransferState.loaded(
      //    state.searchTerm, _mapTransactionsToState(products)));
    }).catchError((error) {
      changeState(TransferState.error(
          state.searchTerm, 'A network error has occurred'));
    });*/
  }

  Future<bool> exit(
      double amount, String accountIndex, Token token, double fee) async {
    return _exitUseCase.execute(amount, accountIndex, token, fee);
    /*_transferUseCase.execute().then((products) {
      //changeState(TransferState.loaded(
      //    state.searchTerm, _mapTransactionsToState(products)));
    }).catchError((error) {
      changeState(TransferState.error(
          state.searchTerm, 'A network error has occurred'));
    });*/
  }

  Future<bool> forceExit(double amount, String accountIndex, Token token,
      {BigInt gasLimit, int gasPrice = 0}) async {
    return _forceExitUseCase.forceExit(amount, accountIndex, token,
        gasLimit: gasLimit, gasPrice: gasPrice);
    /*_transferUseCase.execute().then((products) {
      //changeState(TransferState.loaded(
      //    state.searchTerm, _mapTransactionsToState(products)));
    }).catchError((error) {
      changeState(TransferState.error(
          state.searchTerm, 'A network error has occurred'));
    });*/
  }

  Future<BigInt> forceExitGasLimit(
      double amount, String accountIndex, Token token) async {
    return _forceExitUseCase.forceExitGasLimit(amount, accountIndex, token);
    /*_transferUseCase.execute().then((products) {
      //changeState(TransferState.loaded(
      //    state.searchTerm, _mapTransactionsToState(products)));
    }).catchError((error) {
      changeState(TransferState.error(
          state.searchTerm, 'A network error has occurred'));
    });*/
  }

  Future<bool> withdraw(double amount, Exit exit,
      {bool completeDelayedWithdrawal = false,
      bool instantWithdrawal = true,
      BigInt gasLimit,
      int gasPrice = 0}) async {
    return _withdrawUseCase.withdraw(amount, exit,
        completeDelayedWithdrawal: completeDelayedWithdrawal,
        instantWithdrawal: instantWithdrawal,
        gasLimit: gasLimit,
        gasPrice: gasPrice);
    /*_transferUseCase.execute().then((products) {
      //changeState(TransferState.loaded(
      //    state.searchTerm, _mapTransactionsToState(products)));
    }).catchError((error) {
      changeState(TransferState.error(
          state.searchTerm, 'A network error has occurred'));
    });*/
  }

  Future<BigInt> withdrawGasLimit(double amount, Exit exit,
      {bool completeDelayedWithdrawal = false,
      bool instantWithdrawal = true}) async {
    return _withdrawUseCase.withdrawGasLimit(amount, exit,
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

  Future<bool> isInstantWithdrawalAllowed(double amount, Token token) {
    return _withdrawUseCase.isInstantWithdrawalAllowed(amount, token);
  }

  Future<RecommendedFee> getHermezFees() async {
    return await _feeUseCase.getHermezFees();
  }

  Future<GasPriceResponse> getGasPrice() async {
    return await _feeUseCase.getGasPrice();
  }

  Future<BigInt> getGasLimit(String from, String to, BigInt amount, Token token,
      {Uint8List data}) async {
    return await _feeUseCase.getGasLimit(from, to, amount, token, data: data);
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
