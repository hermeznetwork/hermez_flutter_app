// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Wallet extends Wallet {
  @override
  final String ethereumAddress;
  @override
  final String ethereumPrivateKey;
  @override
  final String hermezAddress;
  @override
  final String hermezPublicKeyHex;
  @override
  final String hermezPublicKeyBase64;
  @override
  final HermezWallet hermezWallet;
  @override
  final Map<String, BigInt> tokensBalance;
  @override
  final BigInt ethBalance;
  @override
  final double ethUSDPrice;
  @override
  final WalletDefaultCurrency defaultCurrency;
  @override
  final WalletDefaultFee defaultFee;
  @override
  final double exchangeRatio;
  @override
  final TransactionLevel txLevel;
  @override
  final List<Token> tokens;
  @override
  final List<PriceToken> priceTokens;
  @override
  final List<Account> l1Accounts;
  @override
  final List<Account> l2Accounts;
  @override
  final List<PoolTransaction> pendingL2Txs;
  @override
  final List<dynamic> pendingL1Transfers;
  @override
  final List<dynamic> pendingDeposits;
  @override
  final List<dynamic> pendingWithdraws;
  @override
  final List<dynamic> pendingForceExits;
  @override
  final List<Exit> exits;
  @override
  final bool loading;
  @override
  final bool walletInitialized;
  @override
  final BuiltList<String> errors;

  factory _$Wallet([void Function(WalletBuilder) updates]) =>
      (new WalletBuilder()..update(updates)).build();

  _$Wallet._(
      {this.ethereumAddress,
      this.ethereumPrivateKey,
      this.hermezAddress,
      this.hermezPublicKeyHex,
      this.hermezPublicKeyBase64,
      this.hermezWallet,
      this.tokensBalance,
      this.ethBalance,
      this.ethUSDPrice,
      this.defaultCurrency,
      this.defaultFee,
      this.exchangeRatio,
      this.txLevel,
      this.tokens,
      this.priceTokens,
      this.l1Accounts,
      this.l2Accounts,
      this.pendingL2Txs,
      this.pendingL1Transfers,
      this.pendingDeposits,
      this.pendingWithdraws,
      this.pendingForceExits,
      this.exits,
      this.loading,
      this.walletInitialized,
      this.errors})
      : super._() {
    if (tokensBalance == null) {
      throw new BuiltValueNullFieldError('Wallet', 'tokensBalance');
    }
    if (ethBalance == null) {
      throw new BuiltValueNullFieldError('Wallet', 'ethBalance');
    }
    if (loading == null) {
      throw new BuiltValueNullFieldError('Wallet', 'loading');
    }
  }

  @override
  Wallet rebuild(void Function(WalletBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WalletBuilder toBuilder() => new WalletBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Wallet &&
        ethereumAddress == other.ethereumAddress &&
        ethereumPrivateKey == other.ethereumPrivateKey &&
        hermezAddress == other.hermezAddress &&
        hermezPublicKeyHex == other.hermezPublicKeyHex &&
        hermezPublicKeyBase64 == other.hermezPublicKeyBase64 &&
        hermezWallet == other.hermezWallet &&
        tokensBalance == other.tokensBalance &&
        ethBalance == other.ethBalance &&
        ethUSDPrice == other.ethUSDPrice &&
        defaultCurrency == other.defaultCurrency &&
        defaultFee == other.defaultFee &&
        exchangeRatio == other.exchangeRatio &&
        txLevel == other.txLevel &&
        tokens == other.tokens &&
        priceTokens == other.priceTokens &&
        l1Accounts == other.l1Accounts &&
        l2Accounts == other.l2Accounts &&
        pendingL2Txs == other.pendingL2Txs &&
        pendingL1Transfers == other.pendingL1Transfers &&
        pendingDeposits == other.pendingDeposits &&
        pendingWithdraws == other.pendingWithdraws &&
        pendingForceExits == other.pendingForceExits &&
        exits == other.exits &&
        loading == other.loading &&
        walletInitialized == other.walletInitialized &&
        errors == other.errors;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc(
                                $jc(
                                    $jc(
                                        $jc(
                                            $jc(
                                                $jc(
                                                    $jc(
                                                        $jc(
                                                            $jc(
                                                                $jc(
                                                                    $jc(
                                                                        $jc(
                                                                            $jc($jc($jc($jc($jc($jc($jc($jc(0, ethereumAddress.hashCode), ethereumPrivateKey.hashCode), hermezWallet.hashCode), hermezAddress.hashCode), hermezPublicKeyHex.hashCode), hermezPublicKeyBase64.hashCode), tokensBalance.hashCode),
                                                                                ethBalance.hashCode),
                                                                            ethUSDPrice.hashCode),
                                                                        defaultCurrency.hashCode),
                                                                    defaultFee.hashCode),
                                                                exchangeRatio.hashCode),
                                                            txLevel.hashCode),
                                                        tokens.hashCode),
                                                    priceTokens.hashCode),
                                                l1Accounts.hashCode),
                                            l2Accounts.hashCode),
                                        pendingL2Txs.hashCode),
                                    pendingL1Transfers.hashCode),
                                pendingDeposits.hashCode),
                            pendingWithdraws.hashCode),
                        pendingForceExits.hashCode),
                    exits.hashCode),
                loading.hashCode),
            walletInitialized.hashCode),
        errors.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Wallet')
          ..add('ethereumAddress', ethereumAddress)
          ..add('ethereumPrivateKey', ethereumPrivateKey)
          ..add('hermezAddress', hermezAddress)
          ..add('hermezPublicKeyHex', hermezPublicKeyHex)
          ..add('hermezPublicKeyBase64', hermezPublicKeyBase64)
          ..add('hermezWallet', hermezWallet)
          ..add('tokensBalance', tokensBalance)
          ..add('ethBalance', ethBalance)
          ..add('ethUSDPrice', ethUSDPrice)
          ..add('defaultCurrency', defaultCurrency)
          ..add('defaultFee', defaultFee)
          ..add('exchangeRatio', exchangeRatio)
          ..add('txLevel', txLevel)
          ..add('tokens', tokens)
          ..add('priceTokens', priceTokens)
          ..add('l1Accounts', l1Accounts)
          ..add('l2Accounts', l2Accounts)
          ..add('pendingL2Txs', pendingL2Txs)
          ..add('pendingL1Transfers', pendingL1Transfers)
          ..add('pendingDeposits', pendingDeposits)
          ..add('pendingWithdraws', pendingWithdraws)
          ..add('pendingForceExits', pendingForceExits)
          ..add('exits', exits)
          ..add('loading', loading)
          ..add('walletInitialized', walletInitialized)
          ..add('errors', errors))
        .toString();
  }
}

class WalletBuilder implements Builder<Wallet, WalletBuilder> {
  _$Wallet _$v;

  String _ethereumAddress;
  String get ethereumAddress => _$this._ethereumAddress;
  set ethereumAddress(String ethereumAddress) =>
      _$this._ethereumAddress = ethereumAddress;

  String _ethereumPrivateKey;
  String get ethereumPrivateKey => _$this._ethereumPrivateKey;
  set ethereumPrivateKey(String ethereumPrivateKey) =>
      _$this._ethereumPrivateKey = ethereumPrivateKey;

  String _hermezAddress;
  String get hermezAddress => _$this._hermezAddress;
  set hermezAddress(String hermezAddress) =>
      _$this._hermezAddress = hermezAddress;

  String _hermezPublicKeyHex;
  String get hermezPublicKeyHex => _$this._hermezPublicKeyHex;
  set hermezPublicKeyHex(String hermezPublicKeyHex) =>
      _$this._hermezPublicKeyHex = hermezPublicKeyHex;

  String _hermezPublicKeyBase64;
  String get hermezPublicKeyBase64 => _$this._hermezPublicKeyBase64;
  set hermezPublicKeyBase64(String hermezPublicKeyBase64) =>
      _$this._hermezPublicKeyBase64 = hermezPublicKeyBase64;

  HermezWallet _hermezWallet;
  HermezWallet get hermezWallet => _$this._hermezWallet;
  set hermezWallet(HermezWallet hermezWallet) =>
      _$this._hermezWallet = hermezWallet;

  Map<String, BigInt> _tokensBalance;
  Map<String, BigInt> get tokensBalance => _$this._tokensBalance;
  set tokensBalance(Map<String, BigInt> tokensBalance) =>
      _$this._tokensBalance = tokensBalance;

  WalletDefaultCurrency _defaultCurrency;
  WalletDefaultCurrency get defaultCurrency => _$this._defaultCurrency;
  set defaultCurrency(WalletDefaultCurrency defaultCurrency) =>
      _$this._defaultCurrency = defaultCurrency;

  WalletDefaultFee _defaultFee;
  WalletDefaultFee get defaultFee => _$this._defaultFee;
  set defaultFee(WalletDefaultFee defaultFee) =>
      _$this._defaultFee = defaultFee;

  double _exchangeRatio;
  double get exchangeRatio => _$this._exchangeRatio;
  set exchangeRatio(double exchangeRatio) =>
      _$this._exchangeRatio = exchangeRatio;

  TransactionLevel _txLevel;
  TransactionLevel get txLevel => _$this._txLevel;
  set txLevel(TransactionLevel txLevel) => _$this._txLevel = txLevel;

  List<Token> _tokens;
  List<Token> get tokens => _$this._tokens;
  set tokens(List<Token> tokens) => _$this._tokens = tokens;

  List<PriceToken> _priceTokens;
  List<PriceToken> get priceTokens => _$this._priceTokens;
  set priceTokens(List<PriceToken> priceTokens) =>
      _$this._priceTokens = priceTokens;

  List<Account> _l1Accounts;
  List<Account> get l1Accounts => _$this._l1Accounts;
  set l1Accounts(List<Account> l1Accounts) => _$this._l1Accounts = l1Accounts;

  List<Account> _l2Accounts;
  List<Account> get l2Accounts => _$this._l2Accounts;
  set l2Accounts(List<Account> l2Accounts) => _$this._l2Accounts = l2Accounts;

  List<PoolTransaction> _pendingL2Txs;
  List<PoolTransaction> get pendingL2Txs => _$this._pendingL2Txs;
  set pendingL2Txs(List<PoolTransaction> pendingL2Txs) =>
      _$this._pendingL2Txs = pendingL2Txs;

  List<dynamic> _pendingL1Transfers;
  List<dynamic> get pendingL1Transfers => _$this._pendingL1Transfers;
  set pendingL1Transfers(List<dynamic> pendingL1Transfers) =>
      _$this._pendingL1Transfers = pendingL1Transfers;

  List<dynamic> _pendingDeposits;
  List<dynamic> get pendingDeposits => _$this._pendingDeposits;
  set pendingDeposits(List<dynamic> pendingDeposits) =>
      _$this._pendingDeposits = pendingDeposits;

  List<dynamic> _pendingWithdraws;
  List<dynamic> get pendingWithdraws => _$this._pendingWithdraws;
  set pendingWithdraws(List<dynamic> pendingWithdraws) =>
      _$this._pendingWithdraws = pendingWithdraws;

  List<dynamic> _pendingForceExits;
  List<dynamic> get pendingForceExits => _$this._pendingForceExits;
  set pendingForceExits(List<dynamic> pendingForceExits) =>
      _$this._pendingForceExits = pendingForceExits;

  List<Exit> _exits;
  List<Exit> get exits => _$this._exits;
  set exits(List<Exit> exits) => _$this._exits = exits;

  BigInt _ethBalance;
  BigInt get ethBalance => _$this._ethBalance;
  set ethBalance(BigInt ethBalance) => _$this._ethBalance = ethBalance;

  double _ethUSDPrice;
  double get ethUSDPrice => _$this._ethUSDPrice;
  set ethUSDPrice(double ethUSDPrice) => _$this._ethUSDPrice = ethUSDPrice;

  bool _loading;
  bool get loading => _$this._loading;
  set loading(bool loading) => _$this._loading = loading;

  bool _walletInitialized;
  bool get walletInitialized => _$this._walletInitialized;
  set walletInitialized(bool walletInitialized) =>
      _$this._walletInitialized = walletInitialized;

  ListBuilder<String> _errors;
  ListBuilder<String> get errors =>
      _$this._errors ??= new ListBuilder<String>();
  set errors(ListBuilder<String> errors) => _$this._errors = errors;

  WalletBuilder();

  WalletBuilder get _$this {
    if (_$v != null) {
      _ethereumAddress = _$v.ethereumAddress;
      _ethereumPrivateKey = _$v.ethereumPrivateKey;
      _hermezAddress = _$v.hermezAddress;
      _hermezPublicKeyHex = _$v.hermezPublicKeyHex;
      _hermezPublicKeyBase64 = _$v.hermezPublicKeyBase64;
      _hermezWallet = _$v.hermezWallet;
      _tokensBalance = _$v.tokensBalance;
      _ethBalance = _$v.ethBalance;
      _ethUSDPrice = _$v.ethUSDPrice;
      _defaultCurrency = _$v.defaultCurrency;
      _defaultFee = _$v.defaultFee;
      _exchangeRatio = _$v.exchangeRatio;
      _txLevel = _$v.txLevel;
      _tokens = _$v.tokens;
      _priceTokens = _$v.priceTokens;
      _l1Accounts = _$v.l1Accounts;
      _l2Accounts = _$v.l2Accounts;
      _pendingL2Txs = _$v.pendingL2Txs;
      _pendingL1Transfers = _$v.pendingL1Transfers;
      _pendingDeposits = _$v.pendingDeposits;
      _pendingWithdraws = _$v.pendingWithdraws;
      _pendingForceExits = _$v.pendingForceExits;
      _exits = _$v.exits;
      _loading = _$v.loading;
      _walletInitialized = _$v.walletInitialized;
      _errors = _$v.errors?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Wallet other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Wallet;
  }

  @override
  void update(void Function(WalletBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Wallet build() {
    _$Wallet _$result;
    try {
      _$result = _$v ??
          new _$Wallet._(
              ethereumAddress: ethereumAddress,
              ethereumPrivateKey: ethereumPrivateKey,
              hermezAddress: hermezAddress,
              hermezPublicKeyHex: hermezPublicKeyHex,
              hermezPublicKeyBase64: hermezPublicKeyBase64,
              hermezWallet: hermezWallet,
              tokensBalance: tokensBalance,
              ethBalance: ethBalance,
              ethUSDPrice: ethUSDPrice,
              defaultCurrency: defaultCurrency,
              defaultFee: defaultFee,
              exchangeRatio: exchangeRatio,
              txLevel: txLevel,
              tokens: tokens,
              priceTokens: priceTokens,
              l1Accounts: l1Accounts,
              l2Accounts: l2Accounts,
              pendingL2Txs: pendingL2Txs,
              pendingL1Transfers: pendingL1Transfers,
              pendingDeposits: pendingDeposits,
              pendingWithdraws: pendingWithdraws,
              pendingForceExits: pendingForceExits,
              exits: exits,
              loading: loading,
              walletInitialized: walletInitialized,
              errors: _errors?.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'errors';
        _errors?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'Wallet', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
