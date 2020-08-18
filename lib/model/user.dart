import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
//import 'package:firebase_ml_vision/firebase_ml_vision.dart';

part 'user.g.dart';

abstract class User implements Built<User, UserBuilder> {

  @nullable
  String get name;

  @nullable
  String get phoneNumber;

  @nullable
  String get email;

  @nullable
  String get ethAddress;

  bool get loading;

  @nullable
  BuiltList<String> get errors;

  User._();
  factory User([void Function(UserBuilder) updates]) => _$User((b) => b
    ..errors = BuiltList<String>().toBuilder()
    ..loading = false
    ..update(updates));
}
