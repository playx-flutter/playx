library;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:playx/playx.dart';
import 'package:playx/src/models/playx_web_settings.dart';

/// Typedefs for configuration builders
typedef PlayxAppConfigBuilder = PlayXAppConfig Function();
typedef PlayxLocaleConfigBuilder = PlayxLocaleConfig Function();
typedef PlayxThemeConfigBuilder = PlayxThemeConfig Function();
typedef PlayxEnvSettingsBuilder = PlayxEnvSettings Function()?;

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
  /// **New Parameters (Preferred)**:
  /// - [appConfigBuilder]: A builder function returning the app configuration.
  /// - [localeConfigBuilder]: A builder function returning the locale configuration.
  /// - [themeConfigBuilder]: A builder function returning the theme configuration.
  /// - [envSettingsBuilder]: A builder function returning environment settings (optional).
  ///
  /// **Deprecated Parameters (Will be Removed in Future Versions)**:
  /// - [appConfig], [localeConfig], [themeConfig]: Directly passing config objects is now discouraged.
  /// - [envSettings]: Use [envSettingsBuilder] instead.
  ///
  /// Other Parameters:
  /// - [securePrefs]: Settings for secure preferences.
  /// - [prefs]: Settings for preferences storage.
  /// - [workManager]: Settings for background task management.
  /// - [webConfig]: Settings for web-specific configurations.
  static Future<void> boot({
    // New recommended function-based parameters
    PlayxAppConfigBuilder? appConfigBuilder,
    PlayxLocaleConfigBuilder? localeConfigBuilder,
    PlayxThemeConfigBuilder? themeConfigBuilder,
    PlayxEnvSettingsBuilder? envSettingsBuilder,

    // Deprecated parameters
    @Deprecated('Use appConfigBuilder instead.') PlayXAppConfig? appConfig,
    @Deprecated('Use localeConfigBuilder instead.') PlayxLocaleConfig? localeConfig,
    @Deprecated('Use themeConfigBuilder instead.') PlayxThemeConfig? themeConfig,
    @Deprecated('Use envSettingsBuilder instead.') PlayxEnvSettings? envSettings,

    // Other parameters (unchanged)
    PlayxSecurePrefsSettings securePrefsSettings = const PlayxSecurePrefsSettings(),
    PlayxPrefsSettings prefsSettings = const PlayxPrefsSettings(),
    WorkManagerSettings workManagerSettings = const WorkManagerSettings(),
    PlayxWebSettings webSettings = const PlayxWebSettings(),
  }) async {
    EasyLocalization.logger.name = "Playx";

    WidgetsFlutterBinding.ensureInitialized();
    assert(
    (appConfigBuilder != null && appConfig == null) || (appConfigBuilder == null && appConfig != null) || (appConfigBuilder == null && appConfig == null),
    'Use either appConfigBuilder or appConfig, not both.'
    );
    assert(
    (localeConfigBuilder != null && localeConfig == null) || (localeConfigBuilder == null && localeConfig != null) || (localeConfigBuilder == null && localeConfig == null),
    'Use either localeConfigBuilder or localeConfig, not both.'
    );
    assert(
    (themeConfigBuilder != null && themeConfig == null) || (themeConfigBuilder == null && themeConfig != null) || (themeConfigBuilder == null && themeConfig == null),
    'Use either themeConfigBuilder or themeConfig, not both.'
    );
    assert(
    (envSettingsBuilder != null && envSettings == null) || (envSettingsBuilder == null && envSettings != null),
    'Use either envSettingsBuilder or envSettings, not both.'
    );

    final envSettingsInstance = envSettingsBuilder?.call() ?? envSettings;

    await PlayxCore.bootCore(
        securePrefsSettings: securePrefsSettings,
        envSettings: envSettingsInstance,
        prefsSettings: prefsSettings,
        workerManagerSettings: workManagerSettings);
    EasyLocalization.logger('Core booted ✔');


    final localeConfigInstance = localeConfigBuilder?.call() ?? localeConfig!;
    await PlayxLocalization.boot(config: localeConfigInstance);

    final themeConfigInstance = themeConfigBuilder?.call() ?? themeConfig!;
    /// Boot the theme configuration.
    await PlayxTheme.boot(config: themeConfigInstance);
    EasyLocalization.logger('Theme booted ✔');

    final appConfigInstance = appConfigBuilder?.call() ?? appConfig!;
    /// Boot the app configuration.
    await appConfigInstance.boot();
    EasyLocalization.logger('AppConfig booted ✔');

    /// Set up web navigation settings.
    PlayxNavigation.setupWeb(
      usePathUrlStrategy: webSettings.usePathUrlStrategy,
      optionURLReflectsImperativeAPIs: webSettings.optionURLReflectsImperativeAPIs,
    );

    /// Boot long-running tasks asynchronously.
    _asyncCompleter.complete(appConfigInstance.asyncBoot());
  }

  /// Wraps `runApp` to initialize and set up Playx packages before running the app.
  ///
  /// [app]: The root widget of the application.
  /// [appConfigBuilder]: A function that returns the app configuration.
  /// [localeConfigBuilder]: A function that returns the locale configuration.
  /// [themeConfigBuilder]: A function that returns the theme configuration.
  /// [securePrefsSettings]: Settings for secure preferences (default: [PlayxSecurePrefsSettings]).
  /// [prefsSettings]: Settings for shared preferences (default: [PlayxPrefsSettings]).
  /// [workManagerSettings]: Settings for WorkManager (default: [WorkManagerSettings]).
  /// [envSettingsBuilder]: A function that returns optional environment settings.
  /// [sentryOptions]: Optional Sentry configuration for crash reporting.
  static Future<void> runPlayx({
    required Widget  app,
    PlayxAppConfigBuilder? appConfigBuilder,
    PlayxLocaleConfigBuilder? localeConfigBuilder,
    PlayxThemeConfigBuilder? themeConfigBuilder,
    PlayxEnvSettingsBuilder? envSettingsBuilder,
    PlayxSecurePrefsSettings securePrefsSettings =
        const PlayxSecurePrefsSettings(),
    PlayxPrefsSettings prefsSettings = const PlayxPrefsSettings(),
    WorkManagerSettings workManagerSettings = const WorkManagerSettings(),
    FlutterOptionsConfiguration? sentryOptions,
    PlayxWebSettings webSettings = const PlayxWebSettings(),
    // Deprecated parameters
    @Deprecated('Use appConfigBuilder instead.') PlayXAppConfig? appConfig,
    @Deprecated('Use localeConfigBuilder instead.') PlayxLocaleConfig? localeConfig,
    @Deprecated('Use themeConfigBuilder instead.') PlayxThemeConfig? themeConfig,
    @Deprecated('Use envSettingsBuilder instead.') PlayxEnvSettings? envSettings,

  }) async {
    assert(
    (appConfigBuilder != null && appConfig == null) || (appConfigBuilder == null && appConfig != null) || (appConfigBuilder == null && appConfig == null),
    'Use either appConfigBuilder or appConfig, not both.'
    );
    assert(
    (localeConfigBuilder != null && localeConfig == null) || (localeConfigBuilder == null && localeConfig != null) || (localeConfigBuilder == null && localeConfig == null),
    'Use either localeConfigBuilder or localeConfig, not both.'
    );
    assert(
    (themeConfigBuilder != null && themeConfig == null) || (themeConfigBuilder == null && themeConfig != null) || (themeConfigBuilder == null && themeConfig == null),
    'Use either themeConfigBuilder or themeConfig, not both.'
    );
    assert(
    (envSettingsBuilder != null && envSettings == null) || (envSettingsBuilder == null && envSettings != null),
    'Use either envSettingsBuilder or envSettings, not both.'
    );

    // Boots Playx dependencies.
    await boot(
      appConfig: appConfig,
      themeConfig: themeConfig,
      envSettings: envSettings,
      localeConfig: localeConfig,
      appConfigBuilder: appConfigBuilder,
      localeConfigBuilder: localeConfigBuilder,
      themeConfigBuilder: themeConfigBuilder,
      envSettingsBuilder: envSettingsBuilder,
      securePrefsSettings: securePrefsSettings,
      prefsSettings: prefsSettings,
      workManagerSettings: workManagerSettings,
      webSettings: webSettings,
    );

    if (sentryOptions != null) {
      await SentryFlutter.init(
        sentryOptions,
        // Run the app after initializing Sentry.
        appRunner: ()=> runApp(app),
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
