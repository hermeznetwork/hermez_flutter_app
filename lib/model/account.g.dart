// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Account extends Account {

  @override
  final String EthAddr;
  @override
  final int TokenId;
  @override
  final int Idx;
  @override
  final int Nonce;
  @override
  final int Balance;
  @override
  final String PublicKey;
  @override
  final bool loading;
  @override
  final BuiltList<String> errors;

  factory _$Account([void Function(AccountBuilder) updates]) =>
      (new AccountBuilder()..update(updates)).build();

  _$Account._(
      {this.EthAddr,
      this.TokenId,
      this.Idx,
      this.Nonce,
      this.Balance,
      this.PublicKey,
      this.loading,
      this.errors})
      : super._() {
    if (loading == null) {
      throw new BuiltValueNullFieldError('Account', 'loading');
    }
  }

  @override
  Account rebuild(void Function(AccountBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AccountBuilder toBuilder() => new AccountBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Account &&
        EthAddr == other.EthAddr &&
        TokenId == other.TokenId &&
        Idx == other.Idx &&
        Nonce == other.Nonce &&
        Balance == other.Balance &&
        PublicKey == other.PublicKey &&
        loading == other.loading &&
        errors == other.errors;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc($jc($jc(
                $jc($jc($jc(0, EthAddr.hashCode), TokenId.hashCode),
                      Idx.hashCode),
                    Nonce.hashCode),
                  Balance.hashCode),
                PublicKey.hashCode),
              loading.hashCode),
            errors.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Account')
          ..add('EthAddr', EthAddr)
          ..add('TokenId', TokenId)
          ..add('Idx', Idx)
          ..add('Nonce', Nonce)
          ..add('Balance', Balance)
          ..add('PublicKey', PublicKey)
          ..add('loading', loading)
          ..add('errors', errors))
        .toString();
  }
}

class AccountBuilder implements Builder<Account, AccountBuilder> {
  _$Account _$v;

  String _EthAddr;
  String get EthAddr => _$this._EthAddr;
  set EthAddr(String EthAddr) => _$this._EthAddr = EthAddr;

  int _TokenId;
  int get TokenId => _$this._TokenId;
  set TokenId(int TokenId) => _$this._TokenId = TokenId;

  int _Idx;
  int get Idx => _$this._Idx;
  set Idx(int Idx) => _$this._Idx = Idx;

  int _Nonce;
  int get Nonce => _$this._Nonce;
  set Nonce(int Nonce) => _$this._Nonce = Nonce;

  int _Balance;
  int get Balance => _$this._Balance;
  set Balance(int Balance) => _$this._Balance = Balance;

  String _PublicKey;
  String get PublicKey => _$this._PublicKey;
  set PublicKey(String PublicKey) => _$this._PublicKey = PublicKey;

  bool _loading;
  bool get loading => _$this._loading;
  set loading(bool loading) => _$this._loading = loading;

  ListBuilder<String> _errors;
  ListBuilder<String> get errors =>
      _$this._errors ??= new ListBuilder<String>();
  set errors(ListBuilder<String> errors) => _$this._errors = errors;

  AccountBuilder();

  AccountBuilder get _$this {
    if (_$v != null) {
      _EthAddr = _$v.EthAddr;
      _TokenId = _$v.TokenId;
      _Idx = _$v.Idx;
      _Nonce = _$v.Nonce;
      _Balance = _$v.Balance;
      _PublicKey = _$v.PublicKey;
      _loading = _$v.loading;
      _errors = _$v.errors?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Account other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Account;
  }

  @override
  void update(void Function(AccountBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Account build() {
    _$Account _$result;
    try {
      _$result = _$v ??
          new _$Account._(
              EthAddr: EthAddr,
              TokenId: TokenId,
              Idx: Idx,
              Nonce: Nonce,
              Balance: Balance,
              PublicKey: PublicKey,
              loading: loading,
              errors: _errors?.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'errors';
        _errors?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'Account', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
