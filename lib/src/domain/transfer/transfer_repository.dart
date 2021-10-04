import 'dart:collection';
import 'dart:typed_data';

import 'package:hermez/service/network/model/gas_price_response.dart';
import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez_sdk/model/exit.dart';
import 'package:hermez_sdk/model/recommended_fee.dart';
import 'package:hermez_sdk/model/token.dart';
import 'package:hermez_sdk/model/transaction.dart' as hezTransaction;

abstract class TransferRepository {
  Future<bool> deposit(double amount, Token token,
      {BigInt approveGasLimit, BigInt depositGasLimit, int gasPrice});

  Future<LinkedHashMap<String, BigInt>> depositGasLimit(
      double amount, Token token);

  Future<bool> withdraw(double amount, Exit exit,
      bool completeDelayedWithdrawal, bool instantWithdrawal,
      {BigInt gasLimit, int gasPrice = 0});

  Future<BigInt> withdrawGasLimit(double amount, Exit exit,
      bool completeDelayedWithdrawal, bool instantWithdrawal);

  Future<bool> isInstantWithdrawalAllowed(double amount, Token token);

  Future<BigInt> forceExitGasLimit(
      double amount, String accountIndex, Token token);

  Future<bool> forceExit(double amount, String accountIndex, Token token,
      {BigInt gasLimit, int gasPrice = 0});

  Future<bool> exit(
      double amount, String accountIndex, Token token, double fee);

  Future<bool> transfer(TransactionLevel level, String from, String to,
      double amount, Token token,
      {double fee, int gasLimit, int gasPrice});

  Future<bool> sendL2Transaction(hezTransaction.Transaction transaction);

  Future<RecommendedFee> getHermezFees();

  Future<GasPriceResponse> getGasPrice();

  Future<BigInt> getGasLimit(String from, String to, BigInt amount, Token token,
      {Uint8List data});
}