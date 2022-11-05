library playx;

import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:playx/config/playx.dart';
import 'package:playx_theme/playx_theme.dart';
import 'package:playx_core/playx_core.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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

  static Future<void> runPlayX({
    required Widget app,
    required PlayXAppConfig appConfig,
  }) async {
    runZonedGuarded(
      () async {
        if (appConfig.enableSentryReport) {
          await SentryFlutter.init((opt) => opt.dsn = appConfig.sentryKey);
          log('[playx] sentry booted ✔');
        } else {
          log('[playx] sentry is not enabled');
        }
        runApp(app);
      },
      (e, st) async {
        if (kDebugMode) {
          print(e);
          print(st);
        }
        await Sentry.captureException(e, stackTrace: st);
      },
    );
  }

  @visibleForTesting
  static Future<void> dispose() async {
    await PlayXCore.dispose();
  }
}
