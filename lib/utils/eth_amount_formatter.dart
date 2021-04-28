import 'package:web3dart/web3dart.dart';

class EthAmountFormatter {
  EthAmountFormatter(this.amount);

  final BigInt amount;
  String format({
    fromUnit = EtherUnit.wei,
    toUnit = EtherUnit.ether,
  }) {
    if (amount == null) return "-";

    return EtherAmount.fromUnitAndValue(fromUnit, amount)
        .getValueInUnit(toUnit)
        .toString();
  }

  static String removeDecimalZeroFormat(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1);
  }
}
