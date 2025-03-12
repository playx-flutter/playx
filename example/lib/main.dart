import 'package:flutter/material.dart';
import 'package:playx/playx.dart';
import 'package:playx_example/config/theme_config.dart';
import 'package:playx_example/home.dart';
import 'package:playx_example/translation/app_locale_config.dart';
import 'package:playx_example/translation/app_trans.dart';

import 'config/app_config.dart';

void main() async {

  Playx.runPlayx(
    appConfigBuilder:()=> AppConfig(),
    themeConfigBuilder:()=> createThemeConfig(),
    envSettingsBuilder:()=> const PlayxEnvSettings(
      fileName: 'assets/env/keys.env',
    ),
    localeConfigBuilder:()=> createLocaleConfig(),
    app:const MyApp(),
    //not necessary
    // sentryOptions: (options) {
    //   options.dsn = AppConfig.sentryKey;
    // },
  );
}


final goRouter = GoRouter(
  routes: [
    PlayxRoute(path: '/', builder: (context, state) => const Home()),
  ],
);


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return PlayxMaterialApp(
      navigationSettings: PlayxNavigationSettings.goRouter(
        goRouter: goRouter,
      ),
      appSettings: const PlayxAppSettings(
        debugShowCheckedModeBanner: true,
        title: AppTrans.appName,
      ),
    );
  }
}
