import 'package:flutter/material.dart';
import 'package:playx/playx.dart';
import 'package:playx_example/colors/base_colors.dart';

class DarkColorScheme extends BaseColors {
  DarkColorScheme()
      : super(
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue, brightness: Brightness.dark));

  @override
  Color get containerBackgroundColor => PlayxColors.darkGrey;
}
