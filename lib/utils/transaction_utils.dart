import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez_sdk/hermez_compressed_amount.dart';
import 'package:hermez_sdk/model/token.dart';
import 'package:hermez_sdk/tx_utils.dart';

import 'fees_utils.dart';

/// Fixes the transaction amount to be sure that it would be supported by Hermez
/// @param {BigNumber} amount - Transaction amount to be fixed
/// @returns fixedTxAmount
double fixTransactionAmount(double amount) {
  final fixedTxAmount = HermezCompressedAmount.decompressAmount(
      HermezCompressedAmount.floorCompressAmount(amount));

  return fixedTxAmount;
}

/// Calculates the max amoumt that can be sent in a transaction
/// @param {TxType} txType - Transaction type
/// @param {BigNumber} maxAmount - Max amount that can be sent in a transaction (usually it's an account balance)
/// @param {Object} token - Token object
/// @param {Number} l2Fee - Transaction fee
/// @param {BigNumber} gasPrice - Ethereum gas price
/// @returns maxTxAmount
double getMaxTxAmount(TransactionType txType, double maxAmount, Token token,
    double l2Fee, double gasPrice) {
  var maxTxAmount;
  switch (txType) {
    case TransactionType.DEPOSIT:
      final depositFee = getDepositFee(token, gasPrice);
      final newMaxAmount = maxAmount - depositFee;
      maxTxAmount = newMaxAmount > 0 ? newMaxAmount : 0;
      break;
    case TransactionType.FORCEEXIT:
      maxTxAmount = maxAmount;
      break;
    default:
      final l2FeeFixed = double.tryParse(l2Fee.toStringAsFixed(token.decimals));
      maxTxAmount = getMaxAmountFromMinimumFee(l2FeeFixed, maxAmount);
      break;
  }
  return fixTransactionAmount(maxTxAmount);
}
