library playx;

import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:playx/config/playx.dart';
import 'package:playx_core/playx_core.dart';
import 'package:playx_theme/playx_theme.dart';

export 'exports.dart';

abstract class Playx {
  static Future<void> boot({
    required PlayXAppConfig appConfig,
    XThemeConfig themeConfig = const XDefaultThemeConfig(),
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    /// * boot the core
    await PlayXCore.bootCore();
    log('[playx] core booted ✔');

    /// * boot the theme
    await AppTheme.boot(config: themeConfig);
    log('[playx] theme booted ✔');

    await appConfig.boot();

    /// * inject the theme
    Get.put<PlayXAppConfig>(appConfig, permanent: true);
  }

  @visibleForTesting
  static Future<void> dispose() async {
    await PlayXCore.dispose();
  }
}
