library playx;

import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:playx_core/playx_core.dart';
import 'package:playx_theme/playx_theme.dart';

import 'config/playx_app_config.dart';

export '../playx.dart';

///helps with redundant features , less code by providing many futures like:
/// [Prefs] : easily save/ get key-value pairs from shared preferences.
/// [PlayXAppConfig] : install and setup any dependencies that are required by the app.
/// [AppTheme] : easily create and mange app theme with the ability to easily change app theme.
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

    /// * boot app config.
    await appConfig.boot();
    log('[playx] appConfig booted ✔');

    /// * inject the theme
    Get.put<PlayXAppConfig>(appConfig, permanent: true);
  }

  @visibleForTesting
  static Future<void> dispose() async {
    await PlayXCore.dispose();
    log('[playx] disposed ✔');
  }

  /// wraps`runApp` to inject , init ..etc what ever is necessary for using this package
  static Future<void> runPlayx({
    required PlayXAppConfig appConfig,
    required Widget app,
    XThemeConfig themeConfig = const XDefaultThemeConfig(),
  }) async {
    ///Boots playx dependencies.
    await boot(appConfig: appConfig, themeConfig: themeConfig);

    /// run the app.
    runApp(app);
  }
}
