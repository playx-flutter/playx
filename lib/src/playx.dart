library;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:playx/playx.dart';

/// Typedefs for configuration builders
typedef PlayxAppConfigBuilder = PlayXAppConfig Function();
typedef PlayxLocaleConfigBuilder = PlayxLocaleConfig Function();
typedef PlayxThemeConfigBuilder = PlayxThemeConfig Function();
typedef PlayxEnvSettingsBuilder = PlayxEnvSettings Function();
typedef PlayxAppRunner = FutureOr<void> Function();

/// The Playx library provides a suite of utilities for app setup, configuration, and management.
///
/// Key features include:
/// - [PlayxPrefs]: Simplified key-value storage using shared preferences.
/// - [PlayXAppConfig]: Install and set up dependencies required by the app.
/// - [PlayxTheme]: Manage and change app themes easily.
///
/// This abstract class facilitates the initialization and management of Playx-related components.
abstract class Playx {
  /// The in-flight or completed boot, so calling [boot] more than once is safe.
  static Future<void>? _bootFuture;

  /// The future of the asynchronous boot, set once [boot] finishes.
  static Future<void>? _asyncBootFuture;
  static bool _asyncBootCompleted = false;
  static Object? _asyncBootError;
  static StackTrace? _asyncBootStackTrace;

  /// The current app configuration.
  static PlayXAppConfig? _config;

  /// Returns the current app configuration.
  ///
  /// Throws an exception if the app configuration is not set.
  static PlayXAppConfig get appConfig {
    if (_config == null) {
      throw Exception(
        'App config not set. Please ensure you have called boot() before accessing the app config.',
      );
    }
    return _config!;
  }

  /// Boots the Playx package by setting up app dependencies, localization, theme, and preferences.
  ///
  /// This method must be called to initialize dependencies before using Playx features.
  /// Calling it again returns the same boot instead of running it twice.
  ///
  /// Parameters:
  /// - [appConfigBuilder]: A builder function returning the app configuration.
  /// - [localeConfigBuilder]: A builder function returning the locale configuration.
  /// - [themeConfigBuilder]: A builder function returning the theme configuration.
  /// - [envSettingsBuilder]: A builder function returning environment settings (optional).
  /// - [securePrefsSettings]: Settings for secure preferences.
  /// - [prefsSettings]: Settings for preferences storage.
  /// - [workManagerSettings]: Settings for background task management.
  /// - [webSettings]: Settings for web-specific configurations.
  /// - [initializeBinding]: Whether to call `WidgetsFlutterBinding.ensureInitialized()`
  ///   before booting (default: `true`). Set to `false` if the binding is already
  ///   initialized by the caller (for example in the same zone as `runApp` on web).
  static Future<void> boot({
    required PlayxAppConfigBuilder appConfigBuilder,
    required PlayxLocaleConfigBuilder localeConfigBuilder,
    required PlayxThemeConfigBuilder themeConfigBuilder,
    PlayxEnvSettingsBuilder? envSettingsBuilder,
    PlayxSecurePrefsSettings securePrefsSettings =
        const PlayxSecurePrefsSettings(),
    PlayxPrefsSettings prefsSettings = const PlayxPrefsSettings(),
    WorkManagerSettings workManagerSettings = const WorkManagerSettings(),
    PlayxWebSettings webSettings = const PlayxWebSettings(),
    bool initializeBinding = true,
  }) {
    // Calling boot again returns the same boot instead of running it twice.
    // A failed boot is cleared so it can be retried.
    return _bootFuture ??=
        _boot(
          appConfigBuilder: appConfigBuilder,
          localeConfigBuilder: localeConfigBuilder,
          themeConfigBuilder: themeConfigBuilder,
          envSettingsBuilder: envSettingsBuilder,
          securePrefsSettings: securePrefsSettings,
          prefsSettings: prefsSettings,
          workManagerSettings: workManagerSettings,
          webSettings: webSettings,
          initializeBinding: initializeBinding,
        ).onError<Object>((error, stackTrace) {
          _bootFuture = null;
          Error.throwWithStackTrace(error, stackTrace);
        });
  }

  static Future<void> _boot({
    required PlayxAppConfigBuilder appConfigBuilder,
    required PlayxLocaleConfigBuilder localeConfigBuilder,
    required PlayxThemeConfigBuilder themeConfigBuilder,
    PlayxEnvSettingsBuilder? envSettingsBuilder,
    required PlayxSecurePrefsSettings securePrefsSettings,
    required PlayxPrefsSettings prefsSettings,
    required WorkManagerSettings workManagerSettings,
    required PlayxWebSettings webSettings,
    required bool initializeBinding,
  }) async {
    if (initializeBinding) {
      WidgetsFlutterBinding.ensureInitialized();
    }

    final logger = PlayxLogger.initLogger(
      name: 'playx',
      setAsDefault: false,
      useColoredFormatter: true,
    );
    await _runBootStep(logger, 'Core', () async {
      await PlayxCore.bootCore(
        securePrefsSettings: securePrefsSettings,
        envSettings: envSettingsBuilder?.call(),
        prefsSettings: prefsSettings,
        workerManagerSettings: workManagerSettings,
      );
    });

    await _runBootStep(logger, 'Localization', () async {
      await PlayxLocalization.boot(config: localeConfigBuilder());
    });

    await _runBootStep(logger, 'Theme', () async {
      await PlayxTheme.boot(config: themeConfigBuilder());
    });

    final appConfigInstance = appConfigBuilder();
    _config = appConfigInstance;
    await _runBootStep(logger, 'AppConfig', () => appConfigInstance.boot());

    await _runBootStep(logger, 'Web navigation', () async {
      PlayxNavigation.setupWeb(
        usePathUrlStrategy: webSettings.usePathUrlStrategy,
        optionURLReflectsImperativeAPIs:
            webSettings.optionURLReflectsImperativeAPIs,
      );
    });

    // Boot long-running tasks in the background. Failures are logged and
    // reported to Sentry, and are also available through [asyncBootFuture].
    _asyncBootCompleted = false;
    _asyncBootError = null;
    _asyncBootStackTrace = null;
    final asyncBoot = _runAsyncBoot(logger, appConfigInstance);
    // Mark as handled so an unawaited failure is not an unhandled error.
    // Callers awaiting [asyncBootFuture] still receive the error.
    asyncBoot.ignore();
    _asyncBootFuture = asyncBoot;
  }

  /// Runs a boot step and wraps any failure in a [PlayxBootException].
  static Future<void> _runBootStep(
    PlayxBaseLogger logger,
    String step,
    FutureOr<void> Function() run,
  ) async {
    try {
      await run();
      logger.i('$step booted ✔');
    } catch (error, stackTrace) {
      logger.e('$step boot failed ✘', error: error, stackTrace: stackTrace);
      Error.throwWithStackTrace(
        PlayxBootException(step, error, stackTrace),
        stackTrace,
      );
    }
  }

  static Future<void> _runAsyncBoot(
    PlayxBaseLogger logger,
    PlayXAppConfig config,
  ) async {
    try {
      await config.asyncBoot();
      _asyncBootCompleted = true;
      logger.i('AppConfig async boot completed ✔');
    } catch (error, stackTrace) {
      _asyncBootError = error;
      _asyncBootStackTrace = stackTrace;
      logger.e(
        'AppConfig async boot failed ✘',
        error: error,
        stackTrace: stackTrace,
      );
      if (Sentry.isEnabled) {
        await Sentry.captureException(error, stackTrace: stackTrace);
      }
      rethrow;
    }
  }

  /// Wraps `runApp` to initialize and set up Playx packages before running the app.
  ///
  /// [appRunner]: Runs the application after Playx finishes booting.
  /// [appConfigBuilder]: A function that returns the app configuration.
  /// [localeConfigBuilder]: A function that returns the locale configuration.
  /// [themeConfigBuilder]: A function that returns the theme configuration.
  /// [securePrefsSettings]: Settings for secure preferences (default: [PlayxSecurePrefsSettings]).
  /// [prefsSettings]: Settings for shared preferences (default: [PlayxPrefsSettings]).
  /// [workManagerSettings]: Settings for WorkManager (default: [WorkManagerSettings]).
  /// [envSettingsBuilder]: A function that returns optional environment settings.
  /// [sentryOptions]: Optional Sentry configuration for crash reporting.
  /// [initializeBinding]: Whether to initialize `WidgetsFlutterBinding` (default: `true`).
  ///
  /// The binding is always initialized in the same zone that later calls `runApp`:
  /// - With Sentry, it is initialized inside Sentry's `appRunner` (Sentry runs the
  ///   app in a guarded zone), never before `SentryFlutter.init`. Calling it earlier
  ///   would put the binding and `runApp` in different zones, which breaks on web.
  /// - Without Sentry, it is initialized right before booting.
  static Future<void> runPlayx({
    required PlayxAppRunner appRunner,
    required PlayxAppConfigBuilder appConfigBuilder,
    required PlayxLocaleConfigBuilder localeConfigBuilder,
    required PlayxThemeConfigBuilder themeConfigBuilder,
    PlayxEnvSettingsBuilder? envSettingsBuilder,
    PlayxSecurePrefsSettings securePrefsSettings =
        const PlayxSecurePrefsSettings(),
    PlayxPrefsSettings prefsSettings = const PlayxPrefsSettings(),
    WorkManagerSettings workManagerSettings = const WorkManagerSettings(),
    FlutterOptionsConfiguration? sentryOptions,
    PlayxWebSettings webSettings = const PlayxWebSettings(),
    bool initializeBinding = true,
  }) async {
    Future<void> bootAndRun() async {
      await boot(
        appConfigBuilder: appConfigBuilder,
        localeConfigBuilder: localeConfigBuilder,
        themeConfigBuilder: themeConfigBuilder,
        envSettingsBuilder: envSettingsBuilder,
        securePrefsSettings: securePrefsSettings,
        prefsSettings: prefsSettings,
        workManagerSettings: workManagerSettings,
        webSettings: webSettings,
        initializeBinding: initializeBinding,
      );
      await Future<void>.sync(appRunner);
    }

    if (sentryOptions != null) {
      // Boot Playx inside Sentry's app runner so binding initialization and
      // runApp execute in the same zone, especially on Flutter web.
      await SentryFlutter.init(sentryOptions, appRunner: bootAndRun);
    } else {
      await bootAndRun();
    }
  }

  /// Checks whether the asynchronous boot operation finished successfully.
  ///
  /// Returns `false` while it is running, if it failed, or before [boot] ran.
  /// Use [hasAsyncBootFailed] or [isAsyncBootFinished] to tell these apart.
  static bool isAsyncBootCompleted() => _asyncBootCompleted;

  /// Checks whether the asynchronous boot operation failed.
  ///
  /// The error is available through [asyncBootError].
  static bool hasAsyncBootFailed() => _asyncBootError != null;

  /// Checks whether the asynchronous boot operation is done, whether it
  /// succeeded ([isAsyncBootCompleted]) or failed ([hasAsyncBootFailed]).
  static bool isAsyncBootFinished() =>
      _asyncBootCompleted || hasAsyncBootFailed();

  /// The error thrown by the asynchronous boot operation, or `null` if it
  /// has not failed.
  static Object? get asyncBootError => _asyncBootError;

  /// The stack trace of [asyncBootError], or `null` if it has not failed.
  static StackTrace? get asyncBootStackTrace => _asyncBootStackTrace;

  /// Waits for the asynchronous boot operation to finish without throwing.
  ///
  /// Returns `true` if it succeeded and `false` if it failed; the error is
  /// then available through [asyncBootError]. Use [asyncBootFuture] if you
  /// prefer to receive the error as an exception.
  static Future<bool> waitForAsyncBoot() async {
    try {
      await asyncBootFuture();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Returns the future for the asynchronous boot operation.
  ///
  /// This can be used to wait for the asynchronous boot operation to complete.
  ///
  /// If the asynchronous boot failed, the returned future completes with that error.
  /// Before [boot] has finished it waits for boot first.
  static Future<void> asyncBootFuture() async {
    await _bootFuture;
    await _asyncBootFuture;
  }

  /// Disposes of the Playx package, cleaning up resources and freeing memory.
  ///
  /// This method is useful for cleanup and should be called when the application is disposed.
  @visibleForTesting
  static Future<void> dispose() async {
    await _config?.dispose();
    _config = null;
    _bootFuture = null;
    _asyncBootFuture = null;
    _asyncBootCompleted = false;
    _asyncBootError = null;
    _asyncBootStackTrace = null;
    await PlayxTheme.dispose();
    await PlayxCore.dispose();
  }
}
