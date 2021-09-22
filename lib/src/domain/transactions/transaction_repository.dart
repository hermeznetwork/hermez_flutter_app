import 'dart:collection';

import 'package:hermez_sdk/model/account.dart';
import 'package:hermez_sdk/model/exit.dart';
import 'package:hermez_sdk/model/forged_transaction.dart';
import 'package:hermez_sdk/model/forged_transactions_request.dart';
import 'package:hermez_sdk/model/forged_transactions_response.dart';
import 'package:hermez_sdk/model/pool_transaction.dart';
import 'package:hermez_sdk/model/recommended_fee.dart';
import 'package:hermez_sdk/model/token.dart';
import 'package:hermez_sdk/model/transaction.dart';

enum LayerFilter { ALL, L1, L2 }

abstract class TransactionRepository {
  // ALL
  Future<List<dynamic>> getTransactions(
      {LayerFilter layerFilter = LayerFilter.ALL, int tokenId = 0});

  Future<dynamic> getTransactionById(String transactionId,
      {LayerFilter layerFilter = LayerFilter.ALL});
  // L2
  Future<ForgedTransactionsResponse> getForgedTransactions(
      ForgedTransactionsRequest request);

  Future<ForgedTransaction> getForgedTransactionById(String transactionId);

  Future<List<PoolTransaction>> getPoolTransactions([String accountIndex]);

  Future<PoolTransaction> getPoolTransactionById(String transactionId);

  Future<List<Exit>> getExits(String hermezAddress,
      {bool onlyPendingWithdraws = true, int tokenId = -1});

  Future<Exit> getExit(String accountIndex, int batchNum);

  Future<List<dynamic>> getPendingForceExits();

  Future<List<dynamic>> getPendingWithdraws();

  Future<List<dynamic>> getPendingDeposits();

  Future<List<dynamic>> getPendingTransfers();

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

  Future<bool> transfer(double amount, Account from, Account to, double fee);

  Future<bool> sendL2Transaction(Transaction transaction);

  Future<RecommendedFee> fetchFees();
}
