// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Token extends Token {

  @override
  final int TokenId;
  @override
  final String EthAddr;
  @override
  final String Name;
  @override
  final String Symbol;
  @override
  final int Decimals;
  @override
  final String EthTxHash;
  @override
  final String EthBlockNum;
  @override
  final bool loading;
  @override
  final BuiltList<String> errors;

  factory _$Token([void Function(TokenBuilder) updates]) =>
      (new TokenBuilder()..update(updates)).build();

  _$Token._(
      {this.TokenId,
      this.EthAddr,
      this.Name,
      this.Symbol,
      this.Decimals,
      this.EthTxHash,
      this.EthBlockNum,
      this.loading,
      this.errors})
      : super._() {
    if (loading == null) {
      throw new BuiltValueNullFieldError('Account', 'loading');
    }
  }

  @override
  Token rebuild(void Function(TokenBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TokenBuilder toBuilder() => new TokenBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Token &&
        TokenId == other.TokenId &&
        EthAddr == other.EthAddr &&
        Name == other.Name &&
        Symbol == other.Symbol &&
        Decimals == other.Decimals &&
        EthTxHash == other.EthTxHash &&
        EthBlockNum == other.EthBlockNum &&
        loading == other.loading &&
        errors == other.errors;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc(
            $jc($jc($jc(
                $jc($jc($jc(0, TokenId.hashCode), EthAddr.hashCode),
                      Name.hashCode),
                    Symbol.hashCode),
                  Decimals.hashCode),
                EthTxHash.hashCode),
              EthBlockNum.hashCode),
              loading.hashCode),
            errors.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Token')
          ..add('TokenId', TokenId)
          ..add('EthAddr', EthAddr)
          ..add('Name', Name)
          ..add('Symbol', Symbol)
          ..add('Decimals', Decimals)
          ..add('EthTxHash', EthTxHash)
          ..add('EthBlockNum', EthBlockNum)
          ..add('loading', loading)
          ..add('errors', errors))
        .toString();
  }
}

class TokenBuilder implements Builder<Token, TokenBuilder> {
  _$Token _$v;

  int _TokenId;
  int get TokenId => _$this._TokenId;
  set TokenId(int TokenId) => _$this._TokenId = TokenId;

  String _EthAddr;
  String get EthAddr => _$this._EthAddr;
  set EthAddr(String EthAddr) => _$this._EthAddr = EthAddr;

  String _Name;
  String get Name => _$this._Name;
  set Name(String Name) => _$this._Name = Name;

  String _Symbol;
  String get Symbol => _$this._Symbol;
  set Symbol(String Symbol) => _$this._Symbol = Symbol;

  int _Decimals;
  int get Decimals => _$this._Decimals;
  set Decimals(int Decimals) => _$this._Decimals = Decimals;

  String _EthTxHash;
  String get EthTxHash => _$this._EthTxHash;
  set EthTxHash(String EthTxHash) => _$this._EthTxHash = EthTxHash;

  String _EthBlockNum;
  String get EthBlockNum => _$this._EthBlockNum;
  set EthBlockNum(String EthBlockNum) => _$this._EthBlockNum = EthBlockNum;

  bool _loading;
  bool get loading => _$this._loading;
  set loading(bool loading) => _$this._loading = loading;

  ListBuilder<String> _errors;
  ListBuilder<String> get errors =>
      _$this._errors ??= new ListBuilder<String>();
  set errors(ListBuilder<String> errors) => _$this._errors = errors;

  TokenBuilder();

  TokenBuilder get _$this {
    if (_$v != null) {
      _TokenId = _$v.TokenId;
      _EthAddr = _$v.EthAddr;
      _Name = _$v.Name;
      _Symbol = _$v.Symbol;
      _Decimals = _$v.Decimals;
      _EthTxHash = _$v.EthTxHash;
      _EthBlockNum = _$v.EthBlockNum;
      _loading = _$v.loading;
      _errors = _$v.errors?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Token other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Token;
  }

  @override
  void update(void Function(TokenBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Token build() {
    _$Token _$result;
    try {
      _$result = _$v ??
          new _$Token._(
              TokenId: TokenId,
              EthAddr: EthAddr,
              Name: Name,
              Symbol: Symbol,
              Decimals: Decimals,
              EthTxHash: EthTxHash,
              EthBlockNum: EthBlockNum,
              loading: loading,
              errors: _errors?.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'errors';
        _errors?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'Token', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
