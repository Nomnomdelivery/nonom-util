import 'package:flutter/material.dart';

mixin class ColorPalette {
  static final Color orange = Color(0xffFF9E1B);
  final MaterialColor orangePalette =
      const MaterialColor(0xffFF9E1B, <int, Color>{
        50: Color(0xffFFCF8D),
        100: Color(0xffFFC576),
        200: Color(0xffFFBB5F),
        300: Color(0xffFFB149),
        400: Color(0xffFFA832),
        500: Color(0xffFF9E1B),
        600: Color(0xffE68E18),
        700: Color(0xffCC7E16),
        800: Color(0xffB36F13),
        900: Color(0xff995F10),
      });
  final Color blue = const Color(0xFF50A3FB);
  final Color pink = const Color(0xFFFC4F84);
  final Color grey = const Color(0xFFABABAB);
  static final Color sgrey = const Color(0xFFABABAB);
  static final Color sscaffoldColor = const Color(0xFFFFFFFF);
  final Color textField = const Color(0xFFE5E5E5);
  static final Color sTextField = Color(0xFFE5E5E5);
  final Color red = const Color(0xFFFF0000);
  static final Color sred = const Color(0xFFFF0000);
  final Color green = const Color(0xFF26DE57);
  final Color purple = const Color(0xFF993CFC);
  final Color scaffoldColor = const Color(0xFFFFFFFF);
  final Color darkGrey = const Color(0xFF3F3F3F);
  final Color subScaffoldColor = const Color(0xFFF8F8F8);
}
