import 'dart:collection';

import 'package:hermez/src/domain/transfer/transfer_repository.dart';
import 'package:hermez_sdk/model/token.dart';

class DepositUseCase {
  final TransferRepository _transferRepository;

  DepositUseCase(this._transferRepository);

  Future<bool> deposit(double amount, Token token,
      {BigInt approveGasLimit, BigInt depositGasLimit, int gasPrice}) {
    return _transferRepository.deposit(amount, token,
        approveGasLimit: approveGasLimit,
        depositGasLimit: depositGasLimit,
        gasPrice: gasPrice);
  }

  Future<LinkedHashMap<String, BigInt>> depositGasLimit(
      double amount, Token token) async {
    return _transferRepository.depositGasLimit(amount, token);
  }
}
