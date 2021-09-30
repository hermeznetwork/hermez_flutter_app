import 'dart:collection';

import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez_sdk/model/account.dart';
import 'package:hermez_sdk/model/exit.dart';
import 'package:hermez_sdk/model/recommended_fee.dart';
import 'package:hermez_sdk/model/token.dart';
import 'package:hermez_sdk/model/transaction.dart' as hezTransaction;

abstract class TransferRepository {
  Future<LinkedHashMap<String, BigInt>> depositGasLimit(
      double amount, Token token);

  Future<bool> deposit(double amount, Token token,
      {BigInt approveGasLimit, BigInt depositGasLimit, int gasPrice});

  Future<BigInt> withdrawGasLimit(double amount, Account account, Exit exit,
      bool completeDelayedWithdrawal, bool instantWithdrawal);

  Future<bool> withdraw(double amount, Account account, Exit exit,
      bool completeDelayedWithdrawal, bool instantWithdrawal,
      {BigInt gasLimit, int gasPrice = 0});

  Future<bool> isInstantWithdrawalAllowed(double amount, Token token);

  Future<BigInt> forceExitGasLimit(double amount, Account account);

  Future<bool> forceExit(double amount, Account account,
      {BigInt gasLimit, int gasPrice = 0});

  Future<bool> exit(double amount, Account account, double fee);

  Future<bool> transfer(TransactionLevel level, String from, String to,
      double amount, Token token,
      {double fee, int gasLimit, int gasPrice});

  Future<bool> sendL2Transaction(hezTransaction.Transaction transaction);

  Future<RecommendedFee> fetchFees();
}
