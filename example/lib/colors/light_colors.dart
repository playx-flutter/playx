import 'package:flutter/material.dart';
import 'package:playx/playx.dart';
import 'package:playx_example/colors/base_colors.dart';

class LightColorScheme extends BaseColors {
  LightColorScheme()
      : super(
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue, brightness: Brightness.light));

  @override
  Color get containerBackgroundColor => PlayxColors.white;
}
