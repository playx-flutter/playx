library playx;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:playx/config/playx.dart';
import 'package:playx_theme/playx_theme.dart';
import 'package:playx_core/playx_core.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

export 'exports.dart';

abstract class Playx {
  static Future<void> runPlayX({
    required Widget app,
    required PlayXAppConfig appConfig,
    XThemeConfig themeConfig = const XDefualtThemeConfig(),
  }) async {
    /// * boot the core
    await PlayXCore.bootCore();

    /// * boot the theme
    await AppTheme.boot(config: themeConfig);

    /// * inject the theme
    Get.put<PlayXAppConfig>(appConfig, permanent: true);

    runZonedGuarded(
      () async {
        await SentryFlutter.init((opt) => opt.dsn = appConfig.sentryKey);
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
  static Future<void> disbose() async {
    // ignore: invalid_use_of_visible_for_testing_member
    await PlayXCore.disbose();
  }
}
