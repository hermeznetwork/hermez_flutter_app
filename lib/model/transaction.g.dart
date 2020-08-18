// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Transaction extends Transaction {

  @override
  final int TxID;
  @override
  final int FromIdx;
  @override
  final int ToIdx;
  @override
  final int TokenId;
  @override
  final int Amount;
  @override
  final int Nonce;
  @override
  final int Fee;
  @override
  final String Type;
  @override
  final int BatchNum;
  @override
  final bool loading;
  @override
  final BuiltList<String> errors;

  factory _$Transaction([void Function(TransactionBuilder) updates]) =>
      (new TransactionBuilder()..update(updates)).build();

  _$Transaction._(
      {this.TxID,
      this.FromIdx,
      this.ToIdx,
      this.TokenId,
      this.Amount,
      this.Nonce,
      this.Fee,
      this.Type,
      this.BatchNum,
      this.loading,
      this.errors})
      : super._() {
    if (loading == null) {
      throw new BuiltValueNullFieldError('Account', 'loading');
    }
  }

  @override
  Transaction rebuild(void Function(TransactionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TransactionBuilder toBuilder() => new TransactionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Transaction &&
        TxID == other.TxID &&
        FromIdx == other.FromIdx &&
        ToIdx == other.ToIdx &&
        TokenId == other.TokenId &&
        Amount == other.Amount &&
        Nonce == other.Nonce &&
        Fee == other.Fee &&
        Type == other.Type &&
        BatchNum == other.BatchNum &&
        loading == other.loading &&
        errors == other.errors;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc($jc(
            $jc($jc($jc(
                $jc($jc($jc(0, TxID.hashCode), FromIdx.hashCode),
                    ToIdx.hashCode),
                  TokenId.hashCode),
                   Amount.hashCode),
                    Nonce.hashCode),
                      Fee.hashCode),
                     Type.hashCode),
                 BatchNum.hashCode),
              loading.hashCode),
            errors.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Transaction')
          ..add('TxID', TxID)
          ..add('FromIdx', FromIdx)
          ..add('ToIdx', ToIdx)
          ..add('TokenId', TokenId)
          ..add('Amount', Amount)
          ..add('Nonce', Nonce)
          ..add('Fee', Fee)
          ..add('Type', Type)
          ..add('BatchNum', BatchNum)
          ..add('loading', loading)
          ..add('errors', errors))
        .toString();
  }
}

class TransactionBuilder implements Builder<Transaction, TransactionBuilder> {
  _$Transaction _$v;

  int _TxID;
  int get TxID => _$this._TxID;
  set TxID(int TxID) => _$this._TxID = TxID;

  int _FromIdx;
  int get FromIdx => _$this._FromIdx;
  set FromIdx(int FromIdx) => _$this._FromIdx = FromIdx;

  int _ToIdx;
  int get ToIdx => _$this._ToIdx;
  set ToIdx(int ToIdx) => _$this._ToIdx = ToIdx;

  int _TokenId;
  int get TokenId => _$this._TokenId;
  set TokenId(int TokenId) => _$this._TokenId = TokenId;

  int _Amount;
  int get Amount => _$this._Amount;
  set Amount(int Amount) => _$this._Amount = Amount;

  int _Nonce;
  int get Nonce => _$this._Nonce;
  set Nonce(int Nonce) => _$this._Nonce = Nonce;

  int _Fee;
  int get Fee => _$this._Fee;
  set Fee(int Fee) => _$this._Fee = Fee;

  String _Type;
  String get Type => _$this._Type;
  set Type(String Type) => _$this._Type = Type;

  int _BatchNum;
  int get BatchNum => _$this._BatchNum;
  set BatchNum(int BatchNum) => _$this._BatchNum = BatchNum;

  bool _loading;
  bool get loading => _$this._loading;
  set loading(bool loading) => _$this._loading = loading;

  ListBuilder<String> _errors;
  ListBuilder<String> get errors =>
      _$this._errors ??= new ListBuilder<String>();
  set errors(ListBuilder<String> errors) => _$this._errors = errors;

  TransactionBuilder();

  TransactionBuilder get _$this {
    if (_$v != null) {
      _TxID = _$v.TxID;
      _FromIdx = _$v.FromIdx;
      _ToIdx = _$v.ToIdx;
      _TokenId = _$v.TokenId;
      _Amount = _$v.Amount;
      _Nonce = _$v.Nonce;
      _Fee = _$v.Fee;
      _Type = _$v.Type;
      _BatchNum = _$v.BatchNum;
      _loading = _$v.loading;
      _errors = _$v.errors?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Transaction other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Transaction;
  }

  @override
  void update(void Function(TransactionBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Transaction build() {
    _$Transaction _$result;
    try {
      _$result = _$v ??
          new _$Transaction._(
              TxID: TxID,
              FromIdx: FromIdx,
              ToIdx: ToIdx,
              TokenId: TokenId,
              Amount: Amount,
              Nonce: Nonce,
              Fee: Fee,
              Type: Type,
              BatchNum: BatchNum,
              loading: loading,
              errors: _errors?.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'errors';
        _errors?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'Transaction', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
