library playx;

import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:playx/playx.dart';

///helps with redundant features , less code by providing many futures like:
/// [Prefs] : easily save/ get key-value pairs from shared preferences.
/// [PlayXAppConfig] : install and setup any dependencies that are required by the app.
/// [AppTheme] : easily create and mange app theme with the ability to easily change app theme.
abstract class Playx {
  static Future<void> boot({
    required PlayXAppConfig appConfig,
    required XLocaleConfig localeConfig,
    XThemeConfig themeConfig = const XDefaultThemeConfig(),
    SecurePrefsSettings securePrefsSettings= const SecurePrefsSettings(),
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    /// * boot the theme
    await AppTheme.boot(
        config: themeConfig, securePrefsSettings: securePrefsSettings);
    EasyLocalization.logger.name = "Playx";
    EasyLocalization.logger('Theme booted ✔');

    /// * boot app config.
    await appConfig.boot();
    EasyLocalization.logger('appConfig booted ✔');

    /// * inject the theme
    Get.put<PlayXAppConfig>(appConfig, permanent: true);

    return PlayxLocalization.boot(config: localeConfig);
  }

  @visibleForTesting
  static Future<void> dispose() async {
    await AppTheme.dispose();
    log('[playx] disposed ✔');
  }

  ///Wraps`runApp` to inject , init ..etc and setup playx packages.
  static Future<void> runPlayx({
    required PlayXAppConfig appConfig,
    required Widget app,
    required XLocaleConfig localeConfig,
    XThemeConfig themeConfig = const XDefaultThemeConfig(),
    SecurePrefsSettings securePrefsSettings= const SecurePrefsSettings(),

    /// Options used to initialize sentry to send crash reports to it.
    /// If sentry dsn not provided it will ignore sentry.
    FlutterOptionsConfiguration? sentryOptions,
  }) async {
    ///Boots playx dependencies.
    await boot(appConfig: appConfig, themeConfig: themeConfig,securePrefsSettings: securePrefsSettings, localeConfig:localeConfig);

    if (sentryOptions != null) {
      await SentryFlutter.init(
        sentryOptions,

        /// run the app.
        appRunner: () => runApp(app),
      );
    } else {
      runApp(app);
    }
  }
}
