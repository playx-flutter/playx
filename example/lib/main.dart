import 'package:example/config.dart';
import 'package:flutter/material.dart';
import 'package:playx/playx.dart';

void main() => Playx.runPlayX(
      app: const MyApp(),
      appConfig: AppConfig(),
    );

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
            body: Center(
              child: Text(AppTheme.xTheme.nameBuilder()),
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
