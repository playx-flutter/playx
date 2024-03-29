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
    themeConfig: AppThemeConfig(),
    envSettings: const PlayxEnvSettings(
      fileName: 'assets/env/keys.env',
    ),
    app: const MyApp(),

    //not necessary
    sentryOptions: (options) {
      options.dsn = AppConfig.sentryKey;
    },
    localeConfig: AppLocaleConfig(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PlayxMaterialApp(
      title: AppTrans.appName.tr,
      navigationSettings: const PlayxNavigationSettings(
        home: Home(),
      ),
      appSettings: const PlayxAppSettings(
        debugShowCheckedModeBanner: true,
      ),
    );
  }
}
