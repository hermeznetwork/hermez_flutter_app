import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:web3dart/web3dart.dart';

part 'transaction.g.dart';

// Transaction is a struct that represents a Hermez network transaction
abstract class Transaction implements Built<Transaction, TransactionBuilder> {

  @nullable
  int get TxID;

  @nullable
  int get FromIdx;

  @nullable
  int get ToIdx;

  @nullable
  int get TokenId;

  @nullable
  int get Amount;

  @nullable
  int get Nonce;

  @nullable
  int get Fee;

  @nullable
  String get Type;

  @nullable
  int get BatchNum;

  bool get loading;

  @nullable
  BuiltList<String> get errors;

  Transaction._();
  factory Transaction([void Function(TransactionBuilder) updates]) => _$Transaction((b) => b
    ..errors = BuiltList<String>().toBuilder()
    ..loading = false
    ..update(updates));
}
