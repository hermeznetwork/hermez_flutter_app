import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:hermez/src/domain/prices/price_token.dart';
import 'package:hermez/src/domain/wallets/wallet.dart' as wallet;
import 'package:hermez/src/presentation/transactions/widgets/transaction_amount.dart';
import 'package:hermez_sdk/hermez_wallet.dart';
import 'package:hermez_sdk/model/account.dart';
import 'package:hermez_sdk/model/exit.dart';
import 'package:hermez_sdk/model/pool_transaction.dart';
import 'package:hermez_sdk/model/token.dart';

part 'wallet.g.dart';

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

  wallet.WalletDefaultCurrency get defaultCurrency;

  wallet.WalletDefaultFee get defaultFee;

  double get exchangeRatio;

  TransactionLevel get txLevel;

  List<Token> get tokens;

  List<PriceToken> get priceTokens;

  List<Account> get l1Accounts;

  List<Account> get l2Accounts;

  List<PoolTransaction> get pendingL2Txs;

  List<dynamic> get pendingL1Transfers;

  List<dynamic> get pendingDeposits;

  List<dynamic> get pendingWithdraws;

  List<dynamic> get pendingForceExits;

  List<Exit> get exits;

  bool get loading;

  bool get walletInitialized;

  @nullable
  BuiltList<String> get errors;

  Wallet._();
  factory Wallet([void Function(WalletBuilder) updates]) => _$Wallet((b) => b
    ..tokensBalance = BuiltMap<String, BigInt>().toMap()
    ..ethBalance = BigInt.from(0)
    ..ethUSDPrice = 0
    ..defaultCurrency = wallet.WalletDefaultCurrency.USD
    ..defaultFee = wallet.WalletDefaultFee.AVERAGE
    ..exchangeRatio = 0.0
    ..txLevel = TransactionLevel.LEVEL1
    ..tokens = []
    ..priceTokens = []
    ..l1Accounts = []
    ..l2Accounts = []
    ..pendingL2Txs = []
    ..pendingL1Transfers = []
    ..pendingDeposits = []
    ..pendingWithdraws = []
    ..pendingForceExits = []
    ..exits = []
    ..errors = BuiltList<String>().toBuilder()
    ..loading = false
    ..walletInitialized = false
    ..update(updates));
}
