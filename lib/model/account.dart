import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:web3dart/web3dart.dart';

part 'account.g.dart';

// Account is a struct that gives information of the holdings of an address for a specific token
abstract class Account implements Built<Account, AccountBuilder> {

  @nullable
  String get EthAddr;

  @nullable
  int get TokenId;

  @nullable
  int get Idx;

  @nullable
  int get Nonce;

  @nullable
  int get Balance;

  @nullable
  String get PublicKey;

  bool get loading;

  @nullable
  BuiltList<String> get errors;

  Account._();
  factory Account([void Function(AccountBuilder) updates]) => _$Account((b) => b
    ..errors = BuiltList<String>().toBuilder()
    ..loading = false
    ..update(updates));
}
