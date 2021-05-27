import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:hermez/screens/transaction_amount.dart';
import 'package:hermez_plugin/hermez_wallet.dart';
import 'package:hermez_plugin/model/account.dart';

part 'wallet.g.dart';

enum WalletDefaultCurrency { USD, EUR, CNY, JPY, GBP }

enum WalletDefaultFee { SLOW, AVERAGE, FAST }

abstract class Wallet implements Built<Wallet, WalletBuilder> {
  @nullable
  String get ethereumAddress;

  @nullable
  String get ethereumPrivateKey;

  @nullable
  String get hermezAddress;

  @nullable
  String get hermezPublicKeyHex;

  @nullable
  String get hermezPublicKeyBase64;

  @nullable
  HermezWallet get hermezWallet;

  Map<String, BigInt> get tokensBalance;

  BigInt get ethBalance;

  double get ethUSDPrice;

  WalletDefaultCurrency get defaultCurrency;

  WalletDefaultFee get defaultFee;

  double get exchangeRatio;

  TransactionLevel get txLevel;

  List<Account> get cryptoList;

  bool get loading;

  @nullable
  BuiltList<String> get errors;

  Wallet._();
  factory Wallet([void Function(WalletBuilder) updates]) => _$Wallet((b) => b
    ..tokensBalance = BuiltMap<String, BigInt>().toMap()
    ..ethBalance = BigInt.from(0)
    ..ethUSDPrice = 0
    ..defaultCurrency = WalletDefaultCurrency.USD
    ..defaultFee = WalletDefaultFee.AVERAGE
    ..exchangeRatio = 0.0
    ..txLevel = TransactionLevel.LEVEL1
    ..cryptoList = List()
    ..errors = BuiltList<String>().toBuilder()
    ..loading = false
    ..update(updates));
}
