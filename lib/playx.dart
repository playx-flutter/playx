library playx;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:playx/config/playx.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

export 'exports.dart';

Future<void> bootPlayX({
  required Widget app,
  required PlayXAppConfig appConfig,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  /// inject SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(prefs, permanent: true);

  Get.put<PlayXAppConfig>(appConfig, permanent: true);
  await SentryFlutter.init(
    (options) {
      if (appConfig.enableSentryReport) {
        options.dsn = appConfig.sentryKey;
      }
    },
    appRunner: () => runApp(app),
  );
}
