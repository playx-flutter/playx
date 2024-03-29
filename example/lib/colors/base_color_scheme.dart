import 'package:flutter/material.dart';
import 'package:playx/playx.dart';

/// This is base class for creating a color scheme for each theme.
/// You can create this class of you want to add more colors that will be implemented in each theme color scheme
/// or if you want to add const colors for each theme.
/// If you don't need this functionality you can make each theme color scheme extends `XColorScheme` class
/// You can define a function to get the color scheme like this:
/// ```dart
///  BaseColorScheme get colorScheme => AppTheme.colorScheme as BaseColorScheme;
///  final primary = colorScheme.primary;
///  ```
///  Now you can access each theme color.
abstract class BaseColorScheme extends XColors {
  ///Colors that needs to implemented for each theme.
  Color get containerBackgroundColor;

  ///Colors that needs to is used for each theme.
  static const Color blue = Colors.blue;

  Color get primary;
  Color get secondary;
  Color get background;
  Color get surface;
  Color get error;

  Color get onPrimary;
  Color get onSecondary;
  Color get onBackground;
  Color get onSurface;
  Color get onError;

}

BaseColorScheme get colorScheme => PlayxTheme.colors as BaseColorScheme;
