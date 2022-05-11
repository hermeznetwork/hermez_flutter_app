import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class HermezColors {
  HermezColors._();

  static final appColorScheme =
      ColorScheme.fromSeed(seedColor: primary, background: neutralLight);

  /// Semantic
  static const Color error = Color(0xffE8430D);

  static final Color errorBackground = error.withOpacity(0.1);

  static const Color success = Color(0xff34C095);

  static const Color warning = Color(0xffE17E26);

  static final Color warningBackground = warning.withOpacity(0.1);

  /// Dark
  static const Color dark = Color(0xFF081132);

  /// Primary
  // static const Color secondary = const Color(0xff8248E5);
  static const Color primary = const Color(0xff7B3FE4);

  /// Secondary
  static const Color secondary = const Color(0xffFFC55A);

  static const Color darkTernary = Color(0xffe75a2b);

  /// Neutral
  static const Color neutral = Color(0xff7C7E96);

  static const Color neutralMedium = Color(0xffC9CDD7);

  static const Color neutralMediumLight = Color(0xffE2E5EE);

  static const Color neutralLight = Color(0xffF0F1F6);

  static const Color light = Colors.white;
}
