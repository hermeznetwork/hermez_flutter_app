import 'package:hermez_sdk/constants.dart';
import 'package:hermez_sdk/model/token.dart';

/// Calculates the fee for a L1 deposit into Hermez Network
/// @param {Token} token - Token object
/// @param {double} gasPrice - Ethereum gas price
/// @returns depositFee
double getDepositFee(Token token, double gasPrice) {
  return token.id == 0 ? GAS_LIMIT_LOW * gasPrice : 0;
}
