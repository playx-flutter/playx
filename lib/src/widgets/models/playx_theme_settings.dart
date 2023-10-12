import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playx_theme/playx_theme.dart';

///Default theme settings
class PlayxThemeSettings {
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode themeMode;
  final CupertinoThemeData? cupertinoTheme;
  final ThemeData? highContrastTheme;
  final ThemeData? highContrastDarkTheme;

  ///Callback that is called when the theme is updated.
  final Function(XTheme)? onThemeChanged;

  const PlayxThemeSettings({
    this.theme,
    this.darkTheme,
    this.themeMode = ThemeMode.system,
    this.cupertinoTheme,
    this.highContrastTheme,
    this.highContrastDarkTheme,
    this.onThemeChanged,
  });
}