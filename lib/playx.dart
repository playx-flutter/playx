library playx;

import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:playx/config/playx.dart';
import 'package:playx_theme/playx_theme.dart';
import 'package:playx_core/playx_core.dart';

export 'exports.dart';

abstract class Playx {
  static Future<void> boot({
    required PlayXAppConfig appConfig,
    XThemeConfig themeConfig = const XDefaultThemeConfig(),
  }) async {
    /// * boot the core
    await PlayXCore.bootCore();
    log('[playx] core booted ✔');

    /// * boot the theme
    await AppTheme.boot(config: themeConfig);
    log('[playx] theme booted ✔');

    /// * inject the theme
    Get.put<PlayXAppConfig>(appConfig, permanent: true);
  }

  @visibleForTesting
  static Future<void> dispose() async {
    await PlayXCore.dispose();
  }
}
