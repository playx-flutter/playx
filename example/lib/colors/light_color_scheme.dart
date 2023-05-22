import 'dart:ui';

import 'package:playx/playx.dart';

import 'base_color_scheme.dart';

class LightColorScheme extends BaseColorScheme {
  @override
  Color get containerBackgroundColor => XColorScheme.white;

  @override
  Color get background => XColorScheme.white;

  @override
  Color get error => XColorScheme.red;

  @override
  Color get onBackground => XColorScheme.black;

  @override
  Color get onError => XColorScheme.white;

  @override
  Color get onPrimary => XColorScheme.white;

  @override
  Color get onSecondary => XColorScheme.white;

  @override
  Color get onSurface => XColorScheme.black;

  @override
  Color get primary => XColorScheme.blueMain;

  @override
  Color get secondary => XColorScheme.purpleMain;

  @override
  Color get surface => XColorScheme.white;
}
