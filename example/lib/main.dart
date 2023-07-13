import 'package:flutter/material.dart';
import 'package:playx/playx.dart';
import 'package:playx_example/colors/base_color_scheme.dart';
import 'package:playx_example/config/theme_config.dart';

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
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlayXThemeBuilder(
      builder: (xTheme) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: xTheme.theme,
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Playx Example'),
            ),
            body: OptimizedScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: context.width * .5,
                    color: colorScheme.onBackground,
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      AppTheme.name,
                      style: TextStyle(color: colorScheme.background),
                    ),
                  ),
                  const AppVersion(),
                  ImageViewer.network(
                    'https://avatars.githubusercontent.com/u/35397170?s=200&v=4',
                    height: 100,
                  ),
                  CachedNetworkImage(
                    imageUrl:
                        'https://avatars.githubusercontent.com/u/35397170?s=200&v=4',
                    height: 100,
                  ),
                  OptimizedButton.elevated(child: Text('Click Me'), onPressed: (){
                  })

                ],
              ),
            ),
            floatingActionButton: const FloatingActionButton(
              onPressed: AppTheme.next,
              tooltip: 'Increment',
              child: Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }
}
