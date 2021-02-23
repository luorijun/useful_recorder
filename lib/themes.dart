import 'package:flutter/material.dart';

class ColorDefinition {
  final Color primary;
  final Color secondary;
  final Color weak;
  final Color slight;

  ColorDefinition({
    @required this.primary,
    @required this.secondary,
    @required this.weak,
    @required this.slight,
  });
}

typedef ThemeData ThemeDefinition(ColorDefinition colors);

class AppTheme {
  final ThemeData normal;
  final ThemeData menses;
  final ThemeData ovulation;

  AppTheme({
    @required AppColor colors,
    @required ThemeDefinition normal,
    @required ThemeDefinition menses,
    @required ThemeDefinition ovulation,
  })  : this.normal = normal.call(colors.normal),
        this.menses = menses.call(colors.menses),
        this.ovulation = ovulation.call(colors.ovulation);
}

class AppColor {
  final ColorDefinition normal;
  final ColorDefinition menses;
  final ColorDefinition ovulation;

  AppColor({
    @required this.normal,
    @required this.menses,
    @required this.ovulation,
  });
}

final colors = AppColor(
  normal: ColorDefinition(
    primary: Colors.green,
    secondary: Colors.greenAccent,
    weak: Colors.green.shade300,
    slight: Colors.green.shade200,
  ),
  menses: ColorDefinition(
    primary: Colors.red,
    secondary: Colors.redAccent,
    weak: Colors.red.shade300,
    slight: Colors.red.shade200,
  ),
  ovulation: ColorDefinition(
    primary: Colors.purple,
    secondary: Colors.purpleAccent,
    weak: Colors.purple.shade300,
    slight: Colors.purple.shade200,
  ),
);

final themes = AppTheme(
  colors: colors,
  normal: (colors) => ThemeData(
    primaryColor: colors.primary,
    accentColor: colors.secondary,
    appBarTheme: AppBarTheme(
      color: colors.primary,
      elevation: 4,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: colors.secondary,
    ),
  ),
  menses: (colors) => ThemeData(
    primaryColor: colors.primary,
    accentColor: colors.secondary,
    appBarTheme: AppBarTheme(
      color: colors.primary,
      elevation: 4,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: colors.secondary,
    ),
  ),
  ovulation: (colors) => ThemeData(
    primaryColor: colors.primary,
    accentColor: colors.secondary,
  ),
);
