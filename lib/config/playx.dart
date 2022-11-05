import 'package:flutter/foundation.dart';

abstract class PlayXAppConfig {
  String get appTitle;

  String get sentryKey;

  bool get enableSentryReport => sentryKey.isNotEmpty && kReleaseMode;
}
