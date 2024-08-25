import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playx_theme/playx_theme.dart';

/// Provides theme-related settings for a Flutter application.
///
/// The [PlayxThemeSettings] class allows you to define themes for your app,
/// including light and dark themes, as well as high-contrast themes. It also
/// supports custom Cupertino themes and provides a callback for when the theme
/// is updated.
class PlayxThemeSettings {
  /// The light theme to be applied when the app is using light mode.
  final ThemeData? theme;

  /// The dark theme to be applied when the app is using dark mode.
  final ThemeData? darkTheme;

  /// The mode used to determine whether the app should use the light or dark theme.
  /// This can be [ThemeMode.system], [ThemeMode.light], or [ThemeMode.dark].
  final ThemeMode themeMode;

  /// The Cupertino theme data for iOS-style widgets.
  /// Provides styling for Cupertino widgets.
  final CupertinoThemeData? cupertinoTheme;

  /// The high-contrast theme for accessibility, to be used in light mode.
  final ThemeData? highContrastTheme;

  /// The high-contrast theme for accessibility, to be used in dark mode.
  final ThemeData? highContrastDarkTheme;

  /// Callback that is triggered when the theme is updated.
  /// This function receives the new [XTheme] as an argument, allowing
  /// you to react to theme changes.
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
