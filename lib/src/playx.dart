library playx;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:playx/playx.dart';

///helps with redundant features , less code by providing many futures like:
/// [Prefs] : easily save/ get key-value pairs from shared preferences.
/// [PlayXAppConfig] : install and setup any dependencies that are required by the app.
/// [PlayxTheme] : easily create and mange app theme with the ability to easily change app theme.
abstract class Playx {
  static final _asyncCompleter = Completer();

  /// The current app config.
  static PlayXAppConfig? _config;

  ///Returns the current app config.
  ///Throws an exception if the app config is not set.
  static PlayXAppConfig get appConfig {
    if (_config == null) {
      throw Exception(
          'App config not set. Please ensure you have called boot() before accessing the app config.');
    }
    return _config!;
  }

  ///Boots playx package
  ///Used to setup app dependencies, localization, theme and preferences.
  ///Must be called to initialize dependencies.
  static Future<void> boot({
    required PlayXAppConfig appConfig,
    required PlayxLocaleConfig localeConfig,
    required PlayxThemeConfig themeConfig,
    PlayxSecurePrefsSettings securePrefsSettings =
        const PlayxSecurePrefsSettings(),
    PlayxEnvSettings? envSettings,
  }) async {
    EasyLocalization.logger.name = "Playx";

    WidgetsFlutterBinding.ensureInitialized();

    await PlayxCore.bootCore(
        securePrefsSettings: securePrefsSettings, envSettings: envSettings);
    EasyLocalization.logger('Core booted ✔');

    await PlayxLocalization.boot(config: localeConfig);

    /// * boot the theme
    await PlayxTheme.boot(config: themeConfig);
    EasyLocalization.logger('Theme booted ✔');

    /// * boot app config.
    await appConfig.boot();
    EasyLocalization.logger('appConfig booted ✔');

    //boot long running tasks asynchronously.
    _asyncCompleter.complete(appConfig.asyncBoot());
  }

  ///Wraps`runApp` to inject , init and setup playx packages.
  ///[sentryOptions] : are used to initialize sentry to send crash reports to it.
  /// If sentry dsn not provided it will ignore sentry.
  static Future<void> runPlayx({
    required PlayXAppConfig appConfig,
    required Widget app,
    required PlayxLocaleConfig localeConfig,
    required PlayxThemeConfig themeConfig,
    PlayxSecurePrefsSettings securePrefsSettings =
        const PlayxSecurePrefsSettings(),
    PlayxEnvSettings? envSettings,
    FlutterOptionsConfiguration? sentryOptions,
  }) async {
    ///Boots playx dependencies.
    await boot(
        appConfig: appConfig,
        themeConfig: themeConfig,
        securePrefsSettings: securePrefsSettings,
        envSettings: envSettings,
        localeConfig: localeConfig);

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

  ///Checks whether the application finished performing the async boot operation successfully.
  static bool isAsyncBootCompleted() {
    return _asyncCompleter.isCompleted;
  }

  ///Returns the future of performing the async boot operation.
  ///Can be used to wait for the async boot operation to complete.
  static Future<void> asyncBootFuture() {
    return _asyncCompleter.future;
  }

  ///Dispose playx package
  ///Used to clean up and free up resources.
  @visibleForTesting
  static Future<void> dispose() async {
    await _config?.dispose();
    await PlayxTheme.dispose();
    await PlayxCore.dispose();
    EasyLocalization.logger('disposed ✔');
  }
}
