import 'package:flutter/material.dart';
import 'package:playx/playx.dart';
import 'package:playx_example/colors/dark_color_scheme.dart';
import 'package:playx_example/colors/light_color_scheme.dart';

class AppThemeConfig extends XThemeConfig {
  const AppThemeConfig() : super();

  @override
  List<XTheme> get themes => [
        XTheme(
            id: 'light',
            name: 'Light',
            theme: (locale) => ThemeData(
                  brightness: Brightness.light,
                  fontFamily: locale.isArabic ? 'Segoe UI' : 'Roboto',
                ),
            colorScheme: LightColorScheme()),
        XTheme(
            id: 'dark',
            name: 'Dark',
            theme: (locale) => ThemeData.dark(),
            colorScheme: DarkColorScheme()),
      ];
}
