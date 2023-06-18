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
            theme: ThemeData.light(),
            colorScheme: LightColorScheme()),
        XTheme(
            id: 'dark',
            name: 'Dark',
            theme: ThemeData.dark(),
            colorScheme: DarkColorScheme()),
      ];
}
