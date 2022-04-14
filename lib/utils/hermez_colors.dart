import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class HermezColors {
  HermezColors._();

  // Colors

  static final primarySwatch = generateMaterialColor(primary);

  static const Color transparent = Color(0x00000000);

  static const Color error = Color(0xffff4b40);

  static const Color success = Color(0xff219653);

  static const Color warning = Color(0xffd8853b);

  static const Color warningBackground = Color(0xfff2994a);

  /// Dark
  static const Color dark = Color(0xFF000411);

  static const Color darkTwo = Color(0xFF081132);

  /// Primary
  static final Color primary = const Color(0xffffffff);

  /// Secondary
  static const Color secondary = const Color(0xff8248E5);

  /// Ternary
  static const Color ternary = const Color(0xffffa600);

  static const Color darkTernary = Color(0xffe75a2b);

  /// Quaternary
  static const Color quaternary = Color(0xff7a7c89);

  static const Color quaternaryTwo = Color(0xff565662);

  static const Color quaternaryThree = Color(0xffF6F7FA);

  static const Color quaternaryFour = Color(0xffE9ECF4);

}

MaterialColor generateMaterialColor(Color color) {
  return MaterialColor(color.value, {
    50: tintColor(color, 0.9),
    100: tintColor(color, 0.8),
    200: tintColor(color, 0.6),
    300: tintColor(color, 0.4),
    400: tintColor(color, 0.2),
    500: color,
    600: shadeColor(color, 0.1),
    700: shadeColor(color, 0.2),
    800: shadeColor(color, 0.3),
    900: shadeColor(color, 0.4),
  });
}

int tintValue(int value, double factor) =>
    max(0, min((value + ((255 - value) * factor)).round(), 255));

Color tintColor(Color color, double factor) => Color.fromRGBO(
    tintValue(color.red, factor),
    tintValue(color.green, factor),
    tintValue(color.blue, factor),
    1);

int shadeValue(int value, double factor) =>
    max(0, min(value - (value * factor).round(), 255));

Color shadeColor(Color color, double factor) => Color.fromRGBO(
    shadeValue(color.red, factor),
    shadeValue(color.green, factor),
    shadeValue(color.blue, factor),
    1);
