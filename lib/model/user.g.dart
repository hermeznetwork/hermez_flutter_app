// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$User extends User {

  @override
  final String name;
  @override
  final String phoneNumber;
  @override
  final String email;
  @override
  final String ethAddress;
  @override
  final bool loading;
  @override
  final BuiltList<String> errors;

  factory _$User([void Function(UserBuilder) updates]) =>
      (new UserBuilder()..update(updates)).build();

  _$User._(
      {this.name,
      this.phoneNumber,
      this.email,
      this.ethAddress,
      this.loading,
      this.errors})
      : super._() {
    if (loading == null) {
      throw new BuiltValueNullFieldError('User', 'loading');
    }
  }

  @override
  User rebuild(void Function(UserBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserBuilder toBuilder() => new UserBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is User &&
        name == other.name &&
        phoneNumber == other.phoneNumber &&
        email == other.email &&
        ethAddress == other.ethAddress &&
        loading == other.loading &&
        errors == other.errors;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc($jc($jc(0, name.hashCode), phoneNumber.hashCode),
                    email.hashCode),
                ethAddress.hashCode),
            loading.hashCode),
        errors.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('User')
          ..add('name', name)
          ..add('phoneNumber', phoneNumber)
          ..add('email', email)
          ..add('ethAddress', ethAddress)
          ..add('loading', loading)
          ..add('errors', errors))
        .toString();
  }
}

class UserBuilder implements Builder<User, UserBuilder> {
  _$User _$v;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  String _phoneNumber;
  String get phoneNumber => _$this._phoneNumber;
  set phoneNumber(String phoneNumber) => _$this._phoneNumber = phoneNumber;

  String _email;
  String get email => _$this._email;
  set email(String email) => _$this._email = email;

  String _ethAddress;
  String get ethAddress => _$this._ethAddress;
  set ethAddress(String ethAddress) => _$this._ethAddress = ethAddress;

  bool _loading;
  bool get loading => _$this._loading;
  set loading(bool loading) => _$this._loading = loading;

  ListBuilder<String> _errors;
  ListBuilder<String> get errors =>
      _$this._errors ??= new ListBuilder<String>();
  set errors(ListBuilder<String> errors) => _$this._errors = errors;

  UserBuilder();

  UserBuilder get _$this {
    if (_$v != null) {
      _name = _$v.name;
      _phoneNumber = _$v.phoneNumber;
      _email = _$v.email;
      _ethAddress = _$v.ethAddress;
      _loading = _$v.loading;
      _errors = _$v.errors?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(User other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$User;
  }

  @override
  void update(void Function(UserBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$User build() {
    _$User _$result;
    try {
      _$result = _$v ??
          new _$User._(
              name: name,
              phoneNumber: phoneNumber,
              email: email,
              ethAddress: ethAddress,
              loading: loading,
              errors: _errors?.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'errors';
        _errors?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'User', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
