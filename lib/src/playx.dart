library;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:playx/playx.dart';

/// The Playx library provides a suite of utilities for app setup, configuration, and management.
///
/// Key features include:
/// - [PlayxPrefs]: Simplified key-value storage using shared preferences.
/// - [PlayXAppConfig]: Install and set up dependencies required by the app.
/// - [PlayxTheme]: Manage and change app themes easily.
///
/// This abstract class facilitates the initialization and management of Playx-related components.
abstract class Playx {
  static final _asyncCompleter = Completer<void>();

  /// The current app configuration.
  static PlayXAppConfig? _config;

  /// Returns the current app configuration.
  ///
  /// Throws an exception if the app configuration is not set.
  static PlayXAppConfig get appConfig {
    if (_config == null) {
      throw Exception(
          'App config not set. Please ensure you have called boot() before accessing the app config.');
    }
    return _config!;
  }

  /// Boots the Playx package by setting up app dependencies, localization, theme, and preferences.
  ///
  /// This method must be called to initialize dependencies before using Playx features.
  ///
  /// [appConfig]: The app configuration to set up.
  /// [localeConfig]: The locale configuration for localization.
  /// [themeConfig]: The theme configuration for the app.
  /// [securePrefsSettings]: Settings for secure preferences (default: [PlayxSecurePrefsSettings]).
  /// [envSettings]: Optional environment settings for configuration.
  static Future<void> boot({
    required PlayXAppConfig appConfig,
    required PlayxLocaleConfig localeConfig,
    required PlayxThemeConfig themeConfig,
    PlayxSecurePrefsSettings securePrefsSettings =
        const PlayxSecurePrefsSettings(),
    PlayxEnvSettings? envSettings,
    PlayxPrefsSettings prefsSettings = const PlayxPrefsSettings(),
    WorkManagerSettings workManagerSettings = const WorkManagerSettings(),
  }) async {
    EasyLocalization.logger.name = "Playx";

    WidgetsFlutterBinding.ensureInitialized();

    await PlayxCore.bootCore(
        securePrefsSettings: securePrefsSettings,
        envSettings: envSettings,
        prefsSettings: prefsSettings,
        workerManagerSettings: workManagerSettings);
    EasyLocalization.logger('Core booted ✔');

    await PlayxLocalization.boot(config: localeConfig);

    /// Boot the theme configuration.
    await PlayxTheme.boot(config: themeConfig);
    EasyLocalization.logger('Theme booted ✔');

    /// Boot the app configuration.
    await appConfig.boot();
    EasyLocalization.logger('AppConfig booted ✔');

    // Boot long-running tasks asynchronously.
    _asyncCompleter.complete(appConfig.asyncBoot());
  }

  /// Wraps `runApp` to initialize and set up Playx packages before running the app.
  ///
  /// [appConfig]: The app configuration to set up.
  /// [app]: The root widget of the application.
  /// [localeConfig]: The locale configuration for localization.
  /// [themeConfig]: The theme configuration for the app.
  /// [securePrefsSettings]: Settings for secure preferences (default: [PlayxSecurePrefsSettings]).
  /// [envSettings]: Optional environment settings for configuration.
  /// [sentryOptions]: Optional Sentry configuration for crash reporting.
  /// [prefsSettings]: Settings for shared preferences (default: [PlayxPrefsSettings]).
  /// [workManagerSettings]: Settings for WorkManager (default: [WorkManagerSettings]).
  static Future<void> runPlayx({
    required PlayXAppConfig appConfig,
    required Widget app,
    required PlayxLocaleConfig localeConfig,
    required PlayxThemeConfig themeConfig,
    PlayxSecurePrefsSettings securePrefsSettings =
        const PlayxSecurePrefsSettings(),
    PlayxPrefsSettings prefsSettings = const PlayxPrefsSettings(),
    WorkManagerSettings workManagerSettings = const WorkManagerSettings(),
    PlayxEnvSettings? envSettings,
    FlutterOptionsConfiguration? sentryOptions,
  }) async {
    // Boots Playx dependencies.
    await boot(
        appConfig: appConfig,
        themeConfig: themeConfig,
        securePrefsSettings: securePrefsSettings,
        envSettings: envSettings,
        localeConfig: localeConfig,
        prefsSettings: prefsSettings,
        workManagerSettings: workManagerSettings);

    if (sentryOptions != null) {
      await SentryFlutter.init(
        sentryOptions,
        // Run the app after initializing Sentry.
        appRunner: () => runApp(app),
      );
    } else {
      runApp(app);
    }
  }

  /// Checks whether the application has finished performing the asynchronous boot operation successfully.
  static bool isAsyncBootCompleted() {
    return _asyncCompleter.isCompleted;
  }

  /// Returns the future for the asynchronous boot operation.
  ///
  /// This can be used to wait for the asynchronous boot operation to complete.
  static Future<void> asyncBootFuture() {
    return _asyncCompleter.future;
  }

  /// Disposes of the Playx package, cleaning up resources and freeing memory.
  ///
  /// This method is useful for cleanup and should be called when the application is disposed.
  @visibleForTesting
  static Future<void> dispose() async {
    await _config?.dispose();
    await PlayxTheme.dispose();
    await PlayxCore.dispose();
    EasyLocalization.logger('Disposed ✔');
  }
}
