import 'package:intl/intl.dart';
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
    return n.toString().replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
  }

  static String formatAmount(double amount, String symbol) {
    double resultValue = 0;
    String result = "";
    String locale = "eu";
    bool isCurrency = false;
    if (symbol == "EUR") {
      locale = 'eu';
      symbol = '€';
      isCurrency = true;
    } else if (symbol == "CNY") {
      locale = 'en';
      symbol = '\¥';
      isCurrency = true;
    } else if (symbol == "USD") {
      locale = 'en';
      symbol = '\$';
      isCurrency = true;
    }
    if (amount != null) {
      double value = double.parse(amount.toStringAsFixed(isCurrency ? 2 : 6));
      resultValue += value;
    }
    resultValue =
        double.parse(EthAmountFormatter.removeDecimalZeroFormat(resultValue));
    if (isCurrency) {
      result = NumberFormat.currency(
              locale: locale,
              symbol: symbol,
              decimalDigits: resultValue % 1 == 0
                  ? 0
                  : isCurrency
                      ? 2
                      : 6)
          .format(resultValue);
      return result;
    } else {
      return EthAmountFormatter.removeDecimalZeroFormat(resultValue) +
          " " +
          symbol;
    }
  }
}
