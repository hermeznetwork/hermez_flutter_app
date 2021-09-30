import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

import 'package:hermez/service/network/model/gas_price_response.dart';
import 'package:hermez/src/data/network/contract_service.dart';
import 'package:hermez/src/data/network/hermez_service.dart';
import 'package:hermez/src/domain/prices/price_token.dart';
import 'package:hermez/src/domain/transactions/transaction.dart';
import 'package:hermez/src/domain/transfer/transfer_repository.dart';
import 'package:hermez/src/domain/wallets/wallet.dart';
import 'package:hermez_sdk/hermez_compressed_amount.dart';
import 'package:hermez_sdk/model/account.dart';
import 'package:hermez_sdk/model/exit.dart';
import 'package:hermez_sdk/model/recommended_fee.dart';
import 'package:hermez_sdk/model/token.dart';
import 'package:hermez_sdk/model/transaction.dart' as hezTransaction;
import 'package:web3dart/web3dart.dart' as web3;

class TransferInNetworkRepository implements TransferRepository {
  final HermezService _hermezService;
  final ContractService _contractService;
  TransferInNetworkRepository(this._hermezService, this._contractService);

  // Transactions Operations

  @override
  Future<LinkedHashMap<String, BigInt>> depositGasLimit(
      double amount, Token token) async {
    return _hermezService.depositGasLimit(amount, token);
  }

  @override
  Future<bool> deposit(double amount, Token token,
      {BigInt approveGasLimit, BigInt depositGasLimit, int gasPrice}) async {
    return _hermezService.deposit(amount, token,
        approveGasLimit: approveGasLimit,
        depositGasLimit: depositGasLimit,
        gasPrice: gasPrice);
  }

  @override
  Future<BigInt> withdrawGasLimit(double amount, Account account, Exit exit,
      bool completeDelayedWithdrawal, bool instantWithdrawal) async {
    return _hermezService.withdrawGasLimit(
        amount, account, exit, completeDelayedWithdrawal, instantWithdrawal);
  }

  @override
  Future<bool> withdraw(double amount, Account account, Exit exit,
      bool completeDelayedWithdrawal, bool instantWithdrawal,
      {BigInt gasLimit, int gasPrice = 0}) async {
    final success = await _hermezService.withdraw(
        amount, account, exit, completeDelayedWithdrawal, instantWithdrawal,
        gasLimit: gasLimit, gasPrice: gasPrice);
    return success;
  }

  @override
  Future<bool> isInstantWithdrawalAllowed(double amount, Token token) async {
    final success =
        await _hermezService.isInstantWithdrawalAllowed(amount, token);
    return success;
  }

  @override
  Future<BigInt> forceExitGasLimit(double amount, Account account) async {
    return _hermezService.forceExitGasLimit(amount, account);
  }

  @override
  Future<bool> forceExit(double amount, Account account,
      {BigInt gasLimit, int gasPrice = 0}) async {
    return _hermezService.forceExit(amount, account,
        gasLimit: gasLimit, gasPrice: gasPrice);
  }

  @override
  Future<bool> exit(double amount, Account account, double fee) async {
    final exitTx = {
      'from': account.accountIndex,
      'type': 'Exit',
      'amount': HermezCompressedAmount.compressAmount(amount),
      'fee': fee,
    };
    final success =
        await _hermezService.generateAndSendL2Tx(exitTx, account.tokenId);
    return success;
  }

  @override
  Future<bool> transfer(TransactionLevel level, String from, String to,
      double amount, Token token,
      {double fee, int gasLimit, int gasPrice}) async {
    if (level == TransactionLevel.LEVEL2) {
      final transferTx = {
        'from': from,
        'to': to,
        'amount': HermezCompressedAmount.compressAmount(amount),
        'fee': fee,
      };
      final success =
          await _hermezService.generateAndSendL2Tx(transferTx, token.id);
      return success;
    } else {
      return await _contractService.transfer(
        to,
        BigInt.from(amount * pow(10, token.decimals)),
        token,
        gasLimit: gasLimit,
        gasPrice: gasPrice,
      );
    }
  }

  /*@override
  Future<bool> transfer(
      double amount, Account from, Account to, double fee) async {
    final transferTx = {
      'from': from.accountIndex,
      'to': to.accountIndex != null
          ? to.accountIndex
          : to.hezEthereumAddress != null
              ? to.hezEthereumAddress
              : to.bjj,
      'amount': HermezCompressedAmount.compressAmount(amount),
      'fee': fee,
    };
    final success =
        await _hermezService.generateAndSendL2Tx(transferTx, from.tokenId);
    return success;
  }*/

  /*Future<bool> transfer(
      String privateKey, String to, String amount, Token token,
      {int gasLimit, int gasPrice}) async {
    //_store.dispatch(WalletTransferStarted());
    return await _contractService.transfer(
      privateKey,
      EthereumAddress.fromHex(to),
      BigInt.from(double.parse(amount) * pow(10, token.decimals)),
      token,
      gasLimit: gasLimit,
      gasPrice: gasPrice,
    );
  }*/

  @override
  Future<bool> sendL2Transaction(hezTransaction.Transaction transaction) async {
    final result = await _hermezService.sendL2Transaction(transaction);
    return result;
  }

  /// Fetches the recommended fees from the Coordinator
  /// @returns {RecommendedFee}
  @override
  Future<RecommendedFee> fetchFees() {
    return _hermezService.getRecommendedFee();
  }

  /// Calculates the fee for the transaction.
  /// It takes the appropriate recomended fee in USD from the coordinator
  /// and converts it to token value.
  /// @param {Object} fees - The recommended Fee object returned by the Coordinator
  /// @param {Boolean} iExistingAccount - Whether it's a existingAccount transfer
  /// @returns {number} - Transaction fee
  double getFee(RecommendedFee fees, bool isExistingAccount, PriceToken token,
      TransactionType transactionType) {
    if (token.USD == 0) {
      return 0;
    }

    final fee = (isExistingAccount ||
            transactionType == TransactionType.EXIT ||
            transactionType == TransactionType.FORCEEXIT)
        ? fees.existingAccount
        : fees.createAccount;

    return double.parse((fee / token.USD).toStringAsFixed(6));
  }

  Future<GasPriceResponse> getGasPrice() async {
    GasPriceResponse gasPrice = await _contractService.getGasPrice();
    return gasPrice;
  }

  Future<BigInt> getGasLimit(String from, String to, BigInt amount, Token token,
      {Uint8List data}) async {
    web3.EthereumAddress fromAddress;
    web3.EthereumAddress toAddress;
    if (from != null && from.isNotEmpty) {
      fromAddress = web3.EthereumAddress.fromHex(from);
    }
    if (to != null && to.isNotEmpty) {
      toAddress = web3.EthereumAddress.fromHex(to);
    }

    BigInt maxGas = await _contractService.getEstimatedGas(
        fromAddress, toAddress, amount, data, token);
    return maxGas;
  }

  Future<BigInt> getEstimatedGas(String from, String to, BigInt amount,
      Token token, WalletDefaultFee feeSpeed,
      {Uint8List data}) async {
    web3.EthereumAddress fromAddress;
    web3.EthereumAddress toAddress;
    if (from != null && from.isNotEmpty) {
      fromAddress = web3.EthereumAddress.fromHex(from);
    }
    if (to != null && to.isNotEmpty) {
      toAddress = web3.EthereumAddress.fromHex(to);
    }
    GasPriceResponse gasPriceResponse = await getGasPrice();
    BigInt maxGas = await _contractService.getEstimatedGas(
        fromAddress, toAddress, amount, data, token);

    BigInt gasPrice = BigInt.zero;
    switch (feeSpeed) {
      case WalletDefaultFee.SLOW:
        gasPrice = BigInt.from(gasPriceResponse.safeLow * pow(10, 8));
        break;
      case WalletDefaultFee.AVERAGE:
        gasPrice = BigInt.from(gasPriceResponse.average * pow(10, 8));
        break;
      case WalletDefaultFee.FAST:
        gasPrice = BigInt.from(gasPriceResponse.fast * pow(10, 8));
        break;
    }

    BigInt estimatedFee = gasPrice * maxGas;

    return estimatedFee;
  }

  /*@override
  Future<bool> isInstantWithdrawalAllowed(double amount, Token token) async {
    final success =
    await _hermezService.isInstantWithdrawalAllowed(amount, token);
    return success;
  }*/

  /*List<Exit> exits = await getExits();
  List<PoolTransaction> pendingL2Txs = await getPoolTransactions();
  List<dynamic> pendingL1Transfers = await getPendingTransfers();
  List<dynamic> pendingDeposits = await getPendingDeposits();
  List<dynamic> pendingWithdraws = await getPendingWithdraws();
  List<dynamic> pendingForceExits = await getPendingForceExits();*/
}
