import 'package:flutter/material.dart';
import 'package:playx/playx.dart';
import 'package:playx_example/config/theme_config.dart';
import 'package:playx_example/home.dart';
import 'package:playx_example/translation/app_locale_config.dart';
import 'package:playx_example/translation/app_trans.dart';

import 'config/app_config.dart';

void main() async {
  final config = AppConfig();

  Playx.runPlayx(
    appConfig: config,
    themeConfig: const AppThemeConfig(),
    app: const MyApp(),
    //not necessary
    sentryOptions: (options) {
      options.dsn = AppConfig.sentryKey;
    },
    localeConfig: AppLocaleConfig(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  PlayxPlatformApp(
      title: AppTrans.appName.tr,
      home: const Home(),
    );
  }
}
