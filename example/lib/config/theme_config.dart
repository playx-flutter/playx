import 'package:flutter/material.dart';
import 'package:playx/playx.dart';
import 'package:playx_example/colors/dark_colors.dart';
import 'package:playx_example/colors/light_colors.dart';

PlayxThemeConfig createThemeConfig() {
  return PlayxThemeConfig(
    themes: [
      XTheme.builder(
        id: 'light',
        name: 'Light',
        initialTheme: ThemeData(
          brightness: Brightness.light,
          fontFamily: 'Roboto',
        ),
        themeBuilder: (locale) => ThemeData(
          brightness: Brightness.light,
          fontFamily: locale?.isArabic == true ? 'Segoe UI' : 'Roboto',
        ),
        colors: LightColorScheme(),
        cupertinoThemeBuilder: null,
      ),
      XTheme(
        id: 'dark',
        name: 'Dark',
        themeData: ThemeData.dark(),
        colors: DarkColorScheme(),
      ),
    ],
  );
}
