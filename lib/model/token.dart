import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:web3dart/web3dart.dart';

part 'token.g.dart';

// Token is a struct that represents an Ethereum token that is supported in Hermez network
abstract class Token implements Built<Token, TokenBuilder> {

  @nullable
  int get TokenId;

  @nullable
  String get EthAddr;

  @nullable
  String get Name;

  @nullable
  String get Symbol;

  @nullable
  int get Decimals;

  @nullable
  String get EthTxHash;

  @nullable
  String get EthBlockNum;

  bool get loading;

  @nullable
  BuiltList<String> get errors;

  Token._();
  factory Token([void Function(TokenBuilder) updates]) => _$Token((b) => b
    ..errors = BuiltList<String>().toBuilder()
    ..loading = false
    ..update(updates));
}
