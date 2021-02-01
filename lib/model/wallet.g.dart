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
  final Map<String, BigInt> tokensBalance;
  @override
  final BigInt ethBalance;
  @override
  final double ethUSDPrice;
  @override
  final WalletDefaultCurrency defaultCurrency;
  @override
  final double exchangeRatio;
  @override
  final TransactionLevel txLevel;
  @override
  final List<Account> cryptoList;
  @override
  final bool loading;
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
      this.tokensBalance,
      this.ethBalance,
      this.ethUSDPrice,
      this.defaultCurrency,
      this.exchangeRatio,
      this.txLevel,
      this.cryptoList,
      this.loading,
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
        tokensBalance == other.tokensBalance &&
        ethBalance == other.ethBalance &&
        ethUSDPrice == other.ethUSDPrice &&
        defaultCurrency == other.defaultCurrency &&
        exchangeRatio == other.exchangeRatio &&
        txLevel == other.txLevel &&
        cryptoList == other.cryptoList &&
        loading == other.loading &&
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
                                                            0,
                                                            ethereumAddress
                                                                .hashCode),
                                                        ethereumPrivateKey
                                                            .hashCode),
                                                    hermezAddress.hashCode),
                                                hermezPublicKeyHex.hashCode),
                                            hermezPublicKeyBase64.hashCode),
                                        tokensBalance.hashCode),
                                    ethBalance.hashCode),
                                ethUSDPrice.hashCode),
                            defaultCurrency.hashCode),
                        exchangeRatio.hashCode),
                    txLevel.hashCode),
                cryptoList.hashCode),
            loading.hashCode),
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
          ..add('tokensBalance', tokensBalance)
          ..add('ethBalance', ethBalance)
          ..add('ethUSDPrice', ethUSDPrice)
          ..add('defaultCurrency', defaultCurrency)
          ..add('exchangeRatio', exchangeRatio)
          ..add('txLevel', txLevel)
          ..add('cryptoList', cryptoList)
          ..add('loading', loading)
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

  Map<String, BigInt> _tokensBalance;
  Map<String, BigInt> get tokensBalance => _$this._tokensBalance;
  set tokensBalance(Map<String, BigInt> tokensBalance) =>
      _$this._tokensBalance = tokensBalance;

  WalletDefaultCurrency _defaultCurrency;
  WalletDefaultCurrency get defaultCurrency => _$this._defaultCurrency;
  set defaultCurrency(WalletDefaultCurrency defaultCurrency) =>
      _$this._defaultCurrency = defaultCurrency;

  double _exchangeRatio;
  double get exchangeRatio => _$this._exchangeRatio;
  set exchangeRatio(double exchangeRatio) =>
      _$this._exchangeRatio = exchangeRatio;

  TransactionLevel _txLevel;
  TransactionLevel get txLevel => _$this._txLevel;
  set txLevel(TransactionLevel txLevel) => _$this._txLevel = txLevel;

  List<Account> _cryptoList;
  List<Account> get cryptoList => _$this._cryptoList;
  set cryptoList(List<Account> cryptoList) => _$this._cryptoList = cryptoList;

  BigInt _ethBalance;
  BigInt get ethBalance => _$this._ethBalance;
  set ethBalance(BigInt ethBalance) => _$this._ethBalance = ethBalance;

  double _ethUSDPrice;
  double get ethUSDPrice => _$this._ethUSDPrice;
  set ethUSDPrice(double ethUSDPrice) => _$this._ethUSDPrice = ethUSDPrice;

  bool _loading;
  bool get loading => _$this._loading;
  set loading(bool loading) => _$this._loading = loading;

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
      _tokensBalance = _$v.tokensBalance;
      _ethBalance = _$v.ethBalance;
      _ethUSDPrice = _$v.ethUSDPrice;
      _defaultCurrency = _$v.defaultCurrency;
      _exchangeRatio = _$v.exchangeRatio;
      _txLevel = _$v.txLevel;
      _cryptoList = _$v.cryptoList;
      _loading = _$v.loading;
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
              tokensBalance: tokensBalance,
              ethBalance: ethBalance,
              ethUSDPrice: ethUSDPrice,
              defaultCurrency: defaultCurrency,
              exchangeRatio: exchangeRatio,
              txLevel: txLevel,
              cryptoList: cryptoList,
              loading: loading,
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
